// @dart = 2.12
import 'package:hive/hive.dart';

import 'building.dart';

part 'temporary.g.dart';

@HiveType(typeId: 7)
class Buildings {
  @HiveField(0)
  List<Building> buildings;

  Buildings({required this.buildings});
}