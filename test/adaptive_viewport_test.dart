import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/widgets/adaptive_viewport.dart';
import 'package:we_pei_yang_flutter/commons/widgets/pane_route.dart';

void main() {
  group('ViewportSpec.resolve', () {
    // 常见手机逻辑分辨率：必须与原来完全一致（设计稿 390x844、铺满屏幕）
    const phones = [
      Size(320, 568), // iPhone SE 1
      Size(360, 640),
      Size(360, 800),
      Size(375, 667), // iPhone 8
      Size(390, 844), // iPhone 12/13/14
      Size(393, 852), // iPhone 15/16
      Size(412, 915), // Pixel
      Size(430, 932), // iPhone Pro Max
      Size(344, 882), // 折叠屏外屏
    ];
    for (final size in phones) {
      test('phone $size keeps original layout', () {
        final spec = ViewportSpec.resolve(size);
        expect(spec.isPhone, isTrue);
        expect(spec.isSplit, isFalse);
        expect(spec.designSize, const Size(390, 844));
      });
    }

    const others = {
      'foldable inner': Size(741, 832),
      'galaxy fold inner': Size(884, 1104),
      'ipad portrait': Size(820, 1180),
      'ipad landscape': Size(1180, 820),
      'ipad 10.2': Size(810, 1080),
      'ipad pro 12.9': Size(1024, 1366),
      'desktop': Size(1600, 900),
      'desktop default': Size(1280, 720),
      'desktop narrow': Size(700, 900),
      'small tablet portrait': Size(600, 960),
      'tall narrow window': Size(290, 1500),
      'desktop huge': Size(2560, 1440),
    };
    for (final e in others.entries) {
      test('${e.key} ${e.value}: uniform scale, panes fit a phone design', () {
        final spec = ViewportSpec.resolve(e.value);
        expect(spec.isPhone, isFalse);
        // 宽高等比缩放，不再出现 .w 与 .h 比例不一致导致的变形
        final sx = e.value.width / spec.designSize.width;
        final sy = e.value.height / spec.designSize.height;
        expect(sx, closeTo(sy, 1e-9));
        expect(sx, lessThanOrEqualTo(ViewportSpec.maxScale));
        // 竖向至少容纳一屏手机设计稿
        expect(spec.designSize.height, greaterThanOrEqualTo(844 - 1e-6));
        final panes = spec.isSplit
            ? [spec.leftPane!, spec.rightPane!]
            : [Offset.zero & e.value];
        for (final p in panes) {
          expect(p.width / spec.scale, greaterThanOrEqualTo(390 - 1e-6),
              reason: 'pane $p too narrow');
          expect(p.height, e.value.height);
        }
        if (spec.isSplit) {
          expect(spec.leftPane!.left, 0);
          expect(spec.rightPane!.right, closeTo(e.value.width, 1e-9));
        }
      });
    }

    test('split layouts', () {
      expect(ViewportSpec.resolve(const Size(741, 832)).isSplit, isTrue);
      expect(ViewportSpec.resolve(const Size(1180, 820)).isSplit, isTrue);
      expect(ViewportSpec.resolve(const Size(1600, 900)).isSplit, isTrue);
      expect(ViewportSpec.resolve(const Size(820, 1180)).isSplit, isFalse);
      expect(ViewportSpec.resolve(const Size(700, 900)).isSplit, isFalse);
    });

    test('splits along a hinge', () {
      const size = Size(1000, 800);
      final hinge = DisplayFeature(
        bounds: const Rect.fromLTWH(490, 0, 20, 800),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );
      final spec = ViewportSpec.resolve(size, [hinge]);
      expect(spec.leftPane, const Rect.fromLTWH(0, 0, 490, 800));
      expect(spec.rightPane, const Rect.fromLTWH(510, 0, 490, 800));
    });
  });

  testWidgets('resizing rebuilds .w widgets and keeps state', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);

    var initCount = 0;
    await tester.pumpWidget(AdaptiveViewport(
      child: MaterialApp(home: _Probe(onInit: () => initCount++)),
    ));
    expect(tester.getSize(find.byKey(const Key('box'))), const Size(390, 100));

    tester.view.physicalSize = const Size(820, 1180);
    await tester.pump();
    final spec = ViewportSpec.resolve(const Size(820, 1180));
    final box = tester.getSize(find.byKey(const Key('box')));
    expect(box.width, closeTo(390 * spec.scale, 1e-6));
    expect(box.height, closeTo(100 * spec.scale, 1e-6));

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('box'))), const Size(390, 100));
    expect(initCount, 1);
    expect(tester.takeException(), isNull);
  });

  group('PaneRoute', () {
    final navKey = GlobalKey<NavigatorState>();
    const placeholderHint = 'never shown';

    Route<dynamic> onGenerate(RouteSettings s) => PaneRoute(
          settings: s,
          builder: (context) => Scaffold(
            body: Builder(builder: (context) {
              final size = MediaQuery.sizeOf(context);
              return Column(children: [
                Text('page ${s.name}'),
                Text('size ${size.width.round()}x${size.height.round()}'),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '${s.name}+'),
                  child: Text('open from ${s.name}'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, 'feature'),
                  child: Text('feature from ${s.name}'),
                ),
              ]);
            }),
          ),
        );

    Future<void> pumpApp(WidgetTester tester, Size size,
        {bool allowSplit = true}) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      PaneNavigatorObserver.anchorRouteName = 'home';
      // feature 为例外：即使从首页打开也全屏
      PaneNavigatorObserver.fullScreenRouteNames = {'feature'};
      await tester.pumpWidget(WpyTheme(
        themeData: WpyThemeData.brightThemeList.first,
        child: AdaptiveViewport(
          allowSplit: allowSplit,
          child: MaterialApp(
            navigatorKey: navKey,
            navigatorObservers: [PaneNavigatorObserver.instance],
            onGenerateRoute: onGenerate,
            initialRoute: 'home',
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('phone: behaves like MaterialPageRoute', (tester) async {
      addTearDown(tester.view.reset);
      await pumpApp(tester, const Size(390, 844));
      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      expect(find.text('page home+'), findsOneWidget);
      // 首页被完全覆盖，不再构建
      expect(find.text('page home'), findsNothing);
      expect(find.text('size 390x844'), findsOneWidget);
      navKey.currentState!.popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
    });

    testWidgets('wide: home full width, details split to the right',
        (tester) async {
      addTearDown(tester.view.reset);
      const window = Size(1600, 900);
      await pumpApp(tester, window);
      final spec = ViewportSpec.resolve(window);
      final left = spec.leftPane!, right = spec.rightPane!;

      // 没有详情页时首页铺满窗口
      expect(find.text('size 1600x900'), findsOneWidget);
      expect(find.text(placeholderHint), findsNothing);

      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      // 两栏同时可见，各自拿到本栏尺寸
      expect(find.text('page home'), findsOneWidget);
      expect(find.text('page home+'), findsOneWidget);
      expect(find.text('size ${left.width.round()}x900'), findsOneWidget);
      expect(find.text('size ${right.width.round()}x900'), findsOneWidget);
      expect(tester.getTopLeft(find.text('page home+')).dx,
          greaterThanOrEqualTo(right.left));

      // 右栏内继续打开：叠加在右栏
      await tester.tap(find.text('open from home+'));
      await tester.pumpAndSettle();
      expect(find.text('page home++'), findsOneWidget);
      expect(find.text('page home'), findsOneWidget);
      expect(tester.getTopLeft(find.text('page home++')).dx,
          greaterThanOrEqualTo(right.left));

      // 左栏再打开详情页：替换右栏
      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      await tester.pump();
      expect(find.text('page home++'), findsNothing);
      expect(find.text('page home+'), findsOneWidget);

      // 左栏打开功能页：全屏
      await tester.tap(find.text('feature from home'));
      await tester.pumpAndSettle();
      expect(find.text('page feature'), findsOneWidget);
      expect(find.text('page home'), findsNothing);
      expect(find.text('size 1600x900'), findsOneWidget);
      navKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('page home'), findsOneWidget);
      expect(find.text('page home+'), findsOneWidget);

      // 关闭详情页：首页恢复铺满
      navKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('page home+'), findsNothing);
      expect(find.text('size 1600x900'), findsOneWidget);

      // 窗口变窄 -> 全屏，状态保留；再变宽 -> 分栏
      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('page home+'), findsOneWidget);
      expect(find.text('page home'), findsNothing);
      expect(find.text('size 390x844'), findsOneWidget);
      tester.view.physicalSize = window;
      await tester.pumpAndSettle();
      expect(find.text('page home'), findsOneWidget);
      expect(find.text('page home+'), findsOneWidget);
      navKey.currentState!.popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('narrow -> wide, then open detail: splits', (tester) async {
      addTearDown(tester.view.reset);
      await pumpApp(tester, const Size(390, 844));
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pumpAndSettle();
      expect(find.text('size 1600x900'), findsOneWidget);
      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      expect(find.text('page home'), findsOneWidget,
          reason: 'home should stay visible on the left');
      final right = ViewportSpec.resolve(const Size(1600, 900)).rightPane!;
      expect(tester.getTopLeft(find.text('page home+')).dx,
          greaterThanOrEqualTo(right.left));
      navKey.currentState!.popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
    });

    testWidgets('detail opened narrow, then window widened: splits',
        (tester) async {
      addTearDown(tester.view.reset);
      await pumpApp(tester, const Size(390, 844));
      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pumpAndSettle();
      expect(find.text('page home'), findsOneWidget);
      final right = ViewportSpec.resolve(const Size(1600, 900)).rightPane!;
      expect(tester.getTopLeft(find.text('page home+')).dx,
          greaterThanOrEqualTo(right.left));
      navKey.currentState!.popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
    });

    testWidgets('wide with parallel view disabled: always full screen',
        (tester) async {
      addTearDown(tester.view.reset);
      await pumpApp(tester, const Size(1600, 900), allowSplit: false);
      await tester.tap(find.text('open from home'));
      await tester.pumpAndSettle();
      expect(find.text('page home+'), findsOneWidget);
      expect(find.text('page home'), findsNothing);
      expect(find.text('size 1600x900'), findsOneWidget);
      navKey.currentState!.popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
    });
  });
}

class _Probe extends StatefulWidget {
  const _Probe({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    // 故意不依赖 MediaQuery，只用 .w/.h，验证尺寸变化时会被主动重建
    return Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(key: const Key('box'), width: 390.w, height: 100.h),
      ),
    );
  }
}
