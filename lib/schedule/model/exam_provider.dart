import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_backend_service.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/network/schdule_service.dart';

class ExamProvider with ChangeNotifier {
  /// 所有考试
  List<Exam> _exams = [];

  void set exams(List<Exam> newList) {
    _exams = newList;

    /// 已完成的考试，判断比now早即可
    _finished = [];
    _exams.forEach((e) {
      if (e.date == '时间未安排') return;
      var target = DateTime.parse(e.date);
      if (target.isBefore(realNow)) _finished.add(e);
    });
    _finished.sort((a, b) => b.date.compareTo(a.date)); // 将`刚考完`的排在上面

    /// 未完成的考试，刚好为now这天或者在now之后（也包括未安排的考试）
    _unfinished = [];
    List<Exam> tmp = [];
    _exams.forEach((e) {
      if (e.date == '时间未安排') {
        tmp.add(e);
      } else {
        var target = DateTime.parse(e.date);
        if (target.isAfter(realNow) || target.isAtSameMomentAs(realNow))
          _unfinished.add(e);
      }
    });

    _unfinished.sort((a, b) => a.date.compareTo(b.date)); // 将`刚要考`的排在上面
    _unfinished.addAll(tmp); // 没有安排的考试排在最后

    /// 未完成的、且有安排的考试，在[unfinished]的基础上滤去了时间未安排的课程
    _unscheduled = [];
    _exams.forEach((e) {
      if (e.date == '时间未安排') return;
      var target = DateTime.parse(e.date);
      if (target.isAfter(realNow) || target.isAtSameMomentAs(realNow))
        _unscheduled.add(e);
    });
    _unscheduled.sort((a, b) => a.date.compareTo(b.date)); // 将`刚要考`的排在上面
    notifyListeners();
  }

  List<Exam> _finished = [];

  List<Exam> get finished => _finished;

  List<Exam> _unfinished = [];

  List<Exam> get unfinished => _unfinished;

  List<Exam> _unscheduled = [];

  List<Exam> get unscheduled => _unscheduled;

  /// notifier中也写一个hideExam，就可以在从设置页面pop至主页时，令主页的WpyExamWidget进行rebuild
  void set hideExam(bool value) {
    CommonPreferences.hideExam.value = value;
    notifyListeners();
  }

  bool get hideExam => CommonPreferences.hideExam.value;

  /// 使用后端爬虫（无需填写图形验证码）
  /// [CommonPreferences.useClassesBackend.value]决定了爬虫方式
  ///   --true: 使用后端的完整爬虫接口，直接获取办公网信息
  ///   --false: 仅使用后端ocr接口识别验证码
  /// 若失败则弹出TjuRebindDialog，用户手动填写图形验证码
  void refreshExamByBackend(BuildContext context) async {
    ToastProvider.running("刷新数据中……");
    if (CommonPreferences.useClassesBackend.value) {
      var data = await ClassesBackendService.getClasses();
      if (data != null) {
        exams = data.item2;
        notifyListeners();
      } else {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => TjuRebindDialog(),
        );
      }
    } else {
      var tjuuname = CommonPreferences.tjuuname.value;
      var tjupasswd = CommonPreferences.tjupasswd.value;
      try {
        var captcha = await ClassesBackendService.ocr();
        await ClassesService.getClasses(context, tjuuname, tjupasswd, captcha);
      } on DioError catch (_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => TjuRebindDialog(),
        );
      }
    }
  }

  /// 使用前端爬虫
  void refreshExam({
    void Function()? onSuccess,
    void Function(DioError)? onFailure,
  }) {
    ScheduleService.fetchExam(onResult: (exams) {
      this.exams = exams;
      CommonPreferences.examData.value = json.encode(ExamTable(_exams));
      onSuccess?.call();
    }, onFailure: (e) {
      onFailure?.call(e);
    });
  }

  /// 从缓存中读考表的数据，进入主页之前调用
  void readPref() {
    if (CommonPreferences.examData.value == '') return;
    this.exams =
        ExamTable.fromJson(json.decode(CommonPreferences.examData.value)).exams;
  }

  /// 办公网解绑时清除数据
  void clear() {
    this.exams = [];
  }

  /// 由于Exam中的date只确切到天，所以本地时间也确切到天，这样便于计算
  DateTime get realNow {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
