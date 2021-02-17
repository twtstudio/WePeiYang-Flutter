import 'package:flutter/cupertino.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';

class SRTimeModel extends ChangeNotifier {
  int _currentDay;

  int get currentDay => _currentDay;

  set currentDay(value) {
    _currentDay = value;
    notifyListeners();
  }


  Schedule _schedule;

  Schedule get schedule => _schedule;

  set schedule(value) {
    _schedule = value;
    notifyListeners();
  }

  DateTime _dateTime;

  DateTime get dateTime => _dateTime;

  set dateTime(DateTime value) {
    _dateTime = value;
    currentDay = value.weekday;
  }

  void initSchedule(){
    schedule = Time.classOfDay(DateTime.now());
    dateTime = DateTime.now();
  }
}
