// @dart = 2.12
import 'package:hive/hive.dart';
import 'area.dart';
import 'building.dart';
import 'classroom.dart';

part 'search_entry.g.dart';

enum ResultType { room, area, building }

class ResultEntry {
  final Area? area;
  final Classroom? room;
  final Building? building;

  ResultEntry({
    this.area,
    this.room,
    this.building,
  });
}

@HiveType(typeId: 6)
class HistoryEntry {
  @HiveField(0)
  String bName;

  @HiveField(1)
  String cName;

  @HiveField(2)
  String aId;

  @HiveField(3)
  String bId;

  @HiveField(4)
  String cId;

  @HiveField(5)
  String date;

  HistoryEntry({
    required this.bName,
    required this.cName,
    required this.aId,
    required this.bId,
    required this.cId,
    required this.date,
  });

  Map toJson() =>
      {"aId": aId, "bId": bId, "cId": cId, "cName": cName, "bName": bName};
}
