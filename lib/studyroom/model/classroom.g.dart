// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
    );
  }

  @override
  void write(BinaryWriter writer, Classroom obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.capacity)
      ..writeByte(3)
      ..write(obj.status);
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
