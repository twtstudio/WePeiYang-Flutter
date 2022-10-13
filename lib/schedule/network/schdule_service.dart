// @dart = 2.12
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';

class ScheduleService {
  /// 是否有辅修
  static bool _hasMinor = false;

  /// 0 本科生 1 研究生
  static int _identityType = 0;

  /// 学期id
  static String _semesterId = "";

  /// 爬取课程表信息
  static void fetchCourses(
      {required OnResult<List<Course>> onResult,
      required OnFailure onFailure}) async {
    try {
      var res = await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/stdDetail.action");
      var html = res.data.toString();
      var s = html.find(r"项目：</td>(.+?)</td>");
      if (s.isEmpty) s = html;
      if (s.contains("本科")) _identityType = 0;
      // 这里不能是else if
      if (s.contains("研究")) _identityType = 1;

      // 请求dataQuery，获取学期id和辅修信息
      await _dataQuery();

      final courseList = <Course>[];

      // 获取主修课程
      final majorCourses = await _getDetailTable(false);
      courseList.addAll(majorCourses);

      if (_hasMinor) {
        await Future.delayed(Duration(seconds: 1)); // 防止过快点击
        // 获取辅修课程
        final minorCourses = await _getDetailTable(true);
        courseList.addAll(minorCourses);
        await Future.delayed(Duration(milliseconds: 500));
        // 切换为主修，防止gpa获取辅修成绩
        await _getDetailTable(false);
      }

      onResult(courseList);
    } on DioError catch (e) {
      onFailure(e);
    }
  }

  static String get _currentSemester {
    final date = DateTime.now();
    final year = date.hour;
    final month = date.month;
    if (month > 7)
      return "${year}-${year + 1} 1";
    else if (month < 2)
      return "${year - 1}-${year} 1";
    else
      return "${year - 1}-${year} 2";
  }

  static _dataQuery() async {
    // 初始化学期查询
    try {
      await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/dataQuery.action");
    } catch (_) {}
    // 查询学期
    var res;
    try {
      res = await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/dataQuery.action",
          isPost: true,
          params: {"dataType": "semesterCalendar"});
    } catch (_) {}

    // 这里最开始两次会跳转错误
    // 舍弃掉，重新开始请求
    await Future.delayed(Duration(milliseconds: 300));
    // 初始化学期查询
    await ClassesService.fetch(
        "http://classes.tju.edu.cn/eams/dataQuery.action");
    // 查询学期
    res = await ClassesService.fetch(
        "http://classes.tju.edu.cn/eams/dataQuery.action",
        isPost: true,
        params: {"dataType": "semesterCalendar"});

    final html = res.data.toString();
    final allSemester = html.findArrays(
        "id:([0-9]+),schoolYear:\"([0-9]+)-([0-9]+)\",name:\"(1|2)\"");

    for (var arr in allSemester) {
      if ("${arr[1]}-${arr[2]} ${arr[3]}" == _currentSemester) {
        _semesterId = arr[0];
        break;
      }
    }

