// @dart = 2.12
import 'package:dio/dio.dart' show DioError;
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/spider_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';

/// 爬取课程表信息
void fetchCourses(
    {required OnResult<List<Course>> onResult,
    required OnFailure onFailure}) async {
  try {
    /// 学生没有辅修的情况：
    if (CommonPreferences.ids.value != "useless") {
      var courses = await _fetchSingleTypeCourses(CommonPreferences.ids.value);
      onResult(courses);
      return;
    }

    /// 学生有辅修的情况：
    var courseList = <Course>[];

    /// 先获取semester.id
    var semesterRsp = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: CommonPreferences.cookies,
        params: {'projectId': '1'});
    semesterRsp.headers.map['set-cookie']!.forEach((string) {
      if (string.contains('semester'))
        CommonPreferences.semesterId.value = string.match(r'semester.id=\w+');
    });

    /// 获取主修课程
    var mainIds = await _fetchSingleTypeIds('1');
    var mainCourses = await _fetchSingleTypeCourses(mainIds);
    courseList.addAll(mainCourses);

    await Future.delayed(Duration(seconds: 1)); // 防止过快点击

    /// 获取辅修课程
    var subIds = await _fetchSingleTypeIds('2');
    var subCourses = await _fetchSingleTypeCourses(subIds);
    courseList.addAll(subCourses);

    onResult(courseList);
  } on DioError catch (e) {
    onFailure(e);
  }
}

/// 获取主修 / 辅修的ids
/// * projectId: 1 -> 主修；2 -> 辅修
Future<String> _fetchSingleTypeIds(String projectId) async {
  /// 先切换至该分类
  await fetch("http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
      cookieList: CommonPreferences.cookies, params: {'projectId': projectId});

  /// 获取该分类的ids
  var response = await fetch(
      "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
      cookieList: CommonPreferences.cookies,
      params: {
        'projectId': projectId,
        '_': DateTime.now().millisecondsSinceEpoch
      });
  return response.data.toString().match(r'(?<=ids",")\w*');
}

/// 获取主修 / 辅修的课程数据
/// * 如果学生只有主修，[ids]应从缓存中读取
/// * 如果学生还有辅修，则需要分别给出[ids]，缓存中的ids无用
Future<List<Course>> _fetchSingleTypeCourses(String ids) async {
  var map = {
    "ignoreHead": "1",
    "setting.kind": "std",
    "startWeek": "",
    "semester.id": CommonPreferences.semesterId.value.match(r'[0-9]+'),
    "ids": ids
  };
  var response = await fetch(
      "http://classes.tju.edu.cn/eams/courseTableForStd!courseTable.action",
      cookieList: CommonPreferences.cookies,
      isPost: true,
      params: map);
  return _parseCourseHTML(response.data.toString());
}

/// 解析请求到的html课程数据
List<Course> _parseCourseHTML(String data) {
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
      var unit = [int.parse(unitData.first) + 1, int.parse(unitData.last) + 1];
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

      var course = Course.spider(courseName, classId, courseId, credit, campus,
          weeks, teacherList, []);

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
bool _judgeSubtitle(String s1, String s2) {
  var titles = s1.split(' ');
  return titles.length > 1 ? titles[0] == s2 : false;
}

/// 爬取考表信息
void fetchExam(
    {required OnResult<List<Exam>> onResult,
    required OnFailure onFailure}) async {
  try {
    var response = await fetch(
        "http://classes.tju.edu.cn/eams/stdExamTable!examTable.action",
        cookieList: CommonPreferences.cookies);
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
