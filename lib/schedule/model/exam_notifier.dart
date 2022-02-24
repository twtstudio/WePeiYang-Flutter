import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show OnFailure;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/network/schedule_spider.dart';

class ExamNotifier with ChangeNotifier {
  ExamTable _examTable = ExamTable([]);

  /// 已完成的考试，判断比now早即可
  List<Exam> get finished {
    List<Exam> ret = [];
    _examTable.exams.forEach((e) {
      if (e.date == '时间未安排') return;
      var target = DateTime.parse(e.date);
      if (target.isBefore(realNow)) ret.add(e);
    });
    ret.sort((a, b) => b.date.compareTo(a.date)); // 将`刚考完`的排在上面
    return ret;
  }

  /// 未完成的考试，刚好为now这天或者在now之后（也包括未安排的考试）
  List<Exam> get unfinished {
    List<Exam> unscheduled = [];
    List<Exam> after = [];
    _examTable.exams.forEach((e) {
      if (e.date == '时间未安排') {
        unscheduled.add(e);
      } else {
        var target = DateTime.parse(e.date);
        if (target.isAfter(realNow) || target.isAtSameMomentAs(realNow))
          after.add(e);
      }
    });
    after.sort((a, b) => a.date.compareTo(b.date)); // 将`刚要考`的排在上面
    after.addAll(unscheduled); // 没有安排的考试排在最后
    return after;
  }

  /// 未完成的、且有安排的考试，在[unfinished]的基础上滤去了时间未安排的课程
  List<Exam> get unscheduled {
    List<Exam> ret = [];
    _examTable.exams.forEach((e) {
      if (e.date == '时间未安排') return;
      var target = DateTime.parse(e.date);
      if (target.isAfter(realNow) || target.isAtSameMomentAs(realNow))
        ret.add(e);
    });
    ret.sort((a, b) => a.date.compareTo(b.date)); // 将`刚要考`的排在上面
    return ret;
  }

  /// notifier中也写一个hideExam，就可以在从设置页面pop至主页时，令主页的WpyExamWidget进行rebuild
  set hideExam(bool value) {
    CommonPreferences.hideExam.value = value;
    notifyListeners();
  }

  bool get hideExam => CommonPreferences.hideExam.value;

  /// 通过爬虫刷新数据
  RefreshCallback refreshExam({bool hint = false, OnFailure onFailure}) {
    return () async {
      if (hint) ToastProvider.running("刷新数据中……");
      getExam(onResult: (exams) {
        if (hint) ToastProvider.success("刷新考表数据成功");
        this._examTable = ExamTable(exams);
        notifyListeners(); // 通知各widget进行更新
        CommonPreferences.examData.value = json.encode(_examTable); // 刷新本地缓存
      }, onFailure: (e) {
        if (onFailure != null) onFailure(e);
      });
    };
  }

  /// 从缓存中读考表的数据，进入主页之前调用
  void readPref() {
    if (CommonPreferences.examData.value == '') return;
    this._examTable =
        ExamTable.fromJson(json.decode(CommonPreferences.examData.value));
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    this._examTable.exams = [];
    notifyListeners();
  }

  /// 由于Exam中的date只确切到天，所以本地时间也确切到天，这样便于计算
  DateTime get realNow {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
