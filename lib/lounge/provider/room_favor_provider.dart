// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/server/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/server/repository.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';

class RoomFavorProvider extends ChangeNotifier {
  Map<String, Classroom>? _map;

  Map<String, Classroom> get favourList => _map ?? {};

  bool get success => _map != null;

  static final Map<String, Map<int, List<String>>> _classPlan = {};

  Map<String, Map<int, List<String>>> get classPlan => _classPlan;

  refreshData({required DateTime dateTime}) async {
    var localData = await LoungeDB().db.favourList;

    try {
      _map = {};

      List<String> remoteIds = await Repository.favouriteList;

      // 添加新的收藏到本地
      for (var id in remoteIds) {
        if (!localData.containsKey(id)) {
          final room = await LoungeDB().db.addFavourite(id: id);
          if (room != null) {
            _map![id] = room;
          }
          continue;
        }
        _map![id] = localData[id]!;
      }

      // 添加本地新的收藏到服务器
      for (var room in _map!.values) {
        if (!remoteIds.contains(room.id)) {
          await Repository.collect(id: room.id);
        }
      }
    } catch (e) {
      // throw e;

      _map!.clear();
      // if(localData.isEmpty){
      //   throw Exception("网络未连接");
      // }
      _map!.addAll(localData);
    }

    for (var room in _map!.values) {
      _classPlan[room.id] = await LoungeDB().db.readRoomPlan(
            room: room,
            dateTime: dateTime,
          );
    }

    notifyListeners();
  }

  Future<void> changeFavor(Classroom room) async {
    if (_map?.keys.contains(room.id) ?? false) {
      await removeFavourite(room.id);
    } else {
      await addFavourite(room);
    }
  }

  Future<void> addFavourite(Classroom room) async {
    await LoungeDB().db.addFavourite(room: room);
    _map!.putIfAbsent(room.id, () => room);
    notifyListeners();
  }

  Future<void> removeFavourite(String rId) async {
    await LoungeDB().db.removeFavourite(rId);
    _map!.remove(rId);
    notifyListeners();
  }

  /// 用于切换用户后,将该用户所有收藏的文章
  replaceAll({required List<Classroom> list}) async {
    _map!.clear();
    await LoungeDB().db.replaceFavourite(list);
    for (var room in list) {
      _map![room.id] = room;
    }
    notifyListeners();
  }

  bool contains({required String? cId}) {
    return _map!.containsKey(cId);
  }
}
