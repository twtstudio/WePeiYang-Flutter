// @dart = 2.12

import 'package:hive/hive.dart';

part 'local_entry.g.dart';

@HiveType(typeId: 4)
class LocalEntry {
  @HiveField(0)
  String key;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dateTime;

  LocalEntry({
    required this.key,
    required this.name,
    required this.dateTime,
  });
}