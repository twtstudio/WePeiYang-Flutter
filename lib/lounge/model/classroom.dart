import 'package:hive/hive.dart';

class Classroom {
  String id;
  String name;
  int capacity;
  String status;
  String bId;
  String aId;
  String bName;

  Classroom(
      {this.id,
      this.name,
      this.capacity,
      this.status = '',
      this.bId = '',
      this.aId = '',
      this.bName = ''});

  static Classroom fromMap(Map<String, dynamic> map, {String aId}) {
    if (map == null) return null;
    Classroom classroom = Classroom();
    classroom.id = map['classroom_id'] ?? '';
    classroom.capacity = map['capacity'] ?? 0;
    classroom.status = map['status'] ?? '';
    classroom.name = map['classroom'] ?? '';
    classroom.aId = aId ?? '';

    return classroom;
  }

  Map toJson() =>
      {"id": id, "name": name, "capacity": capacity, 'bId': bId, 'aId': aId};
}

class ClassroomAdapter extends TypeAdapter<Classroom> {
  @override
  final int typeId = 3;

  @override
  Classroom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Classroom(
      id: fields[0] as String,
      name: fields[1] as String,
      capacity: fields[2] as int,
      status: fields[3] as String,
      bId: fields[4] as String,
      aId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Classroom obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.capacity)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.bId)
      ..writeByte(5)
      ..write(obj.aId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ClassroomAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
