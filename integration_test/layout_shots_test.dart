// 临时的大屏布局截图脚本（Linux 桌面 + niri，原生 Wayland），验证后删除。
// 运行：flutter test integration_test/layout_shots_test.dart -d linux --dart-define=SHOT_DIR=/path
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_model.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart' as app;
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

const shotDir = String.fromEnvironment('SHOT_DIR');
const widthsArg = String.fromEnvironment('WIDTHS', defaultValue: '260,700,847,1650');
const onlyHome = bool.fromEnvironment('ONLY_HOME');
const onlyLake = bool.fromEnvironment('ONLY_LAKE');
final widths = widthsArg.split(',').map(int.parse).toList();

final errors = <String>[];

Future<void> settle(WidgetTester t, [int ms = 1200]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<int?> niriWindowId() async {
  final r = await Process.run('niri', ['msg', '-j', 'windows']);
  for (final w in jsonDecode(r.stdout as String) as List) {
    if (w['app_id'] == 'com.twt.we_pei_yang_flutter') return w['id'] as int;
  }
  return null;
}

Future<void> setWidth(WidgetTester t, int width) async {
  final id = await niriWindowId();
  if (id == null) return;
  await Process.run(
      'niri', ['msg', 'action', 'set-window-width', '--id', '$id', '$width']);
  await settle(t, 1500);
}

Future<void> capture(WidgetTester t, String file) async {
  final rv = t.binding.renderViews.first;
  final layer = rv.debugLayer! as OffsetLayer;
  final img = await layer.toImage(Offset.zero & rv.flutterView.physicalSize);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  await File(file).writeAsBytes(bytes!.buffer.asUint8List());
}

Future<void> shot(WidgetTester t, String name, {List<int>? at}) async {
  for (final w in at ?? widths) {
    await setWidth(t, w);
    final ex = t.takeException();
    if (ex != null) errors.add('$name@$w: $ex');
    await capture(t, '$shotDir/$name-$w.png');
  }
}

/// 模拟数据：GPA、考试、课程（每天每周都有课，保证"今日课程"有内容）
void injectMockData(BuildContext ctx) {
  GPACourse c(String sem, String n, double score, double credit, double gpa) =>
      GPACourse(sem, n, '必修', score, '$score', credit, gpa);
  final terms = ['1H23', '2H23', '1H24', '2H24', '1H25', '2H25'];
  final weighted = [84.2, 86.5, 88.1, 85.7, 89.3, 90.6];
  final gpas = [3.42, 3.55, 3.71, 3.50, 3.78, 3.86];
  final gpa = ctx.read<GPANotifier>();
  gpa.hideGPA = false;
  gpa.total = Total(87.4, 3.64, 133.5);
  gpa.gpaStats = [
    for (var i = 0; i < terms.length; i++)
      GPAStat(terms[i], weighted[i], gpas[i], 20.5 + i, [
        c(terms[i], '高等数学', 92, 6, 4.0),
        c(terms[i], '大学物理', 85, 4, 3.5),
        c(terms[i], '程序设计基础', 95, 3.5, 4.0),
        c(terms[i], '线性代数', 78, 3, 2.8),
        c(terms[i], '中国近现代史纲要', 88, 2, 3.7),
      ]),
  ];
  String day(int d) =>
      DateTime.now().add(Duration(days: d)).toIso8601String().substring(0, 10);
  ctx.read<ExamProvider>().exams = [
    Exam('1', '高等数学A（2）', '期末', day(3), '08:30-10:30', '33楼 101', '12', '', ''),
    Exam('2', '大学物理', '期末', day(7), '14:00-16:00', '46楼 A205', '33', '', ''),
    Exam('3', '数据结构', '期中', day(12), '10:00-12:00', '55楼 B306', '7', '', ''),
    Exam('4', '体育', '考查', '时间未安排', '', '', '', '', ''),
  ];
  final names = ['高等数学', '大学物理', '数据结构', '马克思主义原理', '大学英语'];
  final rooms = ['33楼 101', '46楼 A205', '55楼 B306', '45楼 202', '44楼 311'];
  final weeks = [for (var w = 1; w <= 24; w++) w];
  ctx.read<CourseProvider>().updateSchoolCourses([
    for (var k = 0; k < names.length; k++)
      Course.spider(names[k], '$k', 'C00$k', '3', '北洋园', '1-24', ['张老师'], [
        for (var d = 1; d <= 7; d++)
          Arrange(
              name: names[k],
              location: rooms[k],
              weekday: d,
              weekList: weeks,
              unitList: [k * 2 + 1, k * 2 + 2],
              teacherList: ['张老师'],
              showMode: 0,
              isExperiment: false),
      ]),
  ]);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('layout shots', (t) async {
    app.main();
    for (var i = 0; i < 150; i++) {
      await t.pump(const Duration(milliseconds: 200));
      if (find.byKey(const ValueKey('_HomeTabId.home-true')).evaluate().isNotEmpty ||
          find.byKey(const ValueKey('nav-home')).evaluate().isNotEmpty) break;
    }
    await settle(t, 5000);
    // 关掉首页可能弹出的活动弹窗
    final nav = t.state<NavigatorState>(find.byType(Navigator).first);
    nav.popUntil((r) => r.settings.name == 'home/home');
    await settle(t, 800);

    Future<void> tab(String id) async {
      final f = find.byWidgetPredicate((w) =>
          w.key is ValueKey &&
          (w.key as ValueKey).value.toString().startsWith('_HomeTabId.$id-'));
      if (f.evaluate().isEmpty) {
        errors.add('tab $id not found');
        return;
      }
      await t.tap(f.first);
      await settle(t, 2500);
    }

    if (onlyLake) {
      await tab('feedback');
      await settle(t, 4000);
      await shot(t, '02-lake');
      final cards = find.byType(PostCardNormal);
      if (cards.evaluate().isNotEmpty) {
        await t.tap(cards.first, warnIfMissed: false);
        await settle(t, 3000);
        await shot(t, '03-post', at: [widths.last]);
      }
      await setWidth(t, 847);
      return;
    }
    if (onlyHome) {
      // 由 app 自身的 MOCK_DATA 开关注入（进入首页 3 秒后）
      await settle(t, 4000);
    }
    await shot(t, '01-home');
    if (onlyHome) {
      // 首页：切到 GPA / 考表标签再截一次
      // 鼠标滚轮：在自习室网格上滚动，应先滚动整页再滚动网格
      for (final w in [847, 260]) {
        await setWidth(t, w);
        // 自习室网格（课程卡片也是 GridView，按楼名定位）
        final grid = find.ancestor(
            of: find.text('47楼'), matching: find.byType(GridView));
        final rect = t.getRect(grid.first);
        final at = Offset(rect.center.dx, rect.top + 40);
        for (var i = 0; i < 6; i++) {
          await t.sendEventToBinding(PointerScrollEvent(
              position: at, scrollDelta: const Offset(0, 120),
              kind: PointerDeviceKind.mouse));
          await t.pump(const Duration(milliseconds: 100));
        }
        await settle(t, 600);
        await capture(t, '$shotDir/01c-home-wheel-$w.png');
        for (final e in find.byType(Scrollable).evaluate()) {
          final st = (e as StatefulElement).state as ScrollableState;
          final p = st.position;
          if (p.axis != Axis.vertical) continue;
          final box = e.renderObject as RenderBox?;
          debugPrint('SCROLLDBG $w ${st.widget.physics.runtimeType} ctrl=${st.widget.controller.hashCode} '
              'pix=${p.pixels.toStringAsFixed(1)} max=${p.hasContentDimensions ? p.maxScrollExtent.toStringAsFixed(1) : '-'} '
              'vp=${p.hasViewportDimension ? p.viewportDimension.toStringAsFixed(1) : '-'} at=${box?.localToGlobal(Offset.zero)} size=${box?.size}');
        }
        // 触摸拖动回到顶部，再向上拖动一段
        await t.dragFrom(at, const Offset(0, 900));
        await settle(t, 600);
        await t.dragFrom(at, const Offset(0, -260));
        await settle(t, 600);
        await capture(t, '$shotDir/01d-home-drag-$w.png');
        // 在课程区域拖动回到顶部
        await t.dragFrom(Offset(at.dx, 200), const Offset(0, 800));
        await settle(t, 800);
      }
      for (final tab in [1, 2]) {
        await setWidth(t, 847);
        final bar = find.ancestor(
            of: find.text('GPA Curves'), matching: find.byType(TabBar));
        if (bar.evaluate().isEmpty) break;
        t.widget<TabBar>(bar.first).controller!.animateTo(tab);
        await settle(t, 1500);
        await shot(t, '01b-home-tab$tab', at: [260, 847]);
      }
      await setWidth(t, 847);
      File('$shotDir/errors.txt').writeAsStringSync(errors.join('\n'));
      return;
    }
    await tab('feedback');
    await settle(t, 3000);
    await shot(t, '02-lake');

    Future<bool> openPost() async {
      final cards = find.byType(PostCardNormal);
      if (cards.evaluate().isEmpty) {
        errors.add('no post card');
        return false;
      }
      await t.tap(cards.first, warnIfMissed: false);
      await settle(t, 3000);
      return true;
    }

    if (await openPost()) {
      await shot(t, '03-post');
      nav.popUntil((r) => r.settings.name == 'home/home');
      await settle(t, 1000);
    }

    // 设置里切换平行视界
    Future<void> toggleParallel(String name) async {
      nav.pushNamed('setting/general_setting');
      await settle(t, 2000);
      final label = find.text('平行视界');
      await t.scrollUntilVisible(label, 200,
          scrollable: find.byType(Scrollable).first);
      final row = find.ancestor(of: label, matching: find.byType(Row)).first;
      await t.tap(find.descendant(of: row, matching: find.byType(Switch)));
      await settle(t, 800);
      await shot(t, name, at: [1650]);
      nav.popUntil((r) => r.settings.name == 'home/home');
      await settle(t, 1000);
    }

    await setWidth(t, 1650);
    await toggleParallel('10-setting-off');
    if (await openPost()) await shot(t, '11-post-parallel-off', at: [1650]);
    nav.popUntil((r) => r.settings.name == 'home/home');
    await settle(t, 1000);
    await toggleParallel('12-setting-on');
    if (await openPost()) await shot(t, '13-post-parallel-on', at: [1650, 847]);
    nav.popUntil((r) => r.settings.name == 'home/home');
    await settle(t, 1000);

    await tab('ai');
    await shot(t, '04-ai', at: [260, 1650]);
    await tab('profile');
    await settle(t, 2000);
    await shot(t, '05-profile');
    await tab('home');

    for (final r in [
      ['schedule/course', '06-schedule'],
      ['gpa/home', '07-gpa'],
      ['setting/home', '09-settings'],
    ]) {
      nav.pushNamed(r[0]);
      await settle(t, 3000);
      await shot(t, r[1], at: [260, 847, 1650]);
      nav.popUntil((r) => r.settings.name == 'home/home');
      await settle(t, 1000);
    }

    await setWidth(t, 847);
    File('$shotDir/errors.txt').writeAsStringSync(errors.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 15)));
}
