import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required;
import 'package:wei_pei_yang_demo/commons/network/error_interceptor.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'network_model.dart';
import 'dart:convert' show utf8, base64Encode;

typedef OnSuccess = void Function(Map result);
typedef OnFailure = void Function(DioError e);

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
        headers: {"DOMAIN": DOMAIN, "ticket": ticket});
    _dio = Dio()
      ..options = options
      ..interceptors.add(InterceptorsWrapper(onRequest: (Options options) {
        var pref = CommonPreferences();
        options.headers['token'] = pref.token.value;
        options.headers['Cookie'] = pref.captchaCookie.value;
      }))
      ..interceptors.add(ErrorInterceptor())
      ..interceptors.add(LogInterceptor(requestBody: false));
  }

  factory DioService() => _instance;

  static final _instance = DioService._();

  static Dio _dio;

  /// 封装dio中的[get]和[post]函数，并解析返回的commonBody对象
  Future<void> get(
    String path, {
    @required OnSuccess onSuccess,
    OnFailure onFailure,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) async {
    try {
      var response = await _dio.get(path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);
      onSuccess(CommonBody.fromJson(response.data).result);
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!\n");
      if (onFailure != null) onFailure(e);
    }
  }

  Future<void> post(
    String path, {
    @required OnSuccess onSuccess,
    OnFailure onFailure,
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    try {
      var response = await _dio.post(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      onSuccess(CommonBody.fromJson(response.data).result);
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!\n");
      if (onFailure != null) onFailure(e);
    }
  }

  Future<void> put(
    String path, {
    @required OnSuccess onSuccess,
    OnFailure onFailure,
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    try {
      var response = await _dio.put(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      onSuccess(CommonBody.fromJson(response.data).result);
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!\n");
      if (onFailure != null) onFailure(e);
    }
  }

  /// 直接返回response对象而不做解析的post方法
  Future<void> originPost(
    String path, {
    @required void Function(Response) onSuccess,
    OnFailure onFailure,
    Map<String, dynamic> queryParameters,
  }) async {
    try {
      var response = await _dio.post(path, queryParameters: queryParameters);
      onSuccess(response);
    } on DioError catch (e) {
      print("DioServiceLog: \"${e.error}\" error happened!!!\n");
      if (onFailure != null) onFailure(e);
    }
  }
}
