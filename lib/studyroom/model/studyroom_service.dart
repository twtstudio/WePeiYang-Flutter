// @dart = 2.12

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/util/time_util.dart';

class _StudyroomDio extends DioAbstract {
  _StudyroomDio() : super();

  @override
  String get baseUrl => 'https://selfstudy.twt.edu.cn/';

  @override
  Map<String, String>? get headers => {
        "DOMAIN": AuthDio.DOMAIN,
        "ticket": AuthDio.ticket,
      };

  @override
  List<InterceptorsWrapper> get interceptors => [
        _StyApiInterceptor(),
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['token'] = CommonPreferences.token.value;
            return handler.next(options);
          },
        )
      ];
}

class _StyApiInterceptor extends InterceptorsWrapper {
  Map<dynamic, dynamic> parseData(String data) {
    return jsonDecode(data);
  }

  @override
  onResponse(response, handler) async {
    final String data = response.data.toString();
    final bool isCompute = data.length > 10 * 1024;
    final Map<dynamic, dynamic> _map =
        isCompute ? await compute(parseData, data) : parseData(data);
    var respData = _BuildingResponse.fromJson(_map as Map<String, dynamic>);
    if (respData.success) {
      response.data = respData.data;
      return handler.resolve(response);
    } else {
      return handler.reject(
        DioError(
          error: respData.message ?? "未知错误",
          requestOptions: response.requestOptions,
        ),
        true,
      );
    }
  }
}

class _BuildingResponse {
  bool get success => 0 == code || 9 == code;

  _BuildingResponse.fromJson(Map<String, dynamic> json) {
    code = json['error_code'];
    message = json['message'];
    data = json['data'];
  }

  int? code;
  String? message;
  dynamic data;
}

final _studyroomDio = _StudyroomDio();

class StudyroomService {
  /// 获取收藏的教室id
  static Future<List<String>> getFavouriteIds() async {
    final response = await _studyroomDio.get('getCollections');
    // var response =
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.isEmpty) {
      return <String>[];
    } else {
      return pre.first.map((e) => e.toString()).toList();
    }
  }

  /// 收藏教室
  static Future<bool> collectRoom(String id) async {
    try {
      await _studyroomDio.post(
        'addCollection',
        queryParameters: {'classroom_id': id},
      );
      return true;
    } catch (e, s) {
      Logger.reportError(e, s);
      return false;
    }
  }

  /// 取消收藏教室，失败的话就在本地添加记录，下次再做同步
  static Future<bool> deleteRoom(String id) async {
    try {
      await _studyroomDio.post(
        'deleteCollection',
        queryParameters: {'classroom_id': id},
      );
      return true;
    } catch (e, s) {
      Logger.reportError(e, s);
      return false;
    }
  }

  /// 获取指定日期的教室数据（本学期的第几周+周几）
  ///
  /// 如：https://selfstudy.twt.edu.cn/getDayData/21222/1/1
  static Future<List<Building>> getClassroomPlanOfDay(
    StudyRoomDate date,
  ) async {
    final term = CommonPreferences.termName.value;
    final requestDate = '$term/${date.week}/${date.day}';
    try {
      final response = await _studyroomDio.get('getDayData/$requestDate');
      List<Building> buildings =
          response.data.map<Building>((b) => Building.fromJson(b)).toList();
      return buildings.where((b) => b.hasRoom).toList();
    } catch (e) {
      throw ('获取${date.week}+${date.day}自习室数据失败');
    }
  }
}
