// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyAdapter extends TypeAdapter<Key> {
  @override
  final int typeId = 4;

  @override
  Key read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Key(
      fields[0] as String,
      fields[1] as DBState,
    );
  }

  @override
  void write(BinaryWriter writer, Key obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.dbState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DBStateAdapter extends TypeAdapter<DBState> {
  @override
  final int typeId = 5;

  @override
  DBState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DBState(
      fields[0] as bool,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DBState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.getDataIsFinished)
      ..writeByte(1)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
