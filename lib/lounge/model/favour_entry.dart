// @dart = 2.12

import 'package:hive/hive.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';

part 'favour_entry.g.dart';

@HiveType(typeId: 7)
class FavourEntry {
  @HiveField(0)
  final String time;

  @HiveField(1)
  final Classroom room;

  @HiveField(2)
  final String action;

  @HiveField(3)
  final bool sync;

  FavourEntry({
    required this.time,
    required this.room,
    required this.action,
    required this.sync,
  });

  factory FavourEntry.delete(Classroom r, DateTime t) {
    return FavourEntry(
      time: t.toString(),
      room: r,
      action: _delete,
      sync: false,
    );
  }

  factory FavourEntry.collect(Classroom r, DateTime t, {bool sync = true}) {
    return FavourEntry(
      time: t.toString(),
      room: r,
      action: _collect,
      sync: sync,
    );
  }

  bool get isNotSync => !sync;

  DateTime get dateTime => DateTime.parse(time);

  bool get toDelete => action == _delete;

  bool get toCollect => action == _collect;
}

const _delete = 'delete';

const _collect = 'collect';
