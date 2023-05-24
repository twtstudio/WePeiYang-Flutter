import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';

class LocationManager {
  static const _placeChannel = MethodChannel('com.twt.service/place');

  static Future<LocationData> getLocation() async {
    String preJson = await _placeChannel.invokeMethod("getLocation");
    return LocationData.fromJson(jsonDecode(preJson));
  }
}
