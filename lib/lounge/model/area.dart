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
  Map<String ,Classroom> classrooms;

  static Area fromMap(Map<String,dynamic> map){
    if(map == null) return null;
    Area area = Area();
    area.area_id = map['area_id'] ?? '';
    // var list = map['classrooms'];
    var list = List()
       ..addAll((map['classrooms'] as List ?? []).map((e) => Classroom.fromMap(e)));
    for(var room in list){
      area.classrooms[room.id ?? ''] = room;
    }
    return area;
  }

  Map toJson() => {
    "area_id":area_id,
    "classrooms":classrooms
  };
}