import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/network/schedule_spider.dart';

class ExamNotifier with ChangeNotifier {
  ExamTable _examTable = ExamTable([]);

  /// 已完成的考试
  List<Exam> get beforeNow {
    List<Exam> ret = [];
    _examTable.exams.forEach((e) {
      if (e.date != '时间未安排' &&
          DateTime.parse(e.date).isBefore(DateTime.now())) {
        ret.add(e);
      }
    });
    ret.sort((a, b) => b.date.compareTo(a.date)); // 将刚考完的排在上面
    return ret;
  }

  /// 未完成的考试
  List<Exam> get afterNow {
    List<Exam> noArrange = [];
    List<Exam> after = [];
    _examTable.exams.forEach((e) {
      if (e.date == '时间未安排') {
        noArrange.add(e);
      } else if (DateTime.parse(e.date).isAfter(DateTime.now())) {
        after.add(e);
      }
    });
    after.sort((a, b) => a.date.compareTo(b.date)); // 将刚要考的排在上面
    after.addAll(noArrange);
    return after;
  }

  /// 未完成的、有安排的考试
  List<Exam> get afterNowReal {
    List<Exam> after = [];
    _examTable.exams.forEach((e) {
      if (e.date != '时间未安排' &&
          DateTime.parse(e.date).isAfter(DateTime.now())) {
        after.add(e);
      }
    });
    after.sort((a, b) => a.date.compareTo(b.date)); // 将刚要考的排在上面
    return after;
  }

  /// notifier中也写一个hideExam，就可以在从设置页面pop至主页时，令主页的WpyExamWidget进行rebuild
  set hideExam(bool value) {
    CommonPreferences().hideExam.value = value;
    notifyListeners();
  }

  bool get hideExam => CommonPreferences().hideExam.value;

  /// 通过爬虫刷新数据
  RefreshCallback refreshExam({bool hint = false, OnFailure onFailure}) {
    return () async {
      if (hint) ToastProvider.running("刷新数据中……");
      getExam(onResult: (exams) {
        if (hint) ToastProvider.success("刷新考表数据成功");
        this._examTable = ExamTable(exams);
        notifyListeners(); // 通知各widget进行更新
        CommonPreferences().examData.value = json.encode(_examTable); // 刷新本地缓存
      }, onFailure: (e) {
        if (onFailure != null) onFailure(e);
      });
    };
  }

  /// 从缓存中读考表的数据，进入主页之前调用
  void readPref() {
    var pref = CommonPreferences();
    if (pref.examData.value == '') return;
    this._examTable = ExamTable.fromJson(json.decode(pref.examData.value));
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    this._examTable.exams = [];
    notifyListeners();
  }
}
