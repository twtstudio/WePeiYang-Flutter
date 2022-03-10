
// @dart = 2.12

import 'package:hive/hive.dart';
import 'area.dart';

part 'building.g.dart';

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

  @HiveField(4)
  int roomCount;

  Building({
    required this.id,
    required this.name,
    required this.campus,
    required this.areas,
    required this.roomCount,
  });

  static Building fromMap(Map<String, dynamic> map) {
    final bName =
        RegExp(r'^[0-9]{2}').firstMatch(map['building'] ?? '')?.group(0) ?? '';

    final bId = map['building_id'] ?? '';

    List<Area> list = [
      ...(map['areas'] as List? ?? []).map(
        (e) => Area.fromMap(e, bName, bId),
      )
    ];

    var count = 0;
    var areas = <String, Area>{};

    for (var area in list) {
      areas[area.id] = area;
      count += (area.classrooms.length);
    }

    return Building(
      id: bId,
      name: bName,
      campus: map['campus_id'] ?? '',
      roomCount: count,
      areas: areas,
    );
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "campus": campus,
        "areas": areas,
      };

  @override
  String toString() => '''{
  id: $id,
  name: $name,
  campus: $campus,
  areas: $_areasStr,
}''';

  String get _areasStr {
    var str = "{\n";
    areas.forEach((key, value) {
      str += '    $key : $value';
    });
    str += "}";
    return str;
  }
}
