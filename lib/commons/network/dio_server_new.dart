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

  DioService._();
  static final _instance = DioService._();

  static Dio create() => _instance.dio;

  Dio _dio;

  Dio get dio {
    if (_dio == null) {
      BaseOptions options = BaseOptions(
          baseUrl: BASE_URL,
          connectTimeout: 10000,
          receiveTimeout: 10000,
          headers: {
            "domain": DOMAIN,
            "ticket": ticket,
            "Authorization": "Bearer{${CommonPreferences.create().token.value}}",
          });
      _dio = Dio()
      ..options = options
      ..interceptors.add(LogInterceptor(requestBody: false));
    }
    return _dio;
  }
}

typedef OnSuccess = void Function(CommonBody body);
typedef OnFailure = void Function(DioError e);

/// 封装dio中的[get]和[post]函数，返回commonBody对象
extension CommonBodyMethod on Dio {
  Future<void> getCall(
      String path, {
        @required OnSuccess onSuccess,
        OnFailure onFailure,
        Map<String, dynamic> queryParameters,
        Options options,
        CancelToken cancelToken,
        ProgressCallback onReceiveProgress,
      }) async {
    try {
      var response = await get(path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);
      onSuccess(CommonBody.fromJson(response.data));
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!");
      if (onFailure != null) onFailure(e);
    }
  }

  Future<void> postCall(
      String path, {
        @required OnSuccess onSuccess,
        OnFailure onFailure,
        data,
        Map<String, dynamic> queryParameters,
        Options options,
        CancelToken cancelToken,
        ProgressCallback onReceiveProgress,
      }) async {
    try {
      var response = await post(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);
      onSuccess(CommonBody.fromJson(response.data));
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!");
      if (onFailure != null) onFailure(e);
    }
  }
}
