import 'package:hive/hive.dart';
import 'area.dart';

part "building.g.dart";

@HiveType(typeId: 1)
class Building {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String campus;
  @HiveField(3)
  List<Area> areas;

  Building({this.id, this.name, this.campus, this.areas});

  static Building fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Building building = Building();
    building.id = map['building_id'];
    building.name = map['building'];
    building.campus = map['campus_id'];
    building.areas = List()
      ..addAll((map['areas'] as List ?? []).map((e) => Area.fromMap(e)));
    return building;
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "campus": campus,
        "areas": areas,
      };
}
