import 'dart:collection';
import 'package:dio/dio.dart';
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

final reportDio = ReportDio();

class ReportDio extends DioAbstract with AsyncTimer {
  @override
  String baseUrl = "https://api.twt.edu.cn/api/returnSchool/";

  Future<void> report(
      {@required UnmodifiableMapView<ReportPart, dynamic> data,
      @required Function onResult,
      @required OnFailure onFailure}) async {
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
        var result = await dio.post(
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
          onFailure(Exception(responseData.message));
        }
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  Future<List<ReportItem>> getReportHistoryList() async {
    try {
      var token = CommonPreferences.token.value;
      var response = await dio.get(
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
      return null;
    }
  }

  Future<bool> getTodayHasReported() async {
    try {
      var token = CommonPreferences.token.value;
      var response = await dio.get(
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

  LocationData(
      {this.longitude,
      this.latitude,
      this.nation,
      this.province,
      this.city,
      this.cityCode,
      this.district,
      this.address,
      this.time});

  LocationData.onlyAddress(String address) {
    this.latitude = 0;
    this.longitude = 0;
    this.nation = "";
    this.province = "";
    this.city = "";
    this.cityCode = "";
    this.district = "";
    this.address = address;
    this.time = DateTime.now().millisecondsSinceEpoch;
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      longitude: json['longitude'],
      latitude: json['latitude'],
      nation: json['nation'],
      province: json['province'],
      city: json['city'],
      cityCode: json['cityCode'],
      district: json['district'],
      address: json['address'],
      time: json['time'],
    );
  }
}

// TODO: 上传数据的接口返回类型和这个相似，只是result为null，先用这个代替
class ReportState {
  final int errorCode;
  final String message;
  final int result;

  ReportState({this.errorCode, this.message, this.result});

  factory ReportState.fromJson(Map<String, dynamic> json) {
    return ReportState(
      errorCode: json['error_code'],
      message: json['message'],
      result: json['result'],
    );
  }

  Map toJson() => {
        "errorCode": errorCode,
        "message": message,
        "result": result,
      };
}

class ReportList {
  final int errorCode;
  final String message;
  final List<ReportItem> result;

  ReportList({this.errorCode, this.message, this.result});

  factory ReportList.fromJson(Map<String, dynamic> json) {
    return ReportList(
      errorCode: json['error_code'],
      message: json['message'],
      result: []..addAll(
          (json['result'] as List ?? []).map((e) => ReportItem.fromJson(e))),
    );
  }
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

  ReportItem(
      {this.longitude,
      this.latitude,
      this.province,
      this.city,
      this.district,
      this.address,
      this.time,
      this.temperature,
      this.healthCode,
      this.travelCode,
      this.state});

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      longitude: json['longitude'],
      latitude: json['latitude'],
      province: json['provinceName'],
      city: json['cityName'],
      district: json['regionName'],
      address: json['address'],
      time: json['uploadAt'],
      temperature: json['temperature'],
      healthCode: json['healthCodeUrl'],
      travelCode: json['travelCodeUrl'],
      state: json['curStatus'],
    );
  }

  Map toJson() => {
        "longitude": longitude,
        "latitude": latitude,
        "province": province,
        "city": city,
        "district": district,
        "address": address,
        "time": time,
        "temperature": temperature,
        "healthCode": healthCode,
        "travelCode": travelCode,
        "state": state,
      };
}
