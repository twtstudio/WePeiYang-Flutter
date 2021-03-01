import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/net/open_api.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';
import 'hive_manager.dart';

class StudyRoomRepository {
  static Future _getBaseBuildingList() async {
    debugPrint('??????????????????????????????????????????????????????????'
        '?????????????????????????????????????????????????????????????????'
        '????????????????????????????????? getBaseBuildingList !!!!!!!!!!!!!!!!!!!!!!'
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    var response = await open_http.get('getBuildingList');
    List<Building> buildings =
        response.data.map<Building>((b) => Building.fromMap(b)).toList();
    return buildings.where((b) => b.roomCount != 0).toList();
  }

  static Future<List<Classroom>> favouriteList() async {
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
    var term = '20211';
    for (var weekday in thatWeek) {
      debugPrint('??????????????????'+'getDayData/$term/${weekday.week-10}/${weekday.day}');
      var response = await open_http
          .get('getDayData/$term/${weekday.week-10}/${weekday.day}');
      List<Building> buildings =
          response.data.map<Building>((b) => Building.fromMap(b)).toList();
      yield MapEntry(
        weekday.day,
        buildings.where((b) => b.roomCount != 0).toList(),
      );
    }
  }

  static setSRData({@required SRTimeModel model}) async {
    var dateTime = model.dateTime;
    if (dateTime.isThisWeek) {
      if (HiveManager.instance.shouldUpdateLocalData()) {
        var buildings = await _getBaseBuildingList();
        await HiveManager.instance.clearLocalData();
        await HiveManager.instance.writeBaseDataInDisk(buildings: buildings);
        await _getWeekClassPlan(dateTime: dateTime).forEach((plan) async {
          HiveManager.instance.writeThisWeekDataInDisk(plan.value, plan.key);
        });
      }
    } else {
      if (HiveManager.instance.shouldUpdateTemporaryData(dateTime: dateTime)) {
        await _getWeekClassPlan(dateTime: dateTime).forEach((plan) async {
          await HiveManager.instance
              .setTemporaryData(data: plan.value, day: plan.key);
          print("not this week : " + dateTime.toString());
        });
      }
    }
  }
}
