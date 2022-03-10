// @dart = 2.12
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/server/open_api.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

import 'login_api.dart';

class Repository {
  /// 获取基础教学楼及教室数据（无使用信息）
  ///
  /// https://selfstudy.twt.edu.cn/getBuildingList
  static Future<List<Building>> get getBaseBuildingList async {
    var response = await openDio.get('getBuildingList').catchError((e) {
      throw Exception('getBaseBuildingList api error : ${e.toString()}');
    });

    try {
      final buildings = response.data.map<Building>((b) => Building.fromMap(b));
      return buildings.where((b) => b.roomCount != 0).toList();
    } catch (e) {
      throw Exception('getBaseBuildingList parse json error : $e');
    }
  }

  /// 获取指定日期的教室数据（本学期的第几周+周几）
  ///
  /// 如：https://selfstudy.twt.edu.cn/getDayData/21222/1/1
  static Future<MapEntry<int, List<Building>>> getClassroomPlanOfDay(
    PlanDate day,
    String term,
  ) async {
    var requestDate = '$term/${day.week}/${day.day}';
    var response = await openDio.get('getDayData/$requestDate');
    List<Building> buildings =
    response.data.map<Building>((b) => Building.fromMap(b)).toList();
    return MapEntry(
      day.day,
      buildings.where((b) => b.roomCount != 0).toList(),
    );
  }

  /// 获取一周的教室使用数据
  static Stream<MapEntry<int, List<Building>>> getWeekClassPlan(
    DateTime dateTime,
  ) {
    var thatWeek = dateTime.convertedWeekAndDay;
    var term = CommonPreferences().termName.value;
    // for (var weekday in thatWeek) {
    //   yield await getClassroomPlanOfDay(weekday, term);
    // }
    return Stream.fromFutures(
      thatWeek.map((weekday) => getClassroomPlanOfDay(weekday, term)),
    );
  }

  /// 获取收藏的教室id
  static Future<List<String>> get favouriteList async {
    var response = await loginDio.get('getCollections');
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.isEmpty) {
      return <String>[];
    } else {
      return pre.first.map((e) => e.toString()).toList();
    }
  }

  /// 收藏教室
  static collect({String? id}) async => await loginDio
      .post('addCollection', queryParameters: {'classroom_id': id});

  /// 取消收藏教室
  static unCollect({String? id}) async => await loginDio
      .post('deleteCollection', queryParameters: {'classroom_id': id});
}
