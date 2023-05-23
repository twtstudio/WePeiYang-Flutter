// @dart = 2.12
import 'dart:collection';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/urgent_report/main_page.dart';

class ReportDataModel {
  final Map<ReportPart, dynamic> _data = {};

  UnmodifiableMapView<ReportPart, dynamic> get data =>
      UnmodifiableMapView(_data);

  void add(ReportPart k, dynamic v) {
    _data[k] = v;
    if (v == null || v == '') {
      _data.remove(k);
    }
  }

  void clearAll() {
    _data.clear();
  }

  List<ReportPart> check() {
    return ReportPart.values
        .where((element) => !data.containsKey(element))
        .toList();
  }
}

class ReportDio extends DioAbstract {
  @override
  String baseUrl = "https://api.twt.edu.cn/api/returnSchool/";
}

final _reportDio = ReportDio();

class ReportService with AsyncTimer {
  static Future<void> report(
      {required UnmodifiableMapView<ReportPart, dynamic> data,
      required Function onResult,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked("report", () async {
      try {
        var token = CommonPreferences.token.value;
        var id = CommonPreferences.userNumber.value;
        var location = data[ReportPart.currentLocation] as LocationData;
        var state = data[ReportPart.currentState] as LocationState;
        final travelCode = MultipartFile.fromFileSync(
          data[ReportPart.itineraryCode],
          filename: 't${DateTime.now().millisecondsSinceEpoch}code$id.jpg',
          contentType: MediaType('image', 'jpg'),
        );
        final healthCode = MultipartFile.fromFileSync(
          data[ReportPart.healthCode],
          filename: 'h${DateTime.now().millisecondsSinceEpoch}code$id.jpg',
          contentType: MediaType('image', 'jpg'),
        );
        debugPrint("travelCode size: ${travelCode.length}");
        debugPrint("healthCode size: ${healthCode.length}");
        FormData formData = FormData.fromMap({
          'provinceName': location.province,
          'cityName': location.city,
          'regionName': location.district,
          'address': location.address,
          'longitude': location.longitude,
          'latitude': location.latitude,
          'healthCodeScreenshot': healthCode,
          'travelCodeScreenshot': travelCode,
          'curStatus': state.index,
          'temperature': data[ReportPart.temperature],
        });
        var result = await _reportDio.post(
          "record",
          options: Options(
            headers: {
              "DOMAIN": AuthDio.DOMAIN,
              "ticket": AuthDio.ticket,
              "token": token,
            },
          ),
          data: formData,
        );
        var responseData = ReportState.fromJson(result.data);
        if (responseData.errorCode == 0 ? true : false) {
          onResult();
        } else {
          onFailure(WpyDioError(error: responseData.message));
        }
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<List<ReportItem>> getReportHistoryList() async {
    try {
      var token = CommonPreferences.token.value;
      var response = await _reportDio.get(
        "record",
        options: Options(
          headers: {
            "DOMAIN": AuthDio.DOMAIN,
            "ticket": AuthDio.ticket,
            "token": token,
          },
        ),
      );
      var data = ReportList.fromJson(response.data);
      return data.result;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> getTodayHasReported() async {
    try {
      var token = CommonPreferences.token.value;
      var response = await _reportDio.get(
        "status",
        options: Options(
          headers: {
            "DOMAIN": AuthDio.DOMAIN,
            "ticket": AuthDio.ticket,
            "token": token,
          },
        ),
      );
      var data = ReportState.fromJson(response.data);
      return data.result == 1 ? true : false;
    } catch (e) {
      return false;
    }
  }
}

class LocationData {
  double longitude;
  double latitude;
  String nation;
  String province;
  String city;
  String cityCode;
  String district;
  String address;
  int time;

  LocationData({
    required this.longitude,
    required this.latitude,
    required this.nation,
    required this.province,
    required this.city,
    required this.district,
    required this.address,
  })  : this.cityCode = '',
        this.time = DateTime.now().millisecondsSinceEpoch;

  LocationData.onlyAddress(String address)
      : this.latitude = 0,
        this.longitude = 0,
        this.nation = '',
        this.province = '',
        this.city = '',
        this.cityCode = '',
        this.district = '',
        this.address = address,
        this.time = DateTime.now().millisecondsSinceEpoch;

  LocationData.fromJson(Map<String, dynamic> json)
      : this.longitude = json['longitude'],
        this.latitude = json['latitude'],
        this.nation = json['nation'],
        this.province = json['province'],
        this.city = json['city'],
        this.cityCode = json['cityCode'],
        this.district = json['district'],
        this.address = json['address'],
        this.time = json['time'];
}

// TODO: 上传数据的接口返回类型和这个相似，只是result为null，先用这个代替
class ReportState {
  final int errorCode;
  final String message;
  final int result;

  ReportState.fromJson(Map<String, dynamic> json)
      : this.errorCode = json['error_code'],
        this.message = json['message'],
        this.result = json['result'];
}

class ReportList {
  final int errorCode;
  final String message;
  final List<ReportItem> result;

  ReportList.fromJson(Map<String, dynamic> json)
      : this.errorCode = json['error_code'],
        this.message = json['message'],
        this.result = []..addAll(((json['result'] ?? <ReportItem>[]) as List)
            .map((e) => ReportItem.fromJson(e)));
}

class ReportItem {
  final String longitude;
  final String latitude;
  final String province;
  final String city;
  final String district;
  final String address;
  final String time;
  final String temperature;
  final String healthCode;
  final String travelCode;
  final int state;

  ReportItem.fromJson(Map<String, dynamic> json)
      : this.longitude = json['longitude'],
        this.latitude = json['latitude'],
        this.province = json['provinceName'],
        this.city = json['cityName'],
        this.district = json['regionName'],
        this.address = json['address'],
        this.time = json['uploadAt'],
        this.temperature = json['temperature'],
        this.healthCode = json['healthCodeUrl'],
        this.travelCode = json['travelCodeUrl'],
        this.state = json['curStatus'];
}
