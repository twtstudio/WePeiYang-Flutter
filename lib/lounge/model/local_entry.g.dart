// @dart = 2.12
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalEntryAdapter extends TypeAdapter<LocalEntry> {
  @override
  final int typeId = 4;

  @override
  LocalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalEntry(
      key: fields[0] as String,
      name: fields[1] as String,
      dateTime: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocalEntryAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
