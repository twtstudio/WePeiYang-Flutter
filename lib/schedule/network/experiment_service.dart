import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

enum ExperimentKeys {
  ClassId,
  CourseCode,
  CourseName,
  ExperimentName,
  GroupId,
  ExperimentCenter,
  Labs,
  Teacher,
  Time,
}

extension on ExperimentKeys {
  static final keyMaps = {
    ExperimentKeys.ClassId: 1,
    ExperimentKeys.CourseCode: 2,
    ExperimentKeys.CourseName: 3,
    ExperimentKeys.ExperimentName: 5,
    ExperimentKeys.GroupId: 6,
    ExperimentKeys.ExperimentCenter: 7,
    ExperimentKeys.Labs: 9,
    ExperimentKeys.Teacher: 10,
    ExperimentKeys.Time: 18,
  };

  int get item => keyMaps[this]!;
}

class Experiment {
  final String classId;
  final String courseCode;
  final String courseName;
  final String experimentName;
  final String groupId;
  final String experimentCenter;
  final String labs;
  final String teacher;
  final String time;

  Experiment(
      {required this.classId,
      required this.courseCode,
      required this.courseName,
      required this.experimentName,
      required this.groupId,
      required this.experimentCenter,
      required this.labs,
      required this.teacher,
      required this.time});

  static String removeCommonSubstrings(String a, String b) {
    int maxLength = b.length;
    // 从最长可能的子串长度开始尝试，直到长度为1
    for (int length = maxLength; length > 0; length--) {
      for (int start = 0; start <= b.length - length; start++) {
        String substr = b.substring(start, start + length);
        // 检查子串是否存在于a中，并删除所有出现
        while (a.contains(substr)) {
          a = a.replaceFirst(substr, "");
        }
      }
    }
    return a;
  }

  factory Experiment.fromRawData(List<String> raw) {
    return Experiment(
      classId: raw[ExperimentKeys.ClassId.item],
      courseCode: raw[ExperimentKeys.CourseCode.item],
      courseName: raw[ExperimentKeys.CourseName.item],
      experimentName: raw[ExperimentKeys.ExperimentName.item],
      groupId: raw[ExperimentKeys.GroupId.item],
      experimentCenter: raw[ExperimentKeys.ExperimentCenter.item],
      labs: removeCommonSubstrings(
        raw[ExperimentKeys.Labs.item],
        raw[ExperimentKeys.ExperimentName.item],
      ),
      // 删除教室部分的试验名称标注[没必要标注名称]
      teacher: raw[ExperimentKeys.Teacher.item],
      time: raw[ExperimentKeys.Time.item],
    );
  }

  @override
  String toString() {
    return 'Experiment{classId: $classId, courseCode: $courseCode, courseName: $courseName, experimentName: $experimentName, groupId: $groupId, experimentCenter: $experimentCenter, labs: $labs, teacher: $teacher, time: $time}';
  }
}

class ExperimentService {
  static final _requestTarget =
      "http://classes.tju.edu.cn/eams/exp/std-elect-lesson-item!electedList.action";

  static final _searchTarget =
      "http://classes.tju.edu.cn/eams/exp/std-elect-lesson-item!search.action";

  static Future<void> refreshExperiment(CourseProvider courseProvider) async {
    final expList = await _getExperimentRawData();
    var courseList = courseProvider.schoolCourses;

    courseProvider.updateSchoolCourses(
      _mergeExperimentCourse(courseList, expList),
    );
  }

  static List<Course> _mergeExperimentCourse(
      List<Course> courseList, List<Experiment> expList) {
    Set<String> classIdSet = {};
    for (var exp in expList) {
      classIdSet.add(exp.classId);
    }
    print("$classIdSet");
    for (var i = 0; i < courseList.length; i++) {
      var course = courseList[i];
      if (classIdSet.contains(course.classId)) {
        Arrange arrangeTemplate = course.arrangeList[0];
        for (var exp in expList) {
          Arrange arrange = arrangeTemplate.copyWith(
            isExperiment: true,
            name: exp.experimentName,
            location: exp.labs,
            weekList: [parseWeek(exp.time)],
            teacherList: [exp.teacher],
          );

          // 删除对应的站位课程
          courseList[i].arrangeList[0].weekList.remove(parseWeek(exp.time));
          courseList[i].arrangeList.add(arrange);
        }
      }
    }

    return courseList;
  }

  static int parseWeek(String time) {
    RegExp regExp = RegExp(r'第(\d+)周');
    var match = regExp.firstMatch(time);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  static Future<List<Experiment>> _getExperimentRawData() async {
    await ClassesService.spiderDio.get(_searchTarget);
    final rawResult = (await ClassesService.spiderDio.get(_requestTarget)).data;
    RegExp regExp = RegExp(r'<table[^>]*>[\s\S]*?<\/table>');
    String expTable = regExp
        .allMatches(rawResult)
        .firstOrNull!
        .group(0)!; // must exist, orElse throw exception automatically
    regExp = RegExp(r'<tr[^>]*>[\s\S]*?</tr>');
    final table = regExp.allMatches(expTable);
    RegExp headerReg = RegExp(r'<th[^>]*>[\s\S]*?</th>');

    List<Experiment> expList = [];
    for (var row in table) {
      String rawRow = row.group(0)!;
      // 跳过表头
      if (headerReg.hasMatch(rawRow)) continue;

      RegExp itemReg = RegExp(r'<td[^>]*>[\s\S]*?</td>');
      RegExp formatReg = RegExp(r'<[^>]*>|&nbsp;|\s+|（新）');

      final items = itemReg
          .allMatches(rawRow) // 匹配每一行
          .map((e) => e.group(0)!.replaceAll(formatReg, "")) // 删除空格和html标签
          .toList();

      expList.add(Experiment.fromRawData(items));
    }
    return expList;
  }
}
/*
* <td class="gridselect">
<input class="box" name="lessonItem.id" value="93776" type="checkbox"></td>
* <td>03356</td>
* <td>2100347</td>
* <td>物理实验B</td>
* <td>2100347003</td><td>铁磁材料的磁滞回线（新）</td><td>132</td><td>物理实验中心</td>        <td>是</td>
<td>205铁磁材料的磁滞回线</td><td>            冯星辉
</td><td>2</td><td>15</td><td>自选</td><td>基础</td><td>验证性</td><td>选修</td><td>3</td><td>            第8周 星期二 第5-7节 (2024-04-23)
</td><td>            自选
</td><td>                    <a href="/eams/exp/std-elect-lesson-item!withdraw.action?lessonItem.id=93776" onclick="return bg.Go(this,null)">退课</a>
</td>
* */
