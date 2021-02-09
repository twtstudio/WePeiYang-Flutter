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

  Classroom({this.id,this.name,this.capacity,this.status});

  static Classroom fromMap(Map<String,dynamic> map) {
    if (map == null) return null;
    Classroom classroom = Classroom();
    classroom.id = map['classroom_id'];
    classroom.name = map['classroom'];
    classroom.capacity = map['capacity'];
    return classroom;
  }

  Map toJson() => {
    "id":id,
    "name":name,
    "capacity":capacity
  };
}