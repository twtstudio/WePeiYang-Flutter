// @dart = 2.12

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
      capacity: fields[2] as int,
      statuses: (fields[3] as Map).cast<int, String>(),
      bId: fields[4] as String,
      aId: fields[5] as String,
      bName: fields[6] as String,
      status: '',
    );
  }

  @override
  void write(BinaryWriter writer, Classroom obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.capacity)
      ..writeByte(3)
      ..write(obj.statuses)
      ..writeByte(4)
      ..write(obj.bId)
      ..writeByte(5)
      ..write(obj.aId)
      ..writeByte(6)
      ..write(obj.bName);
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
