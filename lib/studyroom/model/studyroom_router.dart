import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/view/page/building_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/page/classroom_detail_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/page/classrooms_page.dart';

class StudyRoomRouter {
  static const String building = 'studyroom/building';
  static const String classrooms = 'studyroom/classrooms';
  static const String detail = 'studyroom/detail';

  static final Map<String, Widget Function(Object? arguments)> routers = {
    building: (arguments) {
      var bid = arguments as int;
      return BuildingPage(bid);
    },
    classrooms: (arguments) {
      var list = arguments as List;
      var bId = list[0] as int;
      var aId = list[1] as int;
      return ClassroomsPage(bId, aId);
    },
    detail: (arguments) {
      var classroom = arguments as Room;
      return StyClassRoomDetailPage(room: classroom);
    },
  };
}
