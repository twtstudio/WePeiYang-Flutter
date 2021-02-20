import 'package:hive/hive.dart';

part 'local_entry.g.dart';

@HiveType(typeId: 4)
class LocalEntry {

  @HiveField(0)
  String key;

  @HiveField(1)
  String dateTime;

  LocalEntry(this.key, this.dateTime);
}
