import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required;
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'network_model.dart';
import 'dart:convert' show utf8, base64Encode;

class DioService {
  static const TRUSTED_HOST = "api.twt.edu.cn";
  static const BASE_URL = "https://$TRUSTED_HOST/api/";
  static const APP_KEY = "banana";
  static const APP_SECRET = "37b590063d593716405a2c5a382b1130b28bf8a7";
  static const DOMAIN = "weipeiyang.twt.edu.cn";
  static String ticket = base64Encode(utf8.encode(APP_KEY + '.' + APP_SECRET));

  DioService._() {
    BaseOptions options = BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: 10000,
        receiveTimeout: 10000,
        headers: {
          "DOMAIN": DOMAIN,
          "ticket": ticket,
          "Authorization": "Bearer{${CommonPreferences.create().token.value}}",
        });
    _dio = Dio()
      ..options = options
      ..interceptors.add(LogInterceptor(requestBody: false));
  }

  static final _instance = DioService._();

  static Dio create() => _instance.dio;

  static Dio _dio;

  Dio get dio => _dio;
}

typedef OnSuccess = void Function(Map result);
typedef OnFailure = void Function(DioError e);

/// 封装dio中的[get]和[post]函数，并解析返回的commonBody对象
extension CommonBodyMethod on Dio {
  Future<void> getCall(
    String path, {
    @required OnSuccess onSuccess,
    OnFailure onFailure,
    Map<String, dynamic> queryParameters,
  }) async {
    try {
      var response = await get(path, queryParameters: queryParameters);
      print(response.data.toString() + '\n');
      onSuccess(CommonBody.fromJson(response.data).result);
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!\n");
      if (onFailure != null) onFailure(e);
    }
  }

  Future<void> postCall(String path,
      {@required OnSuccess onSuccess,
      OnFailure onFailure,
      data,
      Map<String, dynamic> queryParameters}) async {
    try {
      var response =
          await post(path, data: data, queryParameters: queryParameters);
      print(response.data.toString() + '\n');
      onSuccess(CommonBody.fromJson(response.data).result);
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!\n");
      if (onFailure != null) onFailure(e);
    }
  }
}
