import 'package:hive/hive.dart';

import 'classroom.dart';

part 'area.g.dart';

@HiveType(typeId: 2)
class Area {
  @HiveField(0)
  String area_id;
  @HiveField(1)
  String building;
  @HiveField(2)
  List<Classroom> classrooms;

  static Area fromMap(Map<String,dynamic> map){
    if(map == null) return null;
    Area area = Area();
    area.area_id = map['area_id'];
    area.classrooms = map['classrooms'];
    return area;
  }

  Map toJson() => {
    "area_id":area_id,
    "classrooms":classrooms
  };
}