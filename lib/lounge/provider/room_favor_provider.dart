// @dart = 2.12

import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/model/favour_entry.dart';
import 'package:we_pei_yang_flutter/lounge/provider/data_state.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/provider/sync_action.dart';
import 'package:we_pei_yang_flutter/lounge/server/error.dart';
import 'package:we_pei_yang_flutter/lounge/server/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/server/login_api.dart';

// 认为本地数据才是最重要的，服务器数据只是为了同步
// TODO: LoungeDataStateMixin
class RoomFavour extends LoadStateChangeNotifier with LoungeDataStateMixin {
  Map<String, Classroom> _favours = {};

  /// 收藏列表
  Map<String, Classroom> get favourList => _favours;

  Future<void> init() async {
    if(loadState.isInit || loadState.isError){
      await refreshData();
    }
  }

  /// 刷新收藏数据
  Future<void> refreshData() async {
    if (loadState.isRefresh) return;

    stateRefreshing();
    var localData = LoungeDB().db.favourList;

    List<SyncAction> getFavoursSuccess(List<String> remoteData) {
      final actions = <SyncAction>[];

      // 添加新的收藏到本地
      for (var id in remoteData) {
        // 如果本地包含这个教室，则添加到列表中
        // 如果本地不包含这个教室，那么就认为是需要添加到本地
        if (localData.containsKey(id)) {
          final entry = localData[id]!;
          // 只有同步了的数据才添加到列表中
          if (!entry.isNotSync) {
            _favours[id] = entry.room;
          } else if (entry.toCollect) {
            // 服务器有，本地有收藏未同步记录
            _favours[id] = entry.room;
            actions.add(SyncAction.deleteLocalRecord(entry));
          } else if (entry.toDelete) {
            // 服务器有，本地有删除未同步的记录
            actions.add(SyncAction.deleteRemoteCollection(entry));
          }
          localData.remove(id);
        } else {
          final room = LoungeDB().db.findRoomById(id);
          if (room != null) {
            _favours[id] = room;
            // 服务器有，本地没有记录
            actions.add(
              SyncAction.addLocalCollection(
                FavourEntry.collect(room, DateTime.now()),
              ),
            );
            localData.remove(id);
          } else {
            // 本地也没有这个教室
            // 1. 本地数据库不是最新的
            // 2. 收藏数据太老了
          }
        }
      }

      // 根据剩余的本地数据，对服务器做同步（database -> network）
      for (var entry in localData.entries) {
        if (entry.value.toCollect) {
          _favours[entry.key] = entry.value.room;
          // 服务器没有，本地有收藏未同步记录
          actions.add(SyncAction.addRemoteCollection(entry.value));
        } else if (entry.value.toDelete) {
          // 服务器没有，本地有删除未同步记录
          actions.add(SyncAction.deleteLocalRecord(entry.value));
        }
      }

      // 这里只设置当前数据状态为最新，但是由于未同步数据库，所以不设置刷新时间
      dataUpdated();
      stateSuccess('update _favours success');

      return actions;
    }

    List<SyncAction> getFavoursFailure(error, stack) {
      // 加载本地数据
      localData.forEach((key, entry) {
        if (entry.toCollect) {
          _favours[key] = entry.room;
        }
      });

      // 获取服务器数据错误
      final e = LoungeError.network(
        error,
        stackTrace: stack,
        des: 'get remote favour data error',
      );

      if (_favours.isEmpty) {
        dataEmpty(e);
      } else {
        dataOutdated(e);
      }
      stateError();

      return [];
    }

    // 如果 syncs 不为空，则必定是成功请求到了远程数据，那么就同步本地数据
    Future<void> syncActions(List<SyncAction> syncs) async {
      for (var action in syncs) {
        await action.sync();
      }
    }

    // 同步的时候出了错，只能是写入数据库出错，因为网络错误已经拦截
    void syncError(e, s) {
      LoungeError.database(
        e,
        stackTrace: s,
        des: 'sync action to database error',
      ).report();
    }

    await LoungeLoginApi.favouriteList
        .then(getFavoursSuccess, onError: getFavoursFailure)
        .then(syncActions)
        .catchError(syncError);

  }

  /// 点击收藏按钮
  Future<void> changeFavor(Classroom room) async {
    if (_favours.keys.contains(room.id)) {
      await delete(room);
    } else {
      await collect(room);
    }
  }

  /// 收藏（以本地数据为准）
  Future<void> collect(Classroom room) async {
    final current = DateTime.now();

    void writeInDB(bool sync) async {
      await LoungeDB().db.collect(current, room: room, sync: sync).then((_) {
        favourList.putIfAbsent(room.id, () => room);
      }).catchError((e, s) {
        LoungeError.database(
          e,
          stackTrace: s,
          des: 'collect data memory error',
        ).report();
        ToastProvider.error('收藏失败');
      });
    }

    // 如果同步成功，则在本地保留
    await LoungeLoginApi.collect(room.id, current)
        .then(writeInDB)
        .whenComplete(() => notifyListeners());
  }

  /// 取消收藏（以本地数据为准）
  Future<void> delete(Classroom room) async {
    void writeInDB(DateTime? time) async {
      await LoungeDB().db.delete(room, time: time).then((_) {
        favourList.remove(room.id);
      }).catchError((e, s) {
        LoungeError.database(
          e,
          stackTrace: s,
          des: 'collect data memory error',
        ).report();
        ToastProvider.error('取消收藏失败');
      });
    }

    // 如果同步成功了，则直接在本地删除
    // 如果没有同步成功，则在本地保留删除记录，刷新数据时同步
    await LoungeLoginApi.delete(room.id)
        .then(writeInDB)
        .whenComplete(() => notifyListeners());
  }

  /// 用于切换用户后,将该用户所有收藏的文章
  Future<void> replaceAll(List<Classroom> list) async {
    favourList.clear();
    await LoungeDB().db.updateFavourites(list, DateTime.now());
    for (var room in list) {
      _favours[room.id] = room;
    }
    notifyListeners();
  }
}
