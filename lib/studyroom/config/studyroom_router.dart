import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/building/areas_page.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/building/class_plan_page.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/building/classrooms_page.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/main/main_page.dart';

class StudyRoomRouter {
  static const String areas = 'study_room/areas';
  static const String classrooms = 'study_room/classrooms';
  static const String main = 'study_room/main';
  static const String plan = 'study_room/plan';

  static final Map<String, Widget Function(Object arguments)> routers = {
    areas: (arguments) {
      var building = arguments as Building;
      var firstArea = building.areas[0];
      return firstArea.area_id == null
          ? ClassroomsPage(area: firstArea, id: building.id)
          : AreasPage(building: building);
    },
    classrooms: (arguments) {
      var list = arguments as List;
      var area = list[0] as Area;
      var id = list[1] as String;
      return ClassroomsPage(area: area, id: id);
    },
    main: (arguments){
      HiveManager.install();
      return MainPage();
    },
    plan: (arguments) {
      var list = arguments as List;
      var aId = list[0];
      var bId = list[1];
      var cId = list[2];
      var title = list[3];
      return ClassPlanPage(aId: aId, bId: bId, cId: cId, title: title);
    },
  };
}

