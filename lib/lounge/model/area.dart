import 'package:hive/hive.dart';
import 'classroom.dart';

class Area {
  String id;
  String building;
  Map<String, Classroom> classrooms;

  Area({this.id = '', this.building, this.classrooms});

  static Area fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Area area = Area();
    area.id = map['area_id'] ?? '';
    // var list = map['classrooms'];
    List<Classroom> list = []
      ..addAll((map['classrooms'] as List ?? [])
          .map((e) => Classroom.fromMap(e, aId: area.id)));
    area.classrooms = {};
    for (var room in list) {
      area.classrooms[room.id ?? ''] = room;
    }
    return area;
  }

  Map toJson() => {"area_id": id, "classrooms": classrooms};
}

class AreaAdapter extends TypeAdapter<Area> {
  @override
  final int typeId = 2;

  @override
  Area read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Area()
      ..id = fields[0] as String
      ..building = fields[1] as String
      ..classrooms = (fields[2] as Map)?.cast<String, Classroom>();
  }

  @override
  void write(BinaryWriter writer, Area obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.building)
      ..writeByte(2)
      ..write(obj.classrooms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
