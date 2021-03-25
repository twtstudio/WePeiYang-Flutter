import 'package:dio/dio.dart' show DioError, Response;
import 'package:wei_pei_yang_demo/commons/new_network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/commons/new_network/dio_manager.dart'
    show OnResult, OnFailure;

/// 发送请求，获取html中的schedule数据
void getScheduleCourses({OnResult onResult, OnFailure onFailure}) async {
  var pref = CommonPreferences();

  try {
    /// 学生没有辅修的情况：
    if (pref.ids.value != "useless") {
      var response = await getDetailSchedule(pref.ids.value);
      onResult(_data2ScheduleCourses(response.data.toString()));
      return;
    }

    /// 学生有辅修的情况：
    var scheduleList = List<ScheduleCourse>();
    var idsValue = "";

    /// 获取semester.id
    var semesterRsp = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: pref.getCookies(),
        params: {'projectId': '1'});
    semesterRsp.headers.map['set-cookie'].forEach((string) {
      if (string.contains('semester'))
        pref.semesterId.value = getRegExpStr(r'semester\.id=\w+', string);
    });

    /// 切换至主修
    await fetch("http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
        cookieList: pref.getCookies(), params: {'projectId': '1'});

    /// 获取主修的ids
    var idsRsp1 = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: pref.getCookies(),
        params: {'projectId': '1', '_': DateTime.now().millisecondsSinceEpoch});
    idsValue = getRegExpStr(r'(?<=ids\"\,\")\w*', idsRsp1.data.toString());

    /// 获取主修课程
    var courseRsp1 = await getDetailSchedule(idsValue);
    scheduleList.addAll(_data2ScheduleCourses(courseRsp1.data.toString()));

    /// 切换至辅修
    await fetch("http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
        cookieList: pref.getCookies(), params: {'projectId': '2'});

    /// 获取辅修的ids
    var idsRsp2 = await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
        cookieList: pref.getCookies(),
        params: {'projectId': '2'});
    idsValue = getRegExpStr(r'(?<=ids\"\,\")\w*', idsRsp2.data.toString());

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
  // TODO 之前grj的账号好像有问题？
  // if (!data.contains("课程列表")) throw DioError();

  /// 先整理出所有的arrange对象
  List<Arrange> arrangeList = [];
  List<String> arrangeDataList =
      getRegExpStr(r'(?<=var teachers)[^]*?(?=fillTable)', data)
          ?.split("var teachers");
  arrangeDataList?.forEach((item) {
    var day = (int.parse(getRegExpStr(r'(?<=index =)\w', item)) + 1).toString();
    var startEnd = getRegExpList(r'(?<=unitCount\+)\w*', item);
    var start = (int.parse(startEnd.first) + 1).toString();
    var end = (int.parse(startEnd.last) + 1).toString();

    /// 课程名称、课程星期分布的信息
    List<String> courseInfo =
        getRegExpStr(r'(?<=activity )[^]*?(?=\;)', item).split('\"');
    var courseName = courseInfo[3];

    /// 如果当前的信息与arrangeList数组中的都不相同，则代表arrange没有重复
    /// （如果某一门课有多个老师上就会出现重复）
    bool notContains = arrangeList.every((it) => !(it.day == day &&
        it.start == start &&
        it.end == end &&
        it.courseName == courseName));
    if (notContains) {
      var weekInfo = courseInfo[9];
      var week = "单双周";
      bool isAllWeek = weekInfo.contains("11");
      bool isSingle = false;
      for (int i = 0; i < weekInfo.length; i++) {
        if (weekInfo[i] == '1') {
          isSingle = (i % 2 == 1);
          break;
        }
      }
      if (!isAllWeek && isSingle) week = "单周";
      if (!isAllWeek && !isSingle) week = "双周";
      arrangeList.add(Arrange.spider(week, start, end, day, courseName));
    }
  });

  /// 下面的[?.]和[return]是本学期没有课程时的空判断
  List<ScheduleCourse> courses = [];
  List<String> trList = getRegExpStr(r'(?<=\<tbody)[^]*?(?=\<\/tbody\>)', data)
      ?.split("</tr><tr>");
  trList?.forEach((tr) {
    List<String> tdList = getRegExpList(r'(?<=\<td\>)[^]*?(?=\<\/td\>)', tr);
    if (tdList.isEmpty) return;
    var classId = getRegExpStr(r'(?<=\>)[0-9]*', tdList[1]);
    var courseId = tdList[2];

    /// 类似 “体育C 体育舞蹈” 这种有副标题的需要做判断
    List<String> names = getRegExpList(r'[^\>]+(?=\<)', tdList[3]);
    var courseName = (names.length == 0)
        ? tdList[3]
        : names[0].replaceAll(RegExp(r'\s'), '') + " (${names[1]})";
    var credit = double.parse(tdList[4]).toStringAsFixed(1);
    var teacher = tdList[5];
    var campusList = getRegExpList(r'[\S]+', tdList[9]);
    var campus = campusList.length > 0
        ? campusList[0].replaceAll("校区", '').replaceAll("<br/>", '')
        : ""; // 不会真的有课新老校区各上一节吧
    List<String> weekStr = tdList[6].replaceAll(RegExp(r'\s'), '').split('-');
    Week week = Week(weekStr[0], weekStr[1]);
    var roomList = getRegExpList(r'[\S]+', tdList[8]);
    var roomIndex = 0;
    arrangeList.forEach((arrange) {
      var mainName =
          courseName.contains(' ') ? courseName.split(' ').first : courseName;
      if (arrange.courseName == mainName) {
        arrange.room = roomList[roomIndex].replaceAll("<br/>", '');
        roomIndex += 2; // step为2用来跳过roomList匹配到的 “<br/>”
        courses.add(ScheduleCourse(classId, courseId, courseName, credit,
            teacher, campus, week, arrange));
      }
    });
  });
  return courses;
}
