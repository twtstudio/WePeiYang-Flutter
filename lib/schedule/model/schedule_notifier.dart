import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_model.dart';

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

  /// test
  int _weekCount = 21;

  int get weekCount => _weekCount;
}