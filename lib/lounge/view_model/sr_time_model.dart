import 'package:flutter/cupertino.dart';
import 'package:wei_pei_yang_demo/lounge/service/sr_repository.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';

class SRTimeModel extends ChangeNotifier {
  List<Schedule> _schedule;

  List<Schedule> get schedule => _schedule;

  DateTime _dateTime;

  DateTime get dateTime => _dateTime;

  setTime({DateTime date, List<Schedule> schedule}) async {
    if (_schedule == null && _dateTime == null) {
      _schedule = [Time.classOfDay(DateTime.now())];
      _dateTime = DateTime.now();
    } else {
      _schedule = schedule ?? _schedule;
      _dateTime = date ?? _dateTime;
    }
    await StudyRoomRepository.setSRData(model: this);
    notifyListeners();
  }
}
