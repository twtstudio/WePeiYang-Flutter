// @dart = 2.12
import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';

class EditProvider with ChangeNotifier {
  /// 新建课程前初始化
  void init() {
    _arrangeList = [Arrange.empty()];
    _totalCount = 1;
    _initIndexList = [0];
    initWeekList();
  }

  /// 编辑课程前初始化
  void load(Course course) {
    _arrangeList = course.arrangeList;
    _totalCount = _arrangeList.length;
    _initIndexList = List.generate(_totalCount, (index) => index);
    initWeekList();
  }

  /// time frames
  List<Arrange> _arrangeList = [Arrange.empty()];

  List<Arrange> get arrangeList => _arrangeList;

  /// 添加的time frame的总数量
  int _totalCount = 1;

  /// 保存每个time frame最开始被分配的index
  /// 用这个index生成ValueKey，可以在build的时候不丢失输入框中的内容
  List<int> _initIndexList = [0];

  int initIndex(int index) => _initIndexList[index];

  void add() {
    _arrangeList.add(Arrange.empty());
    _initIndexList.add(_totalCount);
    _totalCount += 1;
    notifyListeners();
  }

  void remove(int index) {
    _arrangeList.removeAt(index);
    _initIndexList.removeAt(index);
    notifyListeners();
  }

  /// 检查所有arrange的必填项是否均已填
  int check() {
    for (int i = 0; i < _arrangeList.length; i++) {
      if (_arrangeList[i].weekList.isEmpty ||
          _arrangeList[i].unitList.every((e) => e == 0)) {
        return i;
      }
    }
    return -1;
  }

  /// arrange中unitList默认值为[0, 0]，代表没有设置过节数
  /// UnitPicker打开前将unitList设置为[1, 1]
  void initUnitList(int index) {
    if (arrangeList[index].unitList.every((e) => e == 0)) {
      arrangeList[index].unitList = [1, 1];
    }
  }

  /// UnitPicker关闭后保存
  void saveUnitList(int index) {
    var list = arrangeList[index].unitList;
    if (list.first > list.last) {
      arrangeList[index].unitList = list.reversed.toList();
    }
    notifyListeners();
  }

  /// 储存WeekPicker星期范围的临时变量
  int weekStart = 1;
  int weekEnd = 1;
  String weekType = '每周';

  /// WeekPicker打开前重设临时变量
  void initWeekList() {
    weekStart = 1;
    weekEnd = 1;
    weekType = '每周';
  }

  /// WeekPicker关闭后保存
  void saveWeekList(int index) {
    arrangeList[index].weekList = [];
    var start = min(weekStart, weekEnd);
    var end = max(weekStart, weekEnd);
    if (start == end) {
      arrangeList[index].weekList = [start];
    } else if (weekType == '每周') {
      for (int i = start; i <= end; i++) {
        arrangeList[index].weekList.add(i);
      }
    } else if (weekType == '单周') {
      for (int i = start; i <= end; i++) {
        if (i % 2 == 1) arrangeList[index].weekList.add(i);
      }
    } else if (weekType == '双周') {
      for (int i = start; i <= end; i++) {
        if (i % 2 == 0) arrangeList[index].weekList.add(i);
      }
    }
    notifyListeners();
  }
}
