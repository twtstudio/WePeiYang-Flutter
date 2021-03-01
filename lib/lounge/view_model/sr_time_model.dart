import 'package:flutter/cupertino.dart';
import 'package:wei_pei_yang_demo/lounge/service/sr_repository.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';

class SRTimeModel extends ChangeNotifier {
  List<ClassTime> _classTime;

  List<ClassTime> get classTime => _classTime;

  DateTime _dateTime;

  DateTime get dateTime => _dateTime;

  setTime({
    DateTime date,
    List<ClassTime> schedule,
    bool compareToRemoteData = false,
  }) async {
    if (_classTime == null && _dateTime == null) {
      _classTime = [Time.classOfDay(DateTime.now())];
      _dateTime = DateTime.now();
    } else {
      _classTime = schedule ?? _classTime;
      _dateTime = date ?? _dateTime;
    }
    if (compareToRemoteData) await StudyRoomRepository.setSRData(model: this);
    notifyListeners();
  }
}
