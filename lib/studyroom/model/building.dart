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
  Map<String, Area> areas;

  Building({this.id, this.name, this.campus, this.areas});

  static Building fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Building building = Building();
    building.id = map['building_id'] ?? '';
    building.name = map['building'] ?? '';
    building.campus = map['campus_id'] ?? '';
    var list = List()
      ..addAll((map['areas'] as List ?? []).map((e) => Area.fromMap(e)));
    for (var area in list) {
      building.areas[area.id ?? ''] = area;
    }
    return building;
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "campus": campus,
        "areas": areas,
      };
}