    // 查询主辅修
    res = await ClassesService.fetch(
        "http://classes.tju.edu.cn/eams/dataQuery.action",
        isPost: true,
        params: {"entityId": ""});
    _hasMinor = res.data.toString().contains("辅修");
  }

  /// [getMinor] 是否获取辅修课表
  static Future<List<Course>> _getDetailTable(bool getMinor) async {
    final projectId = getMinor ? 2 : 1;
    var ids = "";
    // 如果是本科生
    if (_identityType == 0) {
      await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/courseTableForStd!index.action?projectId=$projectId");
      final res = await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action?projectId=$projectId");
      ids = res.data.toString().find("\"ids\",\"([^\"]+)\"");
    }
    // 如果是研究生
    else {
      final res = await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action");
      ids = res.data.toString().find("\"ids\",\"([^\"]+)\"");
    }
    // 获取课表
    final res = await ClassesService.fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!courseTable.action",
        isPost: true,
        params: {
          "ignoreHead": "1",
          "setting.kind": "std",
          "semester.id": _semesterId,
          "ids": ids
        });
    return _parseCourseHTML(res.data.toString());
  }

  /// 解析请求到的html课程数据
  static List<Course> _parseCourseHTML(String data) {
    /// 判断会话是否过期
    if (data.contains("本次会话已经被过期")) throw WpyDioError(error: "办公网绑定失效，请重新绑定");

    try {
      /// 先整理出所有的arrange对象
      List<Arrange> arrangeList = [];
      List<String> arrangeDataList = data
          .match(r'(?<=var teachers)[^]*?(?=fillTable)')
          .split("var teachers");
      arrangeDataList.forEach((item) {
        if (item.isEmpty) return; // 课程可能没有arrangeData，此时match.split后的值为['']
        var day = int.parse(item.match(r'(?<=index =)\w')) + 1;
        var unitData = item.matches(r'(?<=unitCount\+)\w*');
        var unit = [
          int.parse(unitData.first) + 1,
          int.parse(unitData.last) + 1
        ];
        var teacherData = item.match(r'(?<=actTeachers )[^]*?(?=;)');
        var teacherList = teacherData.matches(r'(?<=name:")[^]*?(?=")');

        /// 课程名称、课程星期分布的信息
        List<String> courseInfo =
            item.match(r'(?<=activity )[^]*?(?=;)').split('\"');
        var courseName = courseInfo[3];
        var weekInfo = courseInfo[9];

        var weekList = <int>[];
        for (int i = 0; i < weekInfo.length; i++) {
          if (weekInfo[i] == '1') weekList.add(i);
        }

        /// arrange和下面course的courseName都需要trim(), 因为有 "流体力学（1）\s" 这种课
        var arrange =
            Arrange.spider(courseName.trim(), day, weekList, unit, teacherList);

        /// 这里需要防止arrange重复(什么时候会重复我忘了5555)
        bool notContains = true;
        arrangeList.forEach((e) {
          if (e.toString() == arrange.toString()) notContains = false;
        });
        if (notContains) arrangeList.add(arrange);
      });

      /// 下面的[?.]和[return]是本学期没有课程时的空判断
      List<Course> courseList = [];
      List<String> trList =
          data.match(r'(?<=<tbody)[^]*?(?=</tbody>)').split("</tr><tr>");
      trList.forEach((tr) {
        if (tr.isEmpty) return;
        List<String> tdList = tr.matches(r'(?<=<td>)[^]*?(?=</td>)');
        if (tdList.isEmpty) return;
        var classId = tdList[1].match(r'(?<=>)[0-9]*');
        var courseId = tdList[2];

        /// 类似 “体育C 体育舞蹈” 这种有副标题的需要做判断
        List<String> names = tdList[3].matches(r'[^>]+(?=<)');
        var courseName = (names.length == 0)
            ? tdList[3]
            : names[0].replaceAll(RegExp(r'\s'), '') + " (${names[1]})";
        courseName = courseName.trim();

        if (tdList[4] == '') tdList[4] = '0.0';

        /// 整理其余的Course信息，并与Arrange匹配
        var credit = double.parse(tdList[4]).toStringAsFixed(1);
        var teacherList = tdList[5].split(',');
        var campus = '';
        if (tr.contains("北洋园"))
          campus = "北洋园";
        else if (tr.contains("卫津路")) campus = "卫津路";
        var weeks = tdList[6].replaceAll(RegExp(r'\s'), '');
        var roomList = tdList[8].matches(r'[\S]+');
        var roomIndex = 0;

        var course = Course.spider(courseName, classId, courseId, credit,
            campus, weeks, teacherList, []);

        arrangeList.forEach((arrange) {
          /// "体育D\s(体适能)"这门课，course中的名称为"体育D\s(体适能)"，arrange中的名称为"体育D"
          /// 不能用courseName.contains(arrange.courseName)来判断，否则就会把"机器学习"和"机器学习综合实践"这样的课算在一起
          if (courseName != arrange.name &&
              !_judgeSubtitle(courseName, arrange.name!)) return;

          /// 有些个别课没有教室信息，此时roomList.length = 2
          if (roomList.length > roomIndex) {
            arrange.location = roomList[roomIndex].replaceAll("<br/>", '');
            roomIndex += 2; // step为2用来跳过roomList匹配到的 “<br/>”
          }

          /// 补全当前arrange老师的职称
          for (int i = 0; i < arrange.teacherList.length; i++) {
            teacherList.forEach((t) {
              if (t.contains(arrange.teacherList[i])) {
                arrange.teacherList[i] = t;
              }
            });
          }

          course.arrangeList.add(arrange);
        });
        courseList.add(course);
      });
      return courseList;
    } catch (e) {
      throw WpyDioError(error: '解析课程数据出错，请重新尝试');
    }
  }

  /// 判断s1的格式是否为 "${s2} ${某subtitle}"
  static bool _judgeSubtitle(String s1, String s2) {
    var titles = s1.split(' ');
    return titles.length > 1 ? titles[0] == s2 : false;
  }

  /// 爬取考表信息
  static void fetchExam(
      {required OnResult<List<Exam>> onResult,
      required OnFailure onFailure}) async {
    try {
      var response = await ClassesService.fetch(
          "http://classes.tju.edu.cn/eams/stdExamTable!examTable.action");
      var exams = <Exam>[];
      String tbody =
          response.data.toString().match(r'(?<=<tbody)[^]*?(?=</tbody>)');
      if (!tbody.contains('<td>')) {
        onResult([]);
        return;
      }
      List<String> trList = tbody.split("</tr><tr>");
      trList.forEach((tr) {
        List<String> tdList = tr.matches(r'(?<=<td>)[^]*?(?=</td>)');
        tdList = tdList
            .map((e) =>
                e.contains('color') ? e.match(r'(?<=>)[^]*?(?=</font)') : e)
            .toList();
        var ext = tdList[8] == '正常' ? '' : tdList[9];
        exams.add(Exam(tdList[0], tdList[1], tdList[2], tdList[3], tdList[5],
            tdList[6], tdList[7], tdList[8], ext));
      });
      onResult(exams);
    } catch (e) {
      onFailure(e is DioError ? e : WpyDioError(error: '解析考表数据出错，请重新尝试'));
    }
  }
}
