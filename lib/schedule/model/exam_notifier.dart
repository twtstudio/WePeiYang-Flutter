import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
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
    if(CommonPreferences().isAprilFool.value){
      after.addAll(april);
    }
    else {
      _examTable.exams.forEach((e) {
        if (e.date == '时间未安排') {
          unscheduled.add(e);
        } else {
          var target = DateTime.parse(e.date);
          if (target.isAfter(realNow) || target.isAtSameMomentAs(realNow))
            after.add(e);
        }
      });
    }

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

  /// 由于Exam中的date只确切到天，所以本地时间也确切到天，这样便于计算
  DateTime get realNow {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  ///愚人节考表
  List<Exam> april = [
    Exam("1", "游戏与现实的自己理论分析", "期末考试", "2022-04-02", "20:00"," 沙城 "," 座位任选", "未完成",""),
    Exam("2", "朱雀门事变历史探讨", "期末考试", "2022-04-03", "1:30-1:50","","", "未完成",""),
    Exam("3", "人类高质量油脂提纯", "期末考试", "2022-04-03", "9:00-10:00","37教A106"," 72", "未完成",""),
    Exam("4", "鸡排饭制作工艺鉴赏", "期末考试", "2022-04-03", "11:00-12:00","学四食堂","某窗口", "未完成",""),
    Exam("5", "门锁技能培训", "期末考试", "2022-04-03", "22:30-23:30","44教 A110"," 座位任选", "未完成",""),
    Exam("6", "热带风味冰红茶原材料分析", "期末考试", "2022-04-04", "1:00-4:00","七星灯火自习室"," 023", "未完成",""),
    Exam("7", "羊胎素功能分析（这是可以考的吗？）", "期末考试", "2022-04-03", "16:00-17:30","46教  A210","56", "未完成",""),
    Exam("8", "三阿哥生理结构分析", "期末考试", "2022-04-04", " 9:00-10:00","45教   A112","23", "未完成",""),
    Exam("9", "保熟西瓜种植理论与实践", "期末考试", "2022-04-04", "14:00-16:30","劳动实践基地果园","座位任选", "未完成",""),
    Exam("10", "生活道理运用", "期末考试", "2022-04-04", "20:00-21:00","宿舍楼"," 座位任选", "未完成",""),
    Exam("11", "群青，但是要熬夜debug", "期末考试", "2022-04-05", "0:00-2:30","宿舍  线上"," 座位任选", "未完成",""),
    Exam("12", "105℃气压分析", "期末考试", "2022-04-05", "钝角","钝角"," 座位任选", "未完成",""),
    Exam("13", "鸡汤烹饪技巧概论", "期末考试", "2022-04-05", "18:00-22:30","宿舍一楼"," 座位任选", "未完成",""),
    Exam("14", "《窃锅记》全文赏析", "期末考试", "2022-04-06", "8:00-9:00","学五食堂"," 座位任选", "未完成",""),
    Exam("15", "金钱豹物种习性研究", "期末考试", "2022-04-06", "10：30-11：30","操场"," 座位任选", "未完成",""),
    Exam("16", "哥谭梦境文化撷英", "期末考试", "2022-04-06", "13：30-15：30","46教 A301","33", "未完成",""),
    Exam("17", "面包烘培与芝士制作", "期末考试", "2022-04-07", "9：30-12：00","东京"," 座位任选", "未完成","机票自备"),
    Exam("18", "一句话让这周考了十八场试", "期末考试", "2022-04-08", "9:00-12:00","33教 A305","41", "未完成",""),
    Exam("19", "足痰酸菜发酵微生物提纯", "期末考试", "2022-04-08", "15：00-17：00 ","43教  A204","03", "未完成",""),
    Exam("20", "考完了，但又没完全考完", "期末考试", "2022-04-08", "23：00-23：59","青年湖底"," 座位任选", "未完成",""),

  ];
}
