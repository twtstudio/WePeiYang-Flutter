import 'dart:convert';

import 'course.dart';

String scheduleDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime scheduleDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

class ScheduleDayOverride {
  final DateTime? sourceDate;

  const ScheduleDayOverride.off() : sourceDate = null;
  ScheduleDayOverride.replace(DateTime date) : sourceDate = scheduleDate(date);

  bool get isOff => sourceDate == null;

  Map<String, dynamic> toJson() => isOff
      ? {'type': 'off'}
      : {'type': 'replace', 'sourceDate': scheduleDateKey(sourceDate!)};
}

/// 日期规则只影响展示，原始学校课程和自定义课程不被改写。
class ScheduleDayRules {
  final DateTime firstDay;
  final int weekCount;
  final Map<String, ScheduleDayOverride> days;

  ScheduleDayRules(DateTime termStart, this.weekCount,
      [Map<String, ScheduleDayOverride>? days])
      : firstDay = DateTime(termStart.year, termStart.month,
            termStart.day - termStart.weekday + 1),
        days = Map.of(days ?? {});

  DateTime get lastDay => dateFor(weekCount, 7);

  DateTime dateFor(int week, int weekday) => DateTime(firstDay.year,
      firstDay.month, firstDay.day + (week - 1) * 7 + weekday - 1);

  // 按日历日期计算，避免夏令时导致一天不是 24 小时。
  int weekOf(DateTime date) =>
      (DateTime.utc(date.year, date.month, date.day)
                  .difference(
                      DateTime.utc(firstDay.year, firstDay.month, firstDay.day))
                  .inDays /
              7)
          .floor() +
      1;

  bool contains(DateTime date) =>
      weekOf(date) >= 1 && weekOf(date) <= weekCount;

  ScheduleDayOverride? ruleFor(DateTime date) => days[scheduleDateKey(date)];

  /// 过期学期、其他账号或无效数据不生效。
  static ScheduleDayRules restore(String raw, DateTime termStart, int weekCount,
      String term, String account) {
    final rules = ScheduleDayRules(termStart, weekCount);
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map ||
          decoded['term'] != term ||
          decoded['account'] != account ||
          decoded['termStart'] != scheduleDateKey(rules.firstDay) ||
          decoded['days'] is! Map) return rules;
      for (final entry in (decoded['days'] as Map).entries) {
        final target = DateTime.tryParse(entry.key.toString());
        final value = entry.value;
        if (target == null ||
            !rules.contains(target) ||
            scheduleDateKey(target) != entry.key ||
            value is! Map) continue;
        if (value['type'] == 'off') {
          rules.days[entry.key] = const ScheduleDayOverride.off();
        } else if (value['type'] == 'replace') {
          final source = DateTime.tryParse(value['sourceDate'].toString());
          if (source != null &&
              rules.contains(source) &&
              scheduleDateKey(source) == value['sourceDate'] &&
              source != target) {
            rules.days[entry.key] = ScheduleDayOverride.replace(source);
          }
        }
      }
    } catch (_) {
      // 损坏配置回退为原课表。
    }
    return rules;
  }

  String encode(String term, String account) => jsonEncode({
        'term': term,
        'account': account,
        'termStart': scheduleDateKey(firstDay),
        'days': days.map((key, value) => MapEntry(key, value.toJson())),
      });

  bool hasOriginalCourses(DateTime date, List<Course> courses) =>
      contains(date) &&
      courses.any((course) => course.arrangeList.any((a) =>
          a.weekday == date.weekday && a.weekList.contains(weekOf(date))));

  List<Course> schoolCoursesForWeek(int week, List<Course> courses) {
    if (week < 1 || week > weekCount) return [];
    final result = <Course>[];
    for (final course in courses) {
      final arrangements = <Arrange>[];
      for (var day = 1; day <= 7; day++) {
        final target = dateFor(week, day);
        final rule = ruleFor(target);
        if (rule?.isOff == true) continue;
        // 只查来源日的原课表，不递归应用来源日的调整。
        final source = rule?.sourceDate ?? target;
        for (final arrange in course.arrangeList) {
          if (arrange.weekday != source.weekday ||
              !arrange.weekList.contains(weekOf(source))) continue;
          arrangements.add(arrange.copyWith(
            weekday: day,
              weekList: rule == null ? List.of(arrange.weekList) : [week],
            unitList: List.of(arrange.unitList),
            teacherList: List.of(arrange.teacherList),
            showMode: 0,
          )..sourceDate = rule?.sourceDate);
        }
      }
      if (arrangements.isNotEmpty) {
        result
            .add(Course.fromJson(course.toJson())..arrangeList = arrangements);
      }
    }
    return result;
  }
}
