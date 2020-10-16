import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/common_model.dart';
import 'package:wei_pei_yang_demo/schedule/service/schedule_spider.dart';

class ScheduleNotifier with ChangeNotifier {
  List<Course> _coursesWithNotify = [];

  /// 更新课表总数据时调用（如网络请求）
  set coursesWithNotify(List<Course> newList){
    _coursesWithNotify = newList;
    notifyListeners();
  }

  List<Course> get coursesWithNotify => _coursesWithNotify;

  /// 每学期的开始时间
  int _termStart = 1598803200;

  set termStart(int newStart){
    if(_termStart == newStart) return;
    _termStart = newStart;
    notifyListeners();
  }

  int get termStart => _termStart;

  /// 当前显示的星期
  int _selectedWeek = 1;

  set selectedWeek(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  int get selectedWeek => _selectedWeek;

  /// 课程表显示 六天/七天
  bool _showSevenDay = false;

  bool get showSevenDay => _showSevenDay;

  void changeWeekMode(){
    _showSevenDay = !_showSevenDay;
    notifyListeners();
  }

  /// 通过爬虫刷新数据
  RefreshCallback refreshBySpider (BuildContext context) {
    return () async {
      Fluttertoast.showToast(
          msg: "刷新数据中……",
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          timeInSecForIosWeb: 1,
          fontSize: 16);
      await getSchedule(onSuccess: (schedule) {
        Fluttertoast.showToast(
            msg: "刷新课程表数据成功",
            textColor: Colors.white,
            backgroundColor: Colors.green,
            timeInSecForIosWeb: 1,
            fontSize: 16);
        _termStart = schedule.termStart;
        _coursesWithNotify = schedule.courses;
        notifyListeners();
      }, onFailure: (e) {
        Fluttertoast.showToast(
            msg: e.error.toString(),
            textColor: Colors.white,
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 1,
            fontSize: 16);
      });
    };
  }

  /// test
  int _weekCount = 21;

  int get weekCount => _weekCount;
}