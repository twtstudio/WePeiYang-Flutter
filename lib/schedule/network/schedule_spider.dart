import 'package:dio/dio.dart' show DioError, Response;
import 'package:we_pei_yang_flutter/commons/network/spider_service.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/school_model.dart';

/// 爬取课程表信息
void getScheduleCourses(
    {OnResult<List<ScheduleCourse>> onResult, OnFailure onFailure}) async {
  var pref = CommonPreferences();

  try {
    /// 学生没有辅修的情况：
    if (pref.ids.value != "useless") {
      var response = await getDetailSchedule(pref.ids.value);
      onResult(_data2ScheduleCourses(response.data.toString()));
      return;
    }

    /// 学生有辅修的情况：
    var scheduleList = <ScheduleCourse>[];
    var idsValue = '';

    /// 获取semester.id
    var semesterRsp = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: pref.getCookies(),
        params: {'projectId': '1'});
    semesterRsp.headers.map['set-cookie'].forEach((string) {
      if (string.contains('semester'))
        pref.semesterId.value = getRegExpStr(r'semester.id=\w+', string);
    });

    /// 切换至主修
    await fetch("http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
        cookieList: pref.getCookies(), params: {'projectId': '1'});

    /// 获取主修的ids
    var idsRsp1 = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: pref.getCookies(),
        params: {'projectId': '1', '_': DateTime.now().millisecondsSinceEpoch});
    idsValue = getRegExpStr(r'(?<=ids",")\w*', idsRsp1.data.toString());

    /// 获取主修课程
    var courseRsp1 = await getDetailSchedule(idsValue);
    scheduleList.addAll(_data2ScheduleCourses(courseRsp1.data.toString()));

    await Future.delayed(Duration(seconds: 1)); // 防止过快点击

    /// 切换至辅修
    await fetch("http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
        cookieList: pref.getCookies(), params: {'projectId': '2'});

    /// 获取辅修的ids
    var idsRsp2 = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: pref.getCookies(),
        params: {'projectId': '2'});
    idsValue = getRegExpStr(r'(?<=ids",")\w*', idsRsp2.data.toString());

    /// 获取辅修课程
    var courseRsp2 = await getDetailSchedule(idsValue);
    scheduleList.addAll(_data2ScheduleCourses(courseRsp2.data.toString()));
    onResult(scheduleList);
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 获取主修 / 重修的课程数据
/// * 如果学生只有主修，[ids]应从缓存中读取
/// * 如果学生还有重修，则需要分别给出[ids]，缓存中的ids无用
Future<Response> getDetailSchedule(String ids) {
  var pref = CommonPreferences();
  var map = {
    "ignoreHead": "1",
    "setting.kind": "std",
    "startWeek": "",
    "semester.id": getRegExpStr(r'[0-9]+', pref.semesterId.value),
    "ids": ids
  };
  return fetch(
      "http://classes.tju.edu.cn/eams/courseTableForStd!courseTable.action",
      cookieList: pref.getCookies(),
      isPost: true,
      params: map);
}

