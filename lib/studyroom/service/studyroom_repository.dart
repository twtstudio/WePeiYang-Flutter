import 'package:flutter/cupertino.dart';
import 'package:wei_pei_yang_demo/studyroom/config/net/open_api.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';

import 'data.dart';
import 'hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';

class StudyRoomRepository {
  static Future buildingList() async {
    // var response = await open_http.get('api/getBuildingList.php');
    // return response.data.map<Building>((b) => Building.fromMap(b)).toList();

    var buildings = Data.getBuildings();
    var instance = await HiveManager.instance;
    print('hive init finish');
    await instance.createBuildingBoxes(buildings);

    instance.clearClassroomPlan();
    // 数据库中保存这七天的数据
    for (int i = 0; i < 7; i++) {
      var buildings = Data.getOneDayAvailable(i);
      print(buildings.toString());
      await instance.addClassroomsPlan(buildings, i);
    }

    return buildings;
  }

  static Future<List<Classroom>> favouriteList() async {
    // 这里应该是访问服务器数据，然后在SRFavouriteModel的refresh中对比数据
    var instance = await HiveManager.instance;
    print('hive init finish');
    var data = await instance.getFavourList();
    List<Classroom> list = data.values.toList();
    return list;
  }

  static Future collect({String id}) async {}

  static Future unCollect({String id}) async {}

  // 数据库中存这周七天的数据，没有参数就返回这周的数据，有指定日期再获取那周的数据。
  static Future getWeekClassPlan({DateTime dateTime}) async {
    // var response = await open_http.get('api/getDayData.php',queryParameters: {
    //   'term' : term,
    //   'week' : week,
    //   'day' : day
    // });
    // return response.data.map<Building>((b) => Building.fromMap(b)).toList();
    var instance = await HiveManager.instance;
    if(dateTime.isThisWeek){
      for (int i = 0; i < 7; i++) {
        var buildings = Data.getOneDayAvailable(i);
        print(buildings.toString());
        await instance.addClassroomsPlan(buildings, i);
      }
    }
    return Data.getOneDayAvailable(dateTime.weekday);
  }
}
