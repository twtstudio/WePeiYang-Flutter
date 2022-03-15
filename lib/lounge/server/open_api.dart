// @dart = 2.12

import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

import 'base_server.dart';

class OpenDio extends DioAbstract {
  @override
  String get baseUrl => 'https://selfstudy.twt.edu.cn/';

  @override
  List<InterceptorsWrapper> get interceptors => [ApiInterceptor()];
}

final openDio = OpenDio();

class OpenApi {
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
    final requestDate = '$term/${day.week}/${day.day}';
    final response = await openDio.get('getDayData/$requestDate');
    List<Building> buildings =
        response.data.map<Building>((b) => Building.fromMap(b)).toList();
    return MapEntry(
      day.day,
      buildings.where((b) => b.roomCount != 0).toList(),
    );
  }

  /// 获取一周的教室使用数据
  static Stream<MapEntry<int, List<Building>>> getWeekClassPlan(DateTime t) {
    final thatWeek = t.convertedWeekAndDay;
    final term = CommonPreferences().termName.value;
    return Stream.fromFutures(
      thatWeek.map((weekday) => getClassroomPlanOfDay(weekday, term)),
    );
  }
}
