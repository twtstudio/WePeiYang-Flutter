// @dart = 2.12
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      areas: (fields[3] as Map).cast<String, Area>(),
      roomCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.campus)
      ..writeByte(3)
      ..write(obj.areas)
      ..writeByte(4)
      ..write(obj.roomCount);
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
