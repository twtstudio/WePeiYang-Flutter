import 'package:hive/hive.dart';

part 'key.g.dart';

@HiveType(typeId: 4)
class Key {

  @HiveField(0)
  String key;

  @HiveField(1)
  DBState dbState;

  Key(this.key, DBState dbState);
}


@HiveType(typeId: 5)
class DBState {
  @HiveField(0)
  bool getDataIsFinished;

  @HiveField(1)
  String updateTime;

  DBState(this.getDataIsFinished,this.updateTime);
}