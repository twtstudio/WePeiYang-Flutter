import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/service/net/lounge_service.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/lounge/service/time_factory.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/lounge_time_model.dart';

import 'hive_manager.dart';

class LoungeRepository {
  static bool canLoadLocalData = true;
  static bool canLoadTemporaryData = true;

  static Future<List<Building>> get _getBaseBuildingList async {
    var response = await openDio.get('getBuildingList');

    List<Building> buildings =
        response.data.map<Building>((b) => Building.fromMap(b)).toList();
    return buildings.where((b) => b.roomCount != 0).toList();
  }

  static Future<List<String>> get favouriteList async {
    var response = await loginDio.get('getCollections');
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.length == 0) {
      return <String>[];
    } else {
      return pre.first.map((e) => e.toString()).toList();
    }
  }

  static collect({String id}) async => await loginDio
      .post('addCollection', queryParameters: {'classroom_id': id});

  static unCollect({String id}) async => await loginDio
      .post('deleteCollection', queryParameters: {'classroom_id': id});

  /// 从网络上获取一周的全部数据
  static Stream<MapEntry<int, List<Building>>> _getWeekClassPlan(
      {@required DateTime dateTime}) async* {
    var thatWeek = dateTime.convertedWeekAndDay;
    var term = CommonPreferences().termName.value;
    for (var weekday in thatWeek) {
      var requestDate = '$term/${weekday.week}/${weekday.day}';
      var response = await openDio.get('getDayData/$requestDate');
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
    dateTime = checkDateTimeAvailable(dateTime);
    if (!dateTime.isBefore22) {
      dateTime = dateTime.next;
    }
    if (HiveManager.instance.shouldUpdateLocalData && canLoadLocalData) {
      canLoadLocalData = !canLoadLocalData;
      try {
        var buildingList = await _getBaseBuildingList;
        await HiveManager.instance.clearLocalData();
        await HiveManager.instance.writeBaseDataInDisk(buildings: buildingList);
        var planList = await _getWeekClassPlan(dateTime: dateTime).toList();
        await Future.forEach<MapEntry<int, List<Building>>>(
            planList,
            (plan) => HiveManager.instance.writeThisWeekDataInDisk(
                plan.value, plan.key, dateTime)).then((_) {
          HiveManager.instance.checkBaseDataIsAllInDisk();
        });
        canLoadLocalData = !canLoadLocalData;
      } catch (e) {
        canLoadLocalData = !canLoadLocalData;
        rethrow;
      }
    }
  }

  static updateTemporaryData(DateTime dateTime) async {
    if (HiveManager.instance.shouldUpdateTemporaryData(dateTime: dateTime) &&
        canLoadTemporaryData) {
      canLoadTemporaryData = !canLoadTemporaryData;
      try {
        var planList = await _getWeekClassPlan(dateTime: dateTime).toList();
        await HiveManager.instance.changeTemporaryDataStart();
        await Future.forEach<MapEntry<int, List<Building>>>(
            planList,
            (plan) => HiveManager.instance.setTemporaryData(
                data: plan.value, day: plan.key)).then((_) async {
          await HiveManager.instance.setTemporaryDataFinish(dateTime);
        });
        canLoadTemporaryData = !canLoadTemporaryData;
      } catch (e) {
        canLoadTemporaryData = !canLoadTemporaryData;
        throw e;
      }
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
    }
  }
}
