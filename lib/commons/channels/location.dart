// @dart = 2.12

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';

const _placeChannel = MethodChannel('com.twt.service/place');

Future<LocationData> getLocation() async {
  String preJson = await _placeChannel.invokeMethod("getLocation");
  return LocationData.fromJson(jsonDecode(preJson));
}