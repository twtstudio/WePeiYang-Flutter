import 'package:dio/dio.dart' show DioError;
import 'package:flutter/material.dart' show required;
import 'package:wei_pei_yang_demo/commons/new_network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/gpa/model/gpa_model.dart';
import 'package:wei_pei_yang_demo/commons/new_network/dio_manager.dart'
    show OnResult, OnFailure;
import 'package:wei_pei_yang_demo/commons/new_network/error_interceptor.dart'
    show WpyDioError;

/// 发送请求，获取html中的gpa数据
void getGPABean({@required OnResult onResult, OnFailure onFailure}) async {
  var pref = CommonPreferences();

  try {
    /// 如果学生没有辅修，需要做一下谜之操作，不然无数据
    if (pref.ids.value == "useless") {
      /// 切换至主修
      await fetch("http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
          cookieList: pref.getCookies(), params: {'projectId': '1'});
    }
    var response = await fetch(
        "http://classes.tju.edu.cn/eams/teach/grade/course/person!historyCourseGrade.action?projectType=MAJOR",
        cookieList: pref.getCookies());
    onResult(_data2GPABean(response.data.toString()));
    return;
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

const double _DELAYED = 999.0;
const double _IGNORED = 999.0;

/// 用请求到的html数据生成gpaBean对象
GPABean _data2GPABean(String data) {
  /// 如果匹配失败，则证明cookie已过期（或者根本没保存cookie）
  if (!data.contains("在校汇总")) throw WpyDioError(error: "办公网绑定失效，请重新绑定");
  if (data.contains("本次会话已经被过期")) throw WpyDioError(error: "会话过期，请重新尝试");
  bool isMaster = false;

  /// 匹配总加权/绩点/学分: 本科生的数据在“总计”中；而研究生的数据在“在校汇总”中
  var totalData = getRegExpStr(r'(?<=总计\<\/th\>)[\s\S]*?(?=\<\/tr)', data) ??
      () {
        isMaster = true;
        return getRegExpStr(r'(?<=在校汇总\<\/th\>)[\s\S]*?(?=\<\/tr)', data);
      }.call();

  List<double> thList = [];
  getRegExpList(r'(?<=\<th\>)[0-9\.]*', totalData)
      .forEach((e) => thList.add(double.parse(e)));
  // 下标321是因为html数据的顺序和数据类的顺序不一样
  var total = Total(thList[3], thList[2], thList[1]);

  /// 匹配所有科目信息
  var filterStr = getRegExpStr(r'(?<=\>绩点\<)[\s\S]*', data); // 先去掉总数据部分的tr结点

  // TODO 不知道这样检查是否评价可以不，只能等到期末了。。
  if (filterStr.contains("评教")) throw WpyDioError(error: "有课程未评教，无法显示数据");
  var courseDataList =
      getRegExpList(r'(?<=\<tr)[\s\S]*?(?=\<\/tr)', filterStr); // 所有的课程数据（糙数据）
  var currentTermStr = "";
  List<GPAStat> stats = [];
  List<GPACourse> courses = [];
  for (int i = 0; i < courseDataList.length; i++) {
    /// 这里特意适配了重修课的红色span，在中括号里面
    var courseData = getRegExpList(r'(?<=\<td[ =":a-z]*?\>)[\s\S]*?(?=\<)',
        courseDataList[i]); // 这里的数据含有转义符
    var term = courseData[0];
    if (currentTermStr == "") currentTermStr = term;
    if (currentTermStr != term) {
      stats.add(_calculateStat(courses));
      courses.clear();
      currentTermStr = term;
    }
    var gpaCourse = _data2GPACourse(courseData, isMaster);
    if (!courseDataList[i].contains("重修") && gpaCourse != null)
      courses.add(gpaCourse);
    if (i == courseDataList.length - 1) stats.add(_calculateStat(courses));
  }
  return GPABean(total, stats);
}

/// 对课程数据进行整理后生成gpaCourse对象，注意研究生的list元素顺序和本科生的不一样
GPACourse _data2GPACourse(List<String> data, bool isMaster) {
  List<String> list = [];
  data.forEach((s) => list.add(s.replaceAll(RegExp(r'\s'), ''))); // 去掉数据中的转义符
  double score = 0.0;
  switch (isMaster ? list[8] : list[6]) {
    case 'P':
      score = 100.0;
      break;
    case '缓考':
      score = _DELAYED;
      break;
    case '--':
      score = _DELAYED;
      break;
    case 'F':
      score = 0.0;
      break;
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case '':
      score = _IGNORED;
      break;
    default:
      score = double.parse(isMaster ? list[8] : list[6]);
  }
  double credit = 0.0;
  if (score >= 60) credit = double.parse(list[5]);

  if (score != _DELAYED && score != _IGNORED) {
    double gpa = double.parse(isMaster ? list[9] : list[8]);
    return GPACourse(isMaster ? list[3] : list[2], list[4], score, credit, gpa);
  } else {
    return null;
  }
}

/// 计算每学期的总加权/绩点/学分
GPAStat _calculateStat(List<GPACourse> courses) {
  /// 不能直接把courses传进gpaStat对象中，stats数组会持续持有courses的引用导致每学期课程相同，所以这里搞个新数组copy一下
  List<GPACourse> deepCopyCourses = [];
  var currentTermScore = 0.0;
  var currentTermGpa = 0.0;
  var currentTermTotalCredits = 0.0;
  courses.forEach((course) => currentTermTotalCredits += course.credit);
  courses.forEach((course) {
    double ratio = course.credit / currentTermTotalCredits;
    currentTermGpa += course.gpa * ratio;
    currentTermScore += course.score * ratio;
    deepCopyCourses.add(course);
  });
  double score = double.parse(currentTermScore.toStringAsFixed(2));
  double gpa = double.parse(currentTermGpa.toStringAsFixed(2));
  return GPAStat(score, gpa, currentTermTotalCredits, deepCopyCourses);
}
