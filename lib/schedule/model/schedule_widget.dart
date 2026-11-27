import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/platform/ohos.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';

import '../extension/logic_extension.dart';
import 'course.dart';
import 'course_provider.dart';
import 'schedule_day_rules.dart';

const _channel = MethodChannel('com.twt.service/widget');

Future<void> syncOhosScheduleWidget(CourseProvider provider) async {
  if (!isOhos) return;
  if (!CommonPreferences.isLogin.value || !CommonPreferences.isBindTju.value) {
    await clearOhosScheduleWidget();
    return;
  }
  // 由 Dart 统一应用调课规则，桌面卡片可在应用退出后按日期读取快照。
  final rules = provider.dayRules;
  final days = <String, List<Map<String, String>>>{};
  for (var week = 1; week <= rules.weekCount; week++) {
    for (var weekday = 1; weekday <= 7; weekday++) {
      final date = rules.dateFor(week, weekday);
      final courses = <Map<String, String>>[];
      for (final entry in provider.coursesForDate(date)) {
        final arrange = entry.arrange;
        final units = arrange.unitList;
        if (units.isEmpty ||
            units.first < 1 ||
            units.last < units.first ||
            units.last > 12) continue;
        courses.add({
          'name':
              arrange.isExperiment && CommonPreferences.isShowExperiment.value
                  ? '[实验] ${arrange.name ?? entry.first.name}'
                  : entry.first.name,
          'location': arrange.location,
          'time': getCourseTime(units),
        });
      }
      if (courses.isNotEmpty) {
        courses.sort((a, b) => a['time']!.compareTo(b['time']!));
        days[scheduleDateKey(date)] = courses;
      }
    }
  }
  await _publishSnapshot(jsonEncode({
    'nightMode': CommonPreferences.nightMode.value,
    'days': days,
  }));
}

Future<void> clearOhosScheduleWidget() async {
  if (isOhos) await _publishSnapshot('');
}

Future<void> _publishSnapshot(String snapshot) async {
  try {
    await _channel.invokeMethod<void>('refreshScheduleWidget', {
      'snapshot': snapshot,
    });
  } catch (error, stack) {
    Log.e(error, stack, 'schedule');
  }
}
