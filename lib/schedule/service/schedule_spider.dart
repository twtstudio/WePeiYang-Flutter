import 'package:dio/dio.dart' show DioError;
import 'package:flutter/material.dart' show required;
import 'package:wei_pei_yang_demo/commons/network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/common_model.dart';

/// 发送请求，获取html中的schedule数据
Future<void> getSchedule(
    {@required void Function(Schedule) onSuccess,
    void Function(DioError) onFailure}) async {
  var pref = CommonPreferences.create();
  var jSessionId = "J" + pref.gSessionId.value?.substring(1);
  var cookieList = [
    pref.gSessionId.value,
    jSessionId,
    pref.garbled.value,
    pref.semesterId.value
  ];
  await fetch(
      "http://classes.tju.edu.cn/eams/courseTableForStd!innerIndex.action",
      cookieList: cookieList, onSuccess: (_) async {
    await fetch(
        "http://classes.tju.edu.cn/eams/courseTableForStd!courseTable.action",
        cookieList: cookieList,
        isPost: true,
        params: {
          "ignoreHead": "1",
          "setting.kind": "std",
          "startWeek": "",
          "semester.id": getRegExpStr(r'[0-9]*', pref.semesterId.value),

          "ids": pref.ids.value
        },
        onSuccess: (response) =>
            onSuccess(_data2Schedule(response.data.toString())),
        onFailure: onFailure);
  }, onFailure: onFailure);
}

/// 用请求到的html数据生成schedule对象
Schedule _data2Schedule(String data) {
  /// 先整理出所有的arrange对象
  List<Arrange> arrangeList = [];
  List<String> arrangeDataList =
      getRegExpStr(r'(?<=var teachers)[^]*?(?=fillTable)', data)
          .split("var teachers");
  arrangeDataList.forEach((item) {
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

  List<Course> courses = [];
  List<String> trList = getRegExpStr(r'(?<=\<tbody)[^]*?(?=\<\/tbody\>)', data)
      .split("</tr><tr>");
  trList.forEach((tr) {
    List<String> tdList = getRegExpList(r'(?<=\<td\>)[^]*?(?=\<\/td\>)', tr);
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
        courses.add(Course(classId, courseId, courseName, credit, teacher,
            campus, week, arrange));
      }
    });
  });
  return Schedule(1581868800, "19202", courses);
}
