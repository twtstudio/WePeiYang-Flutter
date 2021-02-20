import 'package:hive/hive.dart';

import 'building.dart';

class Buildings {
  List<Building> buildings;

  Buildings({this.buildings});
}

class BuildingsAdapter extends TypeAdapter<Buildings> {
  @override
  final int typeId = 7;

  @override
  Buildings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Buildings(buildings: (fields[0] as List)?.cast<Building>());
  }

  @override
  void write(BinaryWriter writer, Buildings obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.buildings);
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