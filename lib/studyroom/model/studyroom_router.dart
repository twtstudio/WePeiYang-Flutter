import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/view/page/areas_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/page/classroom_detail_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/page/classrooms_page.dart';

class StudyRoomRouter {
  static const String areas = 'studyroom/areas';
  static const String classrooms = 'studyroom/classrooms';
  static const String detail = 'studyroom/detail';

  static final Map<String, Widget Function(Object? arguments)> routers = {
    areas: (arguments) {
      var bid = arguments as String;
      return AreasPage(bid);
    },
    classrooms: (arguments) {
      var list = arguments as List;
      var bId = list[0] as String;
      var aId = list[1] as String;
      return ClassroomsPage(bId, aId);
    },
    detail: (arguments) {
      var classroom = arguments as Classroom;
      return StyClassRoomDetailPage(room: classroom);
    },
  };
}
