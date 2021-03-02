import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/net/open_api.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';
import 'hive_manager.dart';

class StudyRoomRepository {
  static Future<List<Building>> get _getBaseBuildingList async {
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
    var term = '20211';
    for (var weekday in thatWeek) {
      var requestDate = '$term/${weekday.week - 10}/${weekday.day}';
      debugPrint('??????????????????' + 'getDayData/$requestDate');
      var response = await open_http
          .get('getDayData/$requestDate');
      try {
        List<Building> buildings =
            response.data.map<Building>((b) => Building.fromMap(b)).toList();
        yield MapEntry(
          weekday.day,
          buildings.where((b) => b.roomCount != 0).toList(),
        );
      } catch (e) {
        throw (Exception('$requestDate:数据解析错误'));
      }
    }
  }

  static setSRData({@required SRTimeModel model}) async {
    var dateTime = model.dateTime;
    if (dateTime.isThisWeek) {
      if (HiveManager.instance.shouldUpdateLocalData()) {
        await _getBaseBuildingList.then((value) async {
          await HiveManager.instance.clearLocalData();
          await HiveManager.instance.writeBaseDataInDisk(buildings: value);
          await _getWeekClassPlan(dateTime: dateTime).forEach((plan) async {
            HiveManager.instance.writeThisWeekDataInDisk(plan.value, plan.key);
          }).then((_) => ToastProvider.success('教室安排加载成功'), onError: (e) {
            // TODO: 这个地方有问题，如果新的数据中间出了问题，那么现在就是新老数据混杂，
            // TODO：感觉应该在数据库中做一个缓存，不是临时数据，是写入数据库的缓存。
            ToastProvider.error(e.toString().split(':')[1].trim());
          });
        }, onError: (e) {
          ToastProvider.error('基础数据解析错误');
          throw(e);
        });
      }
    } else {
      if (HiveManager.instance.shouldUpdateTemporaryData(dateTime: dateTime)) {
        await _getWeekClassPlan(dateTime: dateTime).forEach((plan) async {
          await HiveManager.instance
              .setTemporaryData(data: plan.value, day: plan.key);
          // debugPrint("not this week : " + dateTime.toString());
        }).then((_) => ToastProvider.success('教室安排加载成功'), onError: (e) {
          // TODO: 这地方也是，同上
          ToastProvider.error(e.toString().split(':')[1].trim());
          throw(e);
        });
      }
    }
  }
}
