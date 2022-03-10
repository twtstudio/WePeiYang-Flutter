// @dart = 2.12

import 'package:hive/hive.dart';

import 'classroom.dart';

part 'area.g.dart';

@HiveType(typeId: 2)
class Area {
  @HiveField(0)
  String id;

  @HiveField(1)
  String building;

  @HiveField(2)
  Map<String, Classroom> classrooms;

  String bId;

  Area({
    required this.id,
    required this.building,
    required this.classrooms,
    this.bId = '',
  });

  factory Area.fromMap(Map<String, dynamic> map, String bName, String bId) {
    final String id = map['area_id'] ?? '';

    final List<Classroom> list = [
      ...(map['classrooms'] as List? ?? []).map(
        (e) => Classroom.fromMap(e, aId: id, bId: bId, bName: bName),
      )
    ];

    final Map<String, Classroom> classrooms = {};

    for (var room in list) {
      classrooms[room.id] = room;
    }

    return Area(
      id: id,
      building: bName,
      classrooms: classrooms,
      bId: bId,
    );
  }

  factory Area.empty() {
    return Area(
      id: 'unknown',
      building: 'unknown',
      classrooms: {},
    );
  }

  Map<String, List<Classroom>>? _floors;

  Map<String, List<Classroom>> get splitByFloor {
    if (_floors == null) {
      Map<String, List<Classroom>> f = {};

      for (var c in classrooms.values) {
        var floor = c.name[0];
        var room = c..aId = id;
        if (f.containsKey(floor)) {
          var list = <Classroom>[...f[floor]!, room];
          f[floor] = list;
        } else {
          f[floor] = [room];
        }
      }
      _floors = f.sortByFloor;
    }
    return _floors!;
  }

  Map toJson() => {"area_id": id, "classrooms": classrooms.toString()};

  @override
  String toString() => '''
{
      area_id: $id, 
      classrooms: $_classroomsStr,
    }
  ''';

  String get _classroomsStr {
    var str = "[\n";
    classrooms.forEach((_, value) {
      str += '        $value, \n';
    });
    str += "      ]";
    return str;
  }

  @override
  bool operator ==(Object other) =>
      other is Area &&
      other.runtimeType == runtimeType &&
      other.bId == bId &&
      other.building == building &&
      other.id == id &&
      other.classrooms.keys.fold(
        true,
        (previous, key) =>
            previous && (classrooms[key] == other.classrooms[key]),
      );

  @override
  int get hashCode => classrooms.hashCode;

  bool get isEmpty => id == 'unknown' || building == 'unknown';
}

extension MapExtension on Map {
  Map<String, List<Classroom>> get sortByFloor {
    List<String> list = keys.toList() as List<String>;
    list.sort((a, b) => a.compareTo(b));
    return Map.fromEntries(
      list.map(
        (e) {
          List<Classroom> cList = this[e];
          cList.sort((a, b) => a.name.compareTo(b.name));
          return MapEntry(e, cList);
        },
      ),
    );
  }
}
