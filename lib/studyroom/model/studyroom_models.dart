// @dart=2.12
// To parse this JSON data, do
//
//     final buildingResponse = buildingResponseFromJson(jsonString);

import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';

class Campus {
  final int id;
  final String name;

  Campus(this.id, this.name);

  factory Campus.fromRawJson(String str) => Campus.fromJson(json.decode(str));

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(json['id'], json['name']);
  }
}

class Building {
  final int id;
  final String name;
  final int campusId;

  Building(this.id, this.name, this.campusId);

  factory Building.fromRawJson(String str) =>
      Building.fromJson(json.decode(str));

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
        json['id'],
        (json['name'] as String).replaceAll(RegExp(r'^0+'), ''),
        json['campus_id']);
  }
}

class Room {
  final int id;
  String name;
  final String buildingId;
  final bool isFree;

  Room(this.id, this.name, this.buildingId, this.isFree);

  factory Room.fromRawJson(String str) => Room.fromJson(json.decode(str));

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
        json['id'],
        (json['name'] as String).replaceAll(RegExp(r'^0+'), ''),
        json['building_id'],
        json['free']);
  }
}
