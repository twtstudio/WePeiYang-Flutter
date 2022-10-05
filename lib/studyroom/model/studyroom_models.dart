// @dart=2.12
// To parse this JSON data, do
//
//     final buildingResponse = buildingResponseFromJson(jsonString);

import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_campus.dart';

class Building {
  Building({
    this.buildingId,
    this.areas,
    this.building,
    this.campusId,
  });

  final String? buildingId;
  final List<Area>? areas;
  final String? building;
  final String? campusId;

  String get name {
    if (this.building == null || this.building! == '') return '';
    // 只捕获数字
    return this.building!.find('(\\d+)');
  }

  String get id => this.buildingId ?? '';

  bool get isWjl => (campusId ?? '') == Campus.wjl.id;

  bool get isByy => (campusId ?? '') == Campus.byy.id;

  bool get hasRoom {
    var cnt = 0;
    areas?.forEach((element) => cnt += (element.classrooms ?? []).length);
    return cnt != 0;
  }

  factory Building.fromRawJson(String str) =>
      Building.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        buildingId: json["building_id"],
        areas: List<Area>.from(json["areas"].map((x) => Area.fromJson(x))),
        building: json["building"],
        campusId: json["campus_id"],
      );

  Map<String, dynamic> toJson() => {
        "building_id": buildingId,
        "areas": List<dynamic>.from(areas?.map((x) => x.toJson()) ?? []),
        "building": building,
        "campus_id": campusId,
      };
}

class Area {
  Area({
    this.areaId,
    this.classrooms,
  });

  final String? areaId;
  final List<Classroom>? classrooms;

  String get id => this.areaId ?? '';

  Map<String, List<Classroom>> floors = {};

  Map<String, List<Classroom>> _sortByFloor(Map<String, List<Classroom>> f) {
    List<String> list = f.keys.toList();
    list.sort((a, b) => a.compareTo(b));
    return Map.fromEntries(list.map(
      (e) {
        List<Classroom> cList = f[e]!;
        cList.sort((a, b) => a.name.compareTo(b.name));
        return MapEntry(e, cList);
      },
    ));
  }

  void splitFloors() {
    Map<String, List<Classroom>> f = {};
    if (classrooms == null) return;
    for (var c in classrooms!) {
      var floor = c.name[0];
      c.areaId = id;
      if (f.containsKey(floor)) {
        var list = <Classroom>[...f[floor]!, c];
        f[floor] = list;
      } else {
        f[floor] = [c];
      }
    }
    floors = _sortByFloor(f);
  }

  factory Area.fromRawJson(String str) => Area.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        areaId: json["area_id"] == null ? null : json["area_id"],
        classrooms: json["classrooms"] == null
            ? null
            : List<Classroom>.from(
                json["classrooms"].map((x) => Classroom.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "area_id": areaId == null ? null : areaId,
        "classrooms": classrooms == null
            ? null
            : List<dynamic>.from(classrooms?.map((x) => x.toJson()) ?? []),
      };
}

class Classroom {
  Classroom({
    this.classroomId,
    this.classroom,
    this.status,
  });

  final String? classroomId;
  final String? classroom;
  final String? status;

  String get id => this.classroomId ?? '';
  String get name => this.classroom ?? '';

  Map<int, String> statuses = {
    1: '111111111111',
    2: '111111111111',
    3: '111111111111',
    4: '111111111111',
    5: '111111111111',
    6: '111111111111',
    7: '111111111111',
  };
  String buildingName = '';
  String areaId = '';

  String get title {
    var title = '${buildingName}教';
    if (areaId != '-1') {
      title += areaId;
    }
    title += name;
    return title;
  }

  factory Classroom.fromRawJson(String str) =>
      Classroom.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Classroom.fromJson(Map<String, dynamic> json) => Classroom(
        classroomId: json["classroom_id"],
        classroom: json["classroom"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "classroom_id": classroomId,
        "classroom": classroom,
        "status": status,
      };
}
