import 'package:hive/hive.dart';

class Classroom {
  String id;
  String name;
  String capacity;
  String status;
  String bId;
  String aId;

  Classroom(
      {this.id,
      this.name,
      this.capacity,
      this.status = '',
      this.bId = '',
      this.aId = ''});

  static Classroom fromMap(Map<String, dynamic> map,String id) {
    if (map == null) return null;
    Classroom classroom = Classroom();
    classroom.id = map['classroom_id'] ?? '';
    classroom.name = map['classroom'] ?? '';
    classroom.capacity = map['capacity'] ?? '';
    classroom.status = map['status'] ?? '';
    classroom.aId = id ?? '';
    //TODO: 这个大概使不会有的
    // classroom.bId = map['building'];
    // classroom.aId = map['area'];
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
      capacity: fields[2] as String,
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
