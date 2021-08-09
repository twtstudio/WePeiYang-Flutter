import 'package:flutter/widgets.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/ui/page/building/areas_page.dart';
import 'package:we_pei_yang_flutter/lounge/ui/page/building/class_plan_page.dart';
import 'package:we_pei_yang_flutter/lounge/ui/page/building/classrooms_page.dart';
import 'package:we_pei_yang_flutter/lounge/ui/page/main/main_page.dart';

class LoungeRouter {
  static const String areas = 'lounge/areas';
  static const String classrooms = 'lounge/classrooms';
  static const String main = 'lounge/main';
  static const String plan = 'lounge/plan';

  static final Map<String, Widget Function(Object arguments)> routers = {
    areas: (arguments) {
      var building = arguments as Building;
      var firstArea = building.areas.values.first;
      return firstArea.id == '-1'
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
      return MainPage();
    },
    plan: (arguments) {
      var room = arguments as Classroom;
      return ClassPlanPage(room: room);
    },
  };
}

