import 'package:hive/hive.dart';

part 'classroom.g.dart';

@HiveType(typeId: 3)
class Classroom {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String capacity;
  @HiveField(3)
  String status;
  @HiveField(4)
  String bId;
  @HiveField(5)
  String aId;

  Classroom(
      {this.id,
      this.name,
      this.capacity,
      this.status = '',
      this.bId = '',
      this.aId = ''});

  static Classroom fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Classroom classroom = Classroom();
    classroom.id = map['classroom_id'] ?? '';
    classroom.name = map['classroom'] ?? '';
    classroom.capacity = map['capacity'] ?? '';
    classroom.status = map['status'] ?? '';
    //TODO: 这个大概使不会有的
    // classroom.bId = map['building'];
    // classroom.aId = map['area'];
    return classroom;
  }

  Map toJson() =>
      {"id": id, "name": name, "capacity": capacity, 'bId': bId, 'aId': aId};
}
