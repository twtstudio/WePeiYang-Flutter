// @dart = 2.12

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favour_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavourEntryAdapter extends TypeAdapter<FavourEntry> {
  @override
  final int typeId = 7;

  @override
  FavourEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavourEntry(
      time: fields[0] as String,
      room: fields[1] as Classroom,
      action: fields[2] as String,
      sync: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FavourEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.room)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.sync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavourEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
