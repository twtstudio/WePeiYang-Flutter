import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miui_long_screenshot/miui_long_screenshot.dart';

Widget scrollTargets(String label) => Scaffold(
      body: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: MiuiLongScreenshot(
                child: ListView(
                  children: [
                    for (var row = 0; row < 30; row++)
                      SizedBox(height: 60, child: Text('$label-$i-$row')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('miui_long_screenshot'), (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('miui_long_screenshot'), null);
  });

  testWidgets('notification replaces forum then returns without layout errors',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: scrollTargets('old-forum'),
    ));
    await tester.pumpAndSettle();

    navigator.currentState!.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => scrollTargets('new-forum')),
      (_) => false,
    );
    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => scrollTargets('post')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('new-forum-0-0'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('reparented scroll target remains usable after reactivation',
      (tester) async {
    final key = GlobalKey();
    final controller = ScrollController();
    var onRight = false;
    late StateSetter update;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (_, setState) {
        update = setState;
        final target = MiuiLongScreenshot(
          key: key,
          controller: controller,
          child: ListView(
            controller: controller,
            children: [
              for (var i = 0; i < 30; i++)
                SizedBox(height: 60, child: Text('item-$i')),
            ],
          ),
        );
        return Scaffold(
          body: Row(children: [
            Expanded(child: onRight ? const SizedBox() : target),
            Expanded(child: onRight ? target : const SizedBox()),
          ]),
        );
      }),
    ));
    await tester.pumpAndSettle();
    update(() => onRight = true);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
    controller.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
