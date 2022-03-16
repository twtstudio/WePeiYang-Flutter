// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/areas_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/classrooms_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/main_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/room_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/search_page.dart';

class LoungeRouter {
  static const String areas = 'lounge/areas';
  static const String classrooms = 'lounge/classrooms';
  static const String main = 'lounge/main';
  static const String plan = 'lounge/plan';
  static const String search = 'lounge/search';

  static final Map<String, Widget Function(Object? arguments)> routers = {
    areas: (arguments) {
      var bid = arguments.toString();
      return AreasPage(bId: bid);
    },
    classrooms: (arguments) {
      var list = arguments as List;
      var bId = list[0] as String;
      var aId = list[1] as String;
      return ClassroomsPage(bId: bId, aId: aId);
    },
    plan: (arguments) {
      var classroom = arguments as Classroom;
      return RoomPlanPage(room: classroom);
    },
    main: (_) => const MainPage(),
    search: (_) => const SearchPage(),
  };
}
