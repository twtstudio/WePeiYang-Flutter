import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_model.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

/// 调试用模拟数据：`flutter run --dart-define=MOCK_DATA=true`
///
/// 进入首页后填充 GPA、考表和课表（每天每周都有课，保证"今日课程"有内容），
/// 方便在没有真实数据的账号上查看首页各种布局。只在 debug 构建中生效，
/// 数据只保存在内存中，不会写入本地缓存或修改设置。
const bool kMockData = kDebugMode && bool.fromEnvironment('MOCK_DATA');

void injectMockData(BuildContext context) {
  if (!kMockData) return;

  GPACourse course(String term, String name, double score, double credit,
          double gpa) =>
      GPACourse(term, name, '必修', score, '$score', credit, gpa);
  const terms = ['1H23', '2H23', '1H24', '2H24', '1H25', '2H25'];
  const weighted = [84.2, 86.5, 88.1, 85.7, 89.3, 90.6];
  const gpas = [3.42, 3.55, 3.71, 3.50, 3.78, 3.86];
  context.read<GPANotifier>()
    ..total = Total(87.4, 3.64, 133.5)
    ..gpaStats = [
      for (var i = 0; i < terms.length; i++)
        GPAStat(terms[i], weighted[i], gpas[i], 20.5 + i, [
          course(terms[i], '高等数学', 92, 6, 4.0),
          course(terms[i], '大学物理', 85, 4, 3.5),
          course(terms[i], '程序设计基础', 95, 3.5, 4.0),
          course(terms[i], '线性代数', 78, 3, 2.8),
          course(terms[i], '中国近现代史纲要', 88, 2, 3.7),
        ]),
    ]
    ..debugShowGPA();

  String dayAfter(int days) => DateTime.now()
      .add(Duration(days: days))
      .toIso8601String()
      .substring(0, 10);
  context.read<ExamProvider>().exams = [
    Exam('1', '高等数学A（2）', '期末', dayAfter(3), '08:30-10:30', '33楼 101', '12',
        '', ''),
    Exam('2', '大学物理', '期末', dayAfter(7), '14:00-16:00', '46楼 A205', '33',
        '', ''),
    Exam('3', '数据结构', '期中', dayAfter(12), '10:00-12:00', '55楼 B306', '7',
        '', ''),
    Exam('4', '体育', '考查', '时间未安排', '', '', '', '', ''),
  ];

  const names = ['高等数学', '大学物理', '数据结构', '马克思主义原理', '大学英语'];
  const rooms = ['33楼 101', '46楼 A205', '55楼 B306', '45楼 202', '44楼 311'];
  final weeks = [for (var w = 1; w <= 24; w++) w];
  context.read<CourseProvider>().debugSetSchoolCourses([
    for (var k = 0; k < names.length; k++)
      Course.spider(names[k], '$k', 'MOCK$k', '3', '北洋园', '1-24', ['张老师'], [
        for (var day = 1; day <= 7; day++)
          Arrange(
            name: names[k],
            location: rooms[k],
            weekday: day,
            weekList: weeks,
            unitList: [k * 2 + 1, k * 2 + 2],
            teacherList: ['张老师'],
            showMode: 0,
            isExperiment: false,
          ),
      ]),
  ]);
}
