import 'dart:async';

import 'package:intl/intl.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/util/session_util.dart';

class _StudyroomDio extends DioAbstract {
  _StudyroomDio() : super();

  @override
  String get baseUrl => 'http://studyroom.subit.org.cn/';

  @override
  Map<String, String>? get headers => {
        "DOMAIN": AuthDio.DOMAIN,
        "ticket": AuthDio.ticket,
      };

  @override
  List<Interceptor> get interceptors => [
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
  @override
  onResponse(response, handler) async {
    final data = response.data;
    var respData = _BuildingResponse.fromJson(data);
    if (respData.success) {
      response.data = respData.data;
      return handler.resolve(response);
    } else {
      return handler.reject(
        DioException(
          error: respData.data as String? ?? "未知错误",
          requestOptions: response.requestOptions,
        ),
        true,
      );
    }
  }
}

class _BuildingResponse {
  bool get success => 10000 == code;

  _BuildingResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'];
  }

  int? code;
  dynamic data;
}

final _studyroomDio = _StudyroomDio();

class StudyroomService {
  /// 获取收藏的教室id
  static Future<List<int>> getFavouriteIds() async {
    final response = await _studyroomDio.get('getCollections');
    // var response =
    var pre = Map<String, List<dynamic>>.from(response.data).values;
    if (pre.isEmpty) {
      return <int>[];
    } else {
      return pre.first.map((e) => int.parse(e)).toList();
    }
  }

  /// 收藏教室
  static Future<bool> collectRoom(int id) async {
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
  static Future<bool> deleteRoom(int id) async {
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

  static Future<List<Campus>> getCampusList() async {
    try {
      final response = await _studyroomDio.get('/campus');
      return List<Campus>.from(
        response.data.map((e) => Campus.fromJson(e)),
      );
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }

  static Future<List<Building>> getBuildingList(int campusId) async {
    try {
      final response = await _studyroomDio.get('/campus/${campusId}/building');
      return List<Building>.from(
        response.data.map((e) => Building.fromJson(e)),
      );
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }

  static Future<List<Room>> getRoomList(
      int buildingId, int session, DateTime date) async {
    try {
      final response;
      if (session == -1) session = SessionIndexUtil.getCurrentSessionIndex();
      if (session == -1) {
        response = await _studyroomDio.get('/building/${buildingId}/room');
      } else {
        response = await _studyroomDio.get(
            '/building/${buildingId}/room/session/${session}/date/${DateFormat('yyyy-MM-dd').format(date)}');
      }
      return List<Room>.from(
        response.data.map((e) => Room.fromJson(e)),
      );
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }

  static Future<List<Occupy>> getSchedule(int id) async {
    try {
      final response = await _studyroomDio.get('/room/${id}/schedule');
      return List<Occupy>.from(
        response.data.map((e) => Occupy.fromJson(e)),
      );
    } catch (e, s) {
      Logger.reportError(e, s);
      return [];
    }
  }
}
