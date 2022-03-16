// @dart = 2.12

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 6;

  @override
  HistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      bName: fields[0] as String,
      cName: fields[1] as String,
      aId: fields[2] as String,
      bId: fields[3] as String,
      cId: fields[4] as String,
      date: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bName)
      ..writeByte(1)
      ..write(obj.cName)
      ..writeByte(2)
      ..write(obj.aId)
      ..writeByte(3)
      ..write(obj.bId)
      ..writeByte(4)
      ..write(obj.cId)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HistoryEntryAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
