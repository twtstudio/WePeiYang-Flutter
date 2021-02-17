import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_refresh_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/service/studyroom_repository.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class SRFavouriteModel extends ChangeNotifier {
  static final Map<String, Classroom> _map = Map();

  Map<String, Classroom> get favourList => _map;

  static final Map<String, Map<String, List<String>>> _classPlan = {};

  Map<String, Map<String, List<String>>> get classPlan => _classPlan;

  refresh({List<Classroom> list, bool init = false}) async {
    var instance = await HiveManager.instance;
    var localData = await instance.getFavourList();

    //TODO: 什么时候加载远程数据
    // 这个地方，由于不会有两个app同时登录一个账号，所以，大概不会出现远程数据变动的情况，
    // 那么就只用在初始化 SRFavouriteModel 的时候加载网络数据
    if (init) {
      var remoteData = await StudyRoomRepository.favouriteList();

      // 添加新的收藏到本地
      for (var room in remoteData) {
        if (!localData.containsKey(room.id)) {
          await instance.addFavourite(room: room);
        }
        _map[room.id] = room;
      }

      // 从本地删除旧的收藏
      for (var room in localData.values) {
        if (!remoteData.contains(room.id)) {
          await instance.removeFavourite(cId: room.id);
        }
      }
    } else {
      _map.clear();
      _map.addAll(localData);
    }

    for (var room in _map.values) {
      _classPlan[room.id] = await instance.getClassPlans(r: room);
    }
  }

  addFavourite({@required Classroom room}) async {
    var instance = await HiveManager.instance;
    await instance.addFavourite(room: room);
    _map[room.id] = room;
    _classPlan[room.id] = await instance.getClassPlans(r: room);
    notifyListeners();
  }

  removeFavourite({@required String cId}) async {
    var instance = await HiveManager.instance;
    await instance.removeFavourite(cId: cId);
    _map.remove(cId);
    _classPlan.remove(cId);
    notifyListeners();
  }

  /// 用于切换用户后,将该用户所有收藏的文章
  replaceAll({@required List<Classroom> list}) async {
    _map.clear();
    var instance = await HiveManager.instance;
    await instance.replaceFavourite(list: list);
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
      // TODO: 忽然发现一个问题，没有上传收藏数据的接口 QAQ
      // 那就先做本地处理；
      if (globalFavouriteModel.contains(cId: room.id)) {
        await StudyRoomRepository.unCollect(id: room.id);
        globalFavouriteModel.removeFavourite(cId: room.id);
      } else {
        await StudyRoomRepository.collect(id: room.id);
        globalFavouriteModel.addFavourite(room: room);
      }
      setIdle();
    } catch (e, s) {
      setError(e, s);
    }
  }
}

class FavouriteListModel extends ViewStateListModel<Classroom> {
  FavouriteListModel({this.scheduleModel, this.favouriteModel});

  SRTimeModel scheduleModel;
  SRFavouriteModel favouriteModel;

  int get currentDay => scheduleModel.currentDay;
  Schedule get schedule => scheduleModel.schedule;
  List<Classroom> get favourList => favouriteModel.favourList.values.toList();
  Map<String, Map<String, List<String>>> get classPlan => favouriteModel.classPlan;

  // @override
  // void onError(ViewStateError viewStateError) {
  //   super.onError(viewStateError);
  //   if (viewStateError.isUnauthorized) {
  //     loginModel.logout();
  //   }
  // }

  @override
  Future<List<Classroom>> loadData() async {
    await favouriteModel.refresh(init: true);
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
    if (model.viewStateError.isUnauthorized) {
      // TODO: token会过期，这个之后来写，还得问问崔神咋搞
      // if (await DialogHelper.showLoginDialog(context)) {
      //   var success = await Navigator.pushNamed(context, RouteName.login);
      //   if (success ?? false) {
      //     //登录后,判断是否已经收藏
      //     if (!Provider.of<UserModel>(context, listen: false)
      //         .user
      //         .collectIds
      //         .contains(article.id)) {
      //       addFavourites(context, article: article, model: model, tag: tag);
      //     }
      //   }
      // }
    } else {
      model.showErrorMessage(context);
    }
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
