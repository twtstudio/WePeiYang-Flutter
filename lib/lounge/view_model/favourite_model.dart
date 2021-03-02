import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/service/sr_repository.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class SRFavouriteModel extends ChangeNotifier {
  static final Map<String, Classroom> _map = Map();

  Map<String, Classroom> get favourList => _map;

  static final Map<String, Map<String, List<String>>> _classPlan = {};

  Map<String, Map<String, List<String>>> get classPlan => _classPlan;

  refreshData({bool init = false, DateTime dateTime}) async {
    var instance = HiveManager.instance;
    var localData = await instance.getFavourList();

    if (init) {
      List<Classroom> remoteData = await StudyRoomRepository.favouriteList;
      List<String> remoteIds = remoteData.map((e) => e.id).toList();

      // 添加新的收藏到本地
      for (var room in remoteData) {
        if (!localData.containsKey(room.id)) {
          await instance.addFavourite(room: room);
        }
        _map[room.id] = room;
      }

      // 从本地删除旧的收藏
      for (var room in localData.values) {
        if (!remoteIds.contains(room.id)) {
          await instance.removeFavourite(cId: room.id);
        }
      }
    } else {
      _map.clear();
      _map.addAll(localData);
    }

    for (var room in _map.values) {
      _classPlan[room.id] = await instance.getRoomPlans(
        r: room,
        dateTime: dateTime,
      );
    }
  }

  addFavourite({@required Classroom room}) async {
    var instance = HiveManager.instance;
    await instance.addFavourite(room: room);
    _map.putIfAbsent(room.id, () => room);
    notifyListeners();
  }

  removeFavourite({@required String cId}) async {
    await HiveManager.instance.removeFavourite(cId: cId);
    _map.removeWhere((key, _) => key == cId);
    notifyListeners();
  }

  /// 用于切换用户后,将该用户所有收藏的文章
  replaceAll({@required List<Classroom> list}) async {
    _map.clear();
    await HiveManager.instance.replaceFavourite(list: list);
    list.forEach((room) {
      _map[room.id] = room;
    });
    notifyListeners();
  }

  bool contains({@required String cId}) {
    return _map.containsKey(cId);
  }
}

/// 收藏/取消收藏
class FavouriteModel extends ViewStateModel {
  SRFavouriteModel globalFavouriteModel;

  FavouriteModel({@required this.globalFavouriteModel});

  collect({@required Classroom room}) async {
    setBusy();
    try {
      if (globalFavouriteModel.contains(cId: room.id)) {
        await StudyRoomRepository.unCollect(id: room.id);
        await globalFavouriteModel.removeFavourite(cId: room.id);
      } else {
        await StudyRoomRepository.collect(id: room.id);
        await globalFavouriteModel.addFavourite(room: room);
      }
      setIdle();
    } catch (e, s) {
      setError(e, s);
    }
  }
}

class FavouriteListModel extends ViewStateListModel<Classroom> {
  FavouriteListModel({this.scheduleModel, this.favouriteModel}) {
    scheduleModel.addListener(refresh);
    favouriteModel.addListener(refresh);
    if (favouriteModel.favourList.isNotEmpty)
      scheduleModel.setTime(compareToRemoteData: true);
  }

  final SRTimeModel scheduleModel;
  final SRFavouriteModel favouriteModel;

  int get currentDay => scheduleModel.dateTime.weekday;

  List<ClassTime> get classTime => scheduleModel.classTime;

  List<Classroom> get favourList => favouriteModel.favourList.values.toList();

  Map<String, Map<String, List<String>>> get classPlan =>
      favouriteModel.classPlan;

  @override
  Future<List<Classroom>> loadData() async {
    await favouriteModel.refreshData(
        init: true, dateTime: scheduleModel.dateTime);
    var list = favouriteModel.favourList.values.toList();
    return list;
  }
}

addFavourites(BuildContext context,
    {Classroom room,
    FavouriteModel model,
    Object tag: 'addFavourite',
    bool playAnim: true}) async {
  await model.collect(room: room);
  if (model.isError) {
    model.showErrorMessage();
  } else {
    if (playAnim) {
      // TODO: 这竟然是flare动画，有机会再搞
      ///接口调用成功播放动画
      // Navigator.push(
      //     context,
      //     HeroDialogRoute(
      //         builder: (_) => FavouriteAnimationWidget(
      //           tag: tag,
      //           add: article.collect,
      //         )));
    }
  }
}
