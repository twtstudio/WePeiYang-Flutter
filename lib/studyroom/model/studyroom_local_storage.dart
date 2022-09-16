// @dart=2.12
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';

class LocalBuildingData {
  LocalBuildingData.data(List<Building> data) {
    this.time = DateTime.now();
    this.data = data;
  }

  LocalBuildingData(String time, List<Building> data) {
    this.time = DateTime.parse(time);
    this.data = data;
  }

  late DateTime time;
  late List<Building> data;

  factory LocalBuildingData.fromRawJson(String str) =>
      LocalBuildingData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LocalBuildingData.fromJson(Map<String, dynamic> json) =>
      LocalBuildingData(
          json["time"],
          List<Building>.from(
            json["data"].map((x) => Building.fromJson(x)),
          ));

  Map<String, dynamic> toJson() => {
        "time": time,
        "data": List<dynamic>.from(data.map((x) => x.toString())),
      };
}

class StudyroomLocal {
  static const STUDYROOM_DIR = 'studyroom';
  static const BUILDING_JSON_NAME = 'buildings.json';
  static const WEEKDATA_JSON_NAME = 'weekdata.json';

  static Future<void> saveBuildings(List<Building> buildings) async {
    final path = await StorageUtil.filesDir;
    final obj = LocalBuildingData.data(buildings);

    final dir = File(p.join(path.path, STUDYROOM_DIR));
    final exist = await dir.exists();
    if (!exist) await dir.create();
    final f = File(p.join(path.path, STUDYROOM_DIR, BUILDING_JSON_NAME));
    f.writeAsStringSync(obj.toRawJson());
  }

  static Future<LocalBuildingData> getBuildings() async {
    final path = await StorageUtil.filesDir;
    final f = File(p.join(path.path, STUDYROOM_DIR, BUILDING_JSON_NAME));
    final s = f.readAsStringSync();
    return LocalBuildingData.fromRawJson(s);
  }
}
