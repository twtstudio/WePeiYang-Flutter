import 'package:flutter/material.dart';

class ScheduleNotifier with ChangeNotifier {
  int _selectedWeek = 1;

  set selectedWeek(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  int get selectedWeek => _selectedWeek;

  /// test
  int _weekCount = 21;

  int get weekCount => _weekCount;

  List<List<bool>> list = [];

  get testList{
    list.clear();
    list.add([false,false,true,false,true,false]);
    list.add([true,true,true,false,false,false]);
    list.add([false,false,false,false,false,false]);
    list.add([false,false,false,false,false,false]);
    list.add([false,false,false,true,false,false]);
    return list;
  }
}