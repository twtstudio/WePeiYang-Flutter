import 'data.dart';
import 'hive_manager.dart';

class StudyRoomRepository {
  static Future buildingList() async {
    // var response = await open_http.get('api/getBuildingList.php');
    // return response.data.map<Building>((b) => Building.fromMap(b)).toList();

    var buildings = Data.getBuildings();
    var instance = await HiveManager.instance;
    await instance.createBuildingBoxes(buildings);
    for (int i = 0; i < 7; i++) {
      var buildings = Data.getOneDayAvailable(i);
      print(buildings.toString());
      await instance.addClassroomsPlan(buildings, i);
    }

    return buildings;
  }

  static Future favouriteList() async {}

  // 数据库中存这周七天的数据，没有参数就返回这周的数据，有指定日期再获取那周的数据。
  static Future getWeekClassPlan({int term, int week, int day}) async {
    // var response = await open_http.get('api/getDayData.php',queryParameters: {
    //   'term' : term,
    //   'week' : week,
    //   'day' : day
    // });
    // return response.data.map<Building>((b) => Building.fromMap(b)).toList();
    var instance = await HiveManager.instance;

    //只要是这周的任何一天，就返回这周的全部数据

    // for (int i = 0; i < 7; i++) {
    //   var buildings = Data.getOneDayAvailable(i);
    //   await instance.addClassroomsPlan(buildings, i);
    // }
    return Data.getOneDayAvailable(2);
  }
}
