import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/net/open_api.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';
import 'hive_manager.dart';

class LoungeRepository {
  static Future<List<Building>> get _getBaseBuildingList async {
    debugPrint('??????????????????????????????????????????????????????????'
        '?????????????????????????????????????????????????????????????????'
        '????????????????????????????????? getBaseBuildingList !!!!!!!!!!!!!!!!!!!!!!'
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    var response = await server.get('getBuildingList');

    List<Building> buildings =
        response.data.map<Building>((b) => Building.fromMap(b)).toList();
    return buildings.where((b) => b.roomCount != 0).toList();
  }

  //TODO: 后端没给搜藏接口
  static Future<List<Classroom>> get favouriteList async {
    // 这里应该是访问服务器数据，然后在SRFavouriteModel的refresh中对比数据
    var instance = HiveManager.instance;
    var data = await instance.getFavourList();
    List<Classroom> list = data.values.toList();
    return list;
  }

  static Future collect({String id}) async {}

  static Future unCollect({String id}) async {}

  /// 从网络上获取一周的全部数据
  static Stream<MapEntry<int, List<Building>>> _getWeekClassPlan(
      {@required DateTime dateTime}) async* {
    debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' +
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' +
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! getWeekClassPlan ??????????????????????' +
        '??????????????????????????????????????????????????????????????????????' +
        '??????????????????????????????????????????????????????????????????????');
    var thatWeek = await dateTime.convertedWeekAndDay;
    var term = '20212';
    for (var weekday in thatWeek) {
      var requestDate = '$term/${weekday.week}/${weekday.day}';
      debugPrint('??????????????????' + 'getDayData/$requestDate');
      var response = await server.get('getDayData/$requestDate');
      try {
        List<Building> buildings =
            response.data.map<Building>((b) => Building.fromMap(b)).toList();
        yield MapEntry(
          weekday.day,
          buildings.where((b) => b.roomCount != 0).toList(),
        );
      } catch (e) {
        throw Exception('$requestDate:数据解析错误');
      }
    }
  }

  static setLoungeData({@required LoungeTimeModel model}) async {
    var dateTime = model.dateTime;
    if (dateTime.isThisWeek) {
      if (HiveManager.instance.shouldUpdateLocalData) {
        ToastProvider.running('加载数据需要一点时间');
        await _getBaseBuildingList.then((value) async {
          await HiveManager.instance.clearLocalData();
          await HiveManager.instance.writeBaseDataInDisk(buildings: value);
          await _getWeekClassPlan(dateTime: dateTime).toList().then(
              (plans) async {
            await Future.forEach<MapEntry<int, List<Building>>>(
                plans,
                (plan) => HiveManager.instance
                    .writeThisWeekDataInDisk(plan.value, plan.key)).then((_) {
              HiveManager.instance.checkBaseDataIsAllInDisk();
            });
            ToastProvider.success('教室安排加载成功');
          }, onError: (e) {
            ToastProvider.error(e.toString().split(':')[1].trim());
            throw e;
          });
        }, onError: (e) {
          ToastProvider.error('基础数据解析错误');
          throw e;
        });
      }
    } else {
      if (HiveManager.instance.shouldUpdateTemporaryData(dateTime: dateTime)) {
        ToastProvider.running('加载数据需要一点时间');
        await HiveManager.instance.setTemporaryDataStart();
        await _getWeekClassPlan(dateTime: dateTime).toList().then(
            (plans) async {
          await Future.forEach<MapEntry<int, List<Building>>>(
              plans,
              (plan) => HiveManager.instance
                  .setTemporaryData(data: plan.value, day: plan.key)).then((_) {
            HiveManager.instance.setTemporaryDataFinish();
          });
          ToastProvider.success('教室安排加载成功');
        }, onError: (e) {
          // TODO: 这地方也是，同上
          ToastProvider.error(e.toString().split(':')[1].trim());
          throw e;
        });
      }
    }
  }
}
