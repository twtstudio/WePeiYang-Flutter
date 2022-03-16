// @dart = 2.12

import 'package:we_pei_yang_flutter/lounge/model/favour_entry.dart';
import 'package:we_pei_yang_flutter/lounge/server/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/server/login_api.dart';

enum _FavourSyncAction {
  /// 服务器有，本地有收藏未同步记录 或 服务器没有，本地有删除未同步记录
  deleteLocalRecord,

  /// 服务器有，本地有删除未同步的记录
  deleteRemoteCollection,

  /// 服务器有，本地没有记录
  addLocalCollection,

  /// 服务器没有，本地有收藏未同步记录
  addRemoteCollection,
}

class SyncAction {
  final _FavourSyncAction action;
  final FavourEntry favour;

  SyncAction._(this.action, this.favour);

  factory SyncAction.deleteLocalRecord(FavourEntry e) {
    return SyncAction._(_FavourSyncAction.deleteLocalRecord, e);
  }

  factory SyncAction.deleteRemoteCollection(FavourEntry e) {
    return SyncAction._(_FavourSyncAction.deleteRemoteCollection, e);
  }

  factory SyncAction.addLocalCollection(FavourEntry e) {
    return SyncAction._(_FavourSyncAction.addLocalCollection, e);
  }

  factory SyncAction.addRemoteCollection(FavourEntry e) {
    return SyncAction._(_FavourSyncAction.addRemoteCollection, e);
  }

  Future<void> sync() async {
    switch (action) {
      case _FavourSyncAction.deleteLocalRecord:
        // 删除未同步的收藏或删除记录
        await LoungeDB().db.delete(favour.room);
        break;
      case _FavourSyncAction.addLocalCollection:
        await LoungeDB().db.collect(favour.dateTime, room: favour.room);
        break;
      case _FavourSyncAction.deleteRemoteCollection:
        await deleteRemoteCollection();
        break;
      case _FavourSyncAction.addRemoteCollection:
        await addRemoteCollection();
        break;
    }
  }

  /// 删除服务器上的教室收藏
  Future<void> deleteRemoteCollection() async {
    // 如果成功的话，就更新本地的记录
    final syncSuccess = (_) async {
      await LoungeDB().db.delete(favour.room);
    };

    // 如果失败，就啥也不干
    final syncFailure = (_) {};

    await LoungeLoginApi.delete(
      favour.room.id,
    ).then(syncSuccess, onError: syncFailure);
  }

  /// 向服务器添加收藏
  Future<void> addRemoteCollection() async {
    // 如果成功的话，就更新本地的记录
    final syncSuccess = (_) async {
      await LoungeDB().db.collect(favour.dateTime, room: favour.room);
    };

    // 如果失败，就啥也不干
    final syncFailure = (_) {};

    await LoungeLoginApi.collect(
      favour.room.id,
      favour.dateTime,
    ).then(syncSuccess, onError: syncFailure);
  }
}
