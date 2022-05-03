// @dart = 2.12
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/spider_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_model.dart';

/// 发送请求，获取html中的gpa数据
void getGPABean(
    {required OnResult<GPABean> onResult, required OnFailure onFailure}) async {
  try {
    var info = await fetch("http://classes.tju.edu.cn/eams/stdDetail.action",
        cookieList: CommonPreferences.cookies);

    var infoDetail = info.data.toString().match(r'(?<=项目：</td>)[\s\S]*?</td>');

    /// 判断是否为硕士研究生
    bool isMaster = false;

    if (infoDetail != '' && infoDetail.contains('研究')) isMaster = true;

    if (isMaster) {
      /// 如果是研究生，切换至研究生成绩
      await fetch(
          "http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
          cookieList: CommonPreferences.cookies,
          params: {'projectId': '22'});
    } else if (CommonPreferences.ids.value == "useless") {
      /// 如果有辅修，切换至主修成绩（其实是总成绩）
      await fetch(
          "http://classes.tju.edu.cn/eams/courseTableForStd!index.action",
          cookieList: CommonPreferences.cookies,
          params: {'projectId': '1'});
    }
    var response = await fetch(
        "http://classes.tju.edu.cn/eams/teach/grade/course/person!historyCourseGrade.action?projectType=MAJOR",
        cookieList: CommonPreferences.cookies);
    onResult(_data2GPABean(response.data.toString(), isMaster));
  } on DioError catch (e) {
    onFailure(e);
  }
}

/// 用请求到的html数据生成gpaBean对象
GPABean _data2GPABean(String data, bool isMaster) {
  if (!data.contains("在校汇总") || data.contains("本次会话已经被过期")) {
    throw WpyDioError(error: "办公网绑定失效，请重新绑定");
  }
  if (data.contains("就差一个评教的距离啦")) {
    throw WpyDioError(error: "存在未评教的课程，请先前往评教");
  }

  /// 这里加一个try-catch捕获解析数据中抛出的异常（空指针之类的）
  try {
    /// 匹配总加权/绩点/学分: 本科生的数据在“总计”中；而研究生的数据在“在校汇总”中
    var totalData = isMaster
        ? data.match(r'(?<=在校汇总</th>)[\s\S]*?(?=</tr)')
        : data.match(r'(?<=总计</th>)[\s\S]*?(?=</tr)');

    List<double> thList = [];
    totalData.matches(r'(?<=<th>)[0-9.]*').forEach((e) {
      if (e != '') thList.add(double.parse(e));
    });

    /// 下标321是因为html数据的顺序和数据类的顺序不一样
    var total = Total(
      thList.length > 3 ? thList[3] : 0.0,
      thList.length > 2 ? thList[2] : 0.0,
      thList.length > 1 ? thList[1] : 0.0,
    );

    var tables = data.matches(r'(?<=gridtable)[\s\S]*?(?=</table)');
    var gridHead = tables[1].match(r'(?<=gridhead)[\s\S]*(?=</thead)');

    /// ["学年学期", "课程代码", "课程序号", "课程名称", "课程类别", "学分", "考试情况", "期末成绩", "平时成绩", "总评成绩", "最终", "绩点"]
    var headList = gridHead.matches(r'(?<=<th.*>)[\s\S][^<]*?(?=</th)');
    Map<String, int> indexMap = {};
    for (int i = 0; i < headList.length; i++) {
      switch (headList[i]) {
        case '学年学期':
          indexMap['semester'] = i;
          break;
        case '课程代码':
          indexMap['code'] = i;
          break;
        case '课程序号':
          indexMap['no'] = i;
          break;
        case '课程类别':
          indexMap['type'] = i;
          break;
        case '课程性质':
          indexMap['classProperty'] = i;
          break;
        case '课程名称':
          indexMap['name'] = i;
          break;
        case '学分':
          indexMap['credit'] = i;
          break;
        case '考试情况':
          indexMap['condition'] = i;
          break;
        case '最终':
        case '成绩':
          indexMap['score'] = i;
          break;
        case '绩点':
          indexMap['gpa'] = i;
          break;
      }
    }

    /// 课程数据存储在了第二个table的tbody中
    var filterStr = tables[1].match(r'(?<=<tbody>)[\s\S]*(?=</tbody>)');

    /// 所有的课程数据
    var courseDataList = filterStr.matches(r'(?<=<tr)[\s\S]*?(?=</tr)');

    var semesterMap = Map<String, List<GPACourse>>();
    for (int i = 0; i < courseDataList.length; i++) {
      /// 这里的[ =":a-z]*?的作用是适配重修课的红色span
      var courseData = courseDataList[i]
          .matches(r'(?<=<td[ =":a-z]*?>)[\s\S]*?(?=<)')
          .map((e) => e.replaceAll(RegExp(r'\s'), ''))
          .toList(); // 这里去掉了数据中的转义符
      var semester = courseData[0];

      var gpaCourse =
          _data2GPACourse(indexMap.map((k, v) => MapEntry(k, courseData[v])));
      if (courseDataList[i].contains('重修') ||
          gpaCourse == null ||
          gpaCourse.rawScore == '') continue; // 忽略重修课、缓考课、数据异常课

      semesterMap.update(
        semester,
        (list) => list..add(gpaCourse),
        ifAbsent: () => [gpaCourse],
      );
    }
    List<GPAStat> stats =
        semesterMap.values.map((courses) => _calculateStat(courses)).toList();

    return GPABean(total, stats);
  } catch (e) {
    throw WpyDioError(error: "解析GPA数据出错，请重新尝试");
  }
}

/// 对课程数据进行整理后生成gpaCourse对象
GPACourse? _data2GPACourse(Map<String, String> data) {
  if (data['score'] != null) {
    if (data['score'] == '缓考' || data['score'] == '--') return null; // 忽略缓考课
  }

  double score = double.tryParse(data['score'] ?? '0.0') ?? 0.0;
  double credit = double.tryParse(data['credit'] ?? '0.0') ?? 0.0;
  double gpa = double.tryParse(data['gpa'] ?? '0.0') ?? 0.0;

  return GPACourse(data['name'] ?? '', data['type'] ?? '', score,
      data['score'] ?? '', credit, gpa);
}

/// 计算每学期的总加权/绩点/学分
GPAStat _calculateStat(List<GPACourse> courses) {
  var totalCredit = 0.0;
  var totalScore = 0.0;
  var totalGPA = 0.0;
  courses.forEach((course) {
    if (course.credit == 0 || course.gpa == 0)
      return; // gpa为零时代表 F P 等情况(不会有人真能考零分吧)
    totalCredit += course.credit;
    totalScore += course.credit * course.score;
    totalGPA += course.credit * course.gpa;
  });

  if (totalCredit == 0) {
    totalScore = 0;
    totalGPA = 0;
  } else {
    totalScore = double.parse((totalScore / totalCredit).toStringAsFixed(2));
    totalGPA = double.parse((totalGPA / totalCredit).toStringAsFixed(2));
  }

  return GPAStat(totalScore, totalGPA, totalCredit, [...courses]); // 这里需要深拷贝
}
