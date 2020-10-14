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
  var jSessionId = "J" + pref.gSessionId.value.substring(1);
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
  List<String> arrangeDataList =
      getRegExpStr(r'(?<=var teachers)[^]*?(?=fillTable)', data)
          .split("var teachers");

  List<Arrange> arrangeList = [];
  arrangeDataList.forEach((item) {
    var day = (int.parse(getRegExpStr(r'(?<=index =)\w', item)) + 1).toString();
    var courseName =
        getRegExpStr(r'(?<=activity )[^]*?(?=\;)', item).split('\"')[3];
  });

  var courses = [];
  List<String> trList = getRegExpStr(r'(?<=\<tbody)[^]*?(?=\<\/tbody\>)', data)
      .split("</tr><tr>");
  trList.forEach((tr) {
    List<String> tdList = getRegExpList(r'(?<=\<td\>)[^]*?(?=\<\/td\>)', tr);
    var classId = getRegExpStr(r'(?<=\>)[0-9]*', tdList[1]);
    var courseId = tdList[2];

    /// 类似 “体育C 体育舞蹈” 这种有副标题的需要做判断
    List<String> names = getRegExpList(r'[^\>]*(?=\<)', tdList[3]);
    var courseName = "";
    if (names.length == 1)
      courseName = names[0];
    else {
      courseName = names[0].replaceAll(RegExp(r'\s'), '') + " " + names[1];
    }
    var credit = tdList[4];
    var teacher = tdList[5];
    var campus = getRegExpList(r'[\S]*', tdList[9])[0]; // 不会真的有课新老校区各上一节吧
    List<String> weekStr = tdList[6].replaceAll(RegExp(r'\s'), '').split('-');
    Week week = Week(weekStr[0], weekStr[1]);
  });
  var a = data;
  return Schedule(1581868800, "19202", null);
}