/// 用请求到的html数据生成schedule对象
List<ScheduleCourse> _data2ScheduleCourses(String data) {
  /// 判断会话是否过期
  if (data.contains("本次会话已经被过期")) throw WpyDioError(error: "办公网绑定失效，请重新绑定");

  try {
    /// 先整理出所有的arrange对象
    List<Arrange> arrangeList = [];
    List<String> arrangeDataList =
        getRegExpStr(r'(?<=var teachers)[^]*?(?=fillTable)', data)
            ?.split("var teachers");
    arrangeDataList?.forEach((item) {
      var day =
          (int.parse(getRegExpStr(r'(?<=index =)\w', item)) + 1).toString();
      var startEnd = getRegExpList(r'(?<=unitCount\+)\w*', item);
      var start = (int.parse(startEnd.first) + 1).toString();
      var end = (int.parse(startEnd.last) + 1).toString();
      var teacherData = getRegExpStr(r'(?<=actTeachers )[^]*?(?=;)', item);
      var teacherList = getRegExpList(r'(?<=name:")[^]*?(?=")', teacherData);
      var teacher = '';
      teacherList.forEach((t) {
        teacher = teacher + t + ',';
      });
      if (teacher.endsWith(','))
        teacher = teacher.substring(0, teacher.length - 1);

      /// 课程名称、课程星期分布的信息
      List<String> courseInfo =
          getRegExpStr(r'(?<=activity )[^]*?(?=;)', item).split('\"');
      var courseName = courseInfo[3];
      var weekInfo = courseInfo[9];

      var week = "单双周";
      if (!weekInfo.contains("11")) {
        bool isSingle = false;
        for (int i = 0; i < weekInfo.length; i++) {
          if (weekInfo[i] == '1') {
            isSingle = (i % 2 == 1);
            break;
          }
        }
        week = isSingle ? '单周' : '双周';
      }

      /// arrange和下面course的courseName都需要trim(), 因为有 "流体力学（1）\s" 这种课
      var arrange = Arrange.spider(
          week, weekInfo, start, end, day, courseName.trim(), teacher);

      /// 如果当前的信息与arrangeList数组中的都不相同，则代表arrange没有重复
      /// （如果某一门课有多个老师上就会出现重复）
      bool notContains = true;
      arrangeList.forEach((e) {
        if (e.toString() == arrange.toString()) notContains = false;
      });
      if (notContains) arrangeList.add(arrange);
    });

    /// 下面的[?.]和[return]是本学期没有课程时的空判断
    List<ScheduleCourse> courses = [];
    List<String> trList =
        getRegExpStr(r'(?<=<tbody)[^]*?(?=</tbody>)', data)?.split("</tr><tr>");
    trList?.forEach((tr) {
      List<String> tdList = getRegExpList(r'(?<=<td>)[^]*?(?=</td>)', tr);
      if (tdList.isEmpty) return;
      var classId = getRegExpStr(r'(?<=>)[0-9]*', tdList[1]);
      var courseId = tdList[2];

      /// 类似 “体育C 体育舞蹈” 这种有副标题的需要做判断
      List<String> names = getRegExpList(r'[^>]+(?=<)', tdList[3]);
      var courseName = (names.length == 0)
          ? tdList[3]
          : names[0].replaceAll(RegExp(r'\s'), '') + " (${names[1]})";
      courseName = courseName.trim();

      /// 整理其余的Course信息，并与Arrange匹配
      var credit = double.parse(tdList[4]).toStringAsFixed(1);
      var teacherList = tdList[5].split(',');
      var campus = '';
      if (tr.contains("北洋园"))
        campus = "北洋园";
      else if (tr.contains("卫津路")) campus = "卫津路";
      List<String> weekStr = tdList[6].replaceAll(RegExp(r'\s'), '').split('-');
      Week week = Week(weekStr[0], weekStr[1]);
      var roomList = getRegExpList(r'[\S]+', tdList[8]);
      var roomIndex = 0;

      arrangeList.forEach((arrange) {
        /// "体育D\s(体适能)"这门课，course中的名称为"体育D\s(体适能)"，arrange中的名称为"体育D"
        /// 不能像courseName.contains(arrange.courseName)这么写，否则就会把"机器学习"和"机器学习综合实践"这样的课算在一起
        if (courseName == arrange.courseName ||
            _judgeSubtitle(courseName, arrange.courseName)) {
          /// 有些个别课没有教室信息，此时roomList.length = 2
          if (roomList.length > roomIndex) {
            arrange.room = roomList[roomIndex].replaceAll("<br/>", '');
            roomIndex += 2; // step为2用来跳过roomList匹配到的 “<br/>”
          } else
            arrange.room = '';

          /// 匹配老师的职称
          var teacher = arrange.teacher;
          teacherList.forEach((t) {
            if (t.contains(teacher)) teacher = t;
          });
          courses.add(ScheduleCourse.spider(classId, courseId, courseName,
              credit, teacher, campus, week, arrange));
        }
      });
    });
    return courses;
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
void getExam({OnResult<List<Exam>> onResult, OnFailure onFailure}) async {
  try {
    var response = await fetch(
        "http://classes.tju.edu.cn/eams/stdExamTable!examTable.action",
        cookieList: CommonPreferences().getCookies());
    var exams = <Exam>[];
    String tbody =
        getRegExpStr(r'(?<=<tbody)[^]*?(?=</tbody>)', response.data.toString());
    if (!tbody.contains('<td>')) {
      onResult([]);
      return;
    }
    List<String> trList = tbody.split("</tr><tr>");
    trList.forEach((tr) {
      List<String> tdList = getRegExpList(r'(?<=<td>)[^]*?(?=</td>)', tr);
      tdList = tdList
          .map((e) => e.contains('color')
              ? getRegExpStr(r'(?<=>)[^]*?(?=</font)', e)
              : e)
          .toList();
      var ext = tdList[8] == '正常' ? '' : tdList[9];
      exams.add(Exam(tdList[0], tdList[1], tdList[2], tdList[3], tdList[5],
          tdList[6], tdList[7], tdList[8], ext));
    });
    onResult(exams);
  } catch (e) {
    if (onFailure == null) return;
    onFailure(e is DioError ? e : WpyDioError(error: '解析考表数据出错，请重新尝试'));
  }
}
