import 'package:hive/hive.dart';
import 'area.dart';

class Building {
  String id;
  String name;
  String campus;
  Map<String, Area> areas;
  int roomCount;

  Building({this.id, this.name, this.campus, this.areas});

  static Building fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Building building = Building();
    building.id = map['building_id'] ?? '';
    building.name = map['building'] ?? '';
    building.campus = map['campus_id'] ?? '';
    List<Area> list = List()
      ..addAll((map['areas'] as List ?? []).map((e) => Area.fromMap(e)));
    building.roomCount = 0;
    building.areas = {};
    for (var area in list) {
      building.areas[area.id ?? ''] = area;
      building.roomCount += area.classrooms?.length ?? 0;
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

class BuildingAdapter extends TypeAdapter<Building> {
  @override
  final int typeId = 1;

  @override
  Building read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Building(
      id: fields[0] as String,
      name: fields[1] as String,
      campus: fields[2] as String,
      areas: (fields[3] as Map)?.cast<String, Area>(),
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.campus)
      ..writeByte(3)
      ..write(obj.areas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
