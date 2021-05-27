import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/service/net/login_api.dart';
import 'package:wei_pei_yang_demo/lounge/service/net/open_api.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';

import 'hive_manager.dart';

class LoungeRepository {
  static bool canLoadLocalData = true;
  static bool canLoadTemporaryData = true;

  static Future<List<Building>> get _getBaseBuildingList async {
    // debugPrint('????????????????? _getBaseBuildingList ?????????????????');
    var response = await openApi.get('getBuildingList');

    List<Building> buildings =
        response.data.map<Building>((b) => Building.fromMap(b)).toList();
    return buildings.where((b) => b.roomCount != 0).toList();
  }

  static Future<List<String>> get favouriteList async {
    // debugPrint('????????????????? favouriteList ?????????????????');
    var response = await loginApi.get('getCollections');
    // await Future.delayed(Duration(seconds: 1));
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.length == 0) {
      return <String>[];
    } else {
      List<String> rooms = pre.first.map((e) => e.toString()).toList();
      // print(rooms);
      return rooms;
    }
  }

  static collect({String id}) async => await loginApi
      .post('addCollection', queryParameters: {'classroom_id': id});

  static unCollect({String id}) async => await loginApi
      .post('deleteCollection', queryParameters: {'classroom_id': id});

  /// 从网络上获取一周的全部数据
  static Stream<MapEntry<int, List<Building>>> _getWeekClassPlan(
      {@required DateTime dateTime}) async* {
    // debugPrint('????????????????? _getWeekClassPlan ?????????????????');
    var thatWeek = await dateTime.convertedWeekAndDay;
    var term = '20212';
    for (var weekday in thatWeek) {
      var requestDate = '$term/${weekday.week}/${weekday.day}';
      // debugPrint('??????????????????' + 'getDayData/$requestDate');
      var response = await openApi.get('getDayData/$requestDate');
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

  static updateLocalData(DateTime dateTime) async {
    if (!dateTime.isBefore22) {
      dateTime = dateTime.next;
    }
    if (HiveManager.instance.shouldUpdateLocalData && canLoadLocalData) {
      canLoadLocalData = !canLoadLocalData;
      // ToastProvider.running('加载数据需要一点时间');
      await _getBaseBuildingList.then((value) async {
        await HiveManager.instance.clearLocalData();
        await HiveManager.instance.writeBaseDataInDisk(buildings: value);
        await _getWeekClassPlan(dateTime: dateTime).toList().then(
            (plans) async {
          await Future.forEach<MapEntry<int, List<Building>>>(
              plans,
              (plan) => HiveManager.instance
                  .writeThisWeekDataInDisk(plan.value, plan.key,dateTime)).then((_) {
            HiveManager.instance.checkBaseDataIsAllInDisk();
          });
          canLoadLocalData = !canLoadLocalData;
          // ToastProvider.success('教室安排加载成功');
        }, onError: (e) {
          throw e;
        });
      }, onError: (e) {
        throw e;
      }).catchError(
        (e) {
          // ToastProvider.error(e.toString().split(':')[1].trim());
          // debugPrint("updatelocaldata error ${e.toString()}");
          canLoadLocalData = !canLoadLocalData;
          throw e;
        },
      );
    }
  }

  static updateTemporaryData(DateTime dateTime) async {
    if (HiveManager.instance.shouldUpdateTemporaryData(dateTime: dateTime) &&
        canLoadTemporaryData) {
      canLoadTemporaryData = !canLoadTemporaryData;
      // ToastProvider.running('加载数据需要一点时间');
      await _getWeekClassPlan(dateTime: dateTime).toList().then((plans) async {
        await HiveManager.instance.changeTemporaryDataStart();
        await Future.forEach<MapEntry<int, List<Building>>>(
            plans,
            (plan) => HiveManager.instance
                .setTemporaryData(data: plan.value, day: plan.key)).then((_) async {
          await HiveManager.instance.setTemporaryDataFinish(dateTime);
        });
        canLoadTemporaryData = !canLoadTemporaryData;
        // ToastProvider.success('教室安排加载成功');
      }, onError: (e) {
        throw e;
      }).catchError((e) {
        // ToastProvider.error(e.toString().split(':')[1].trim());
        // debugPrint("updateTemporaryData error ${e.toString()}");
        canLoadTemporaryData = !canLoadTemporaryData;
        throw e;
      });
    }
  }

  static setLoungeData({@required LoungeTimeModel model}) async {
    var dateTime = model.dateTime;
    try {
      if (dateTime.isThisWeek) {
        await updateLocalData(dateTime);
      } else {
        await updateTemporaryData(dateTime);
      }
    } catch (e) {
      throw e;
      // ToastProvider.error(e.toString());
    }
  }
}
