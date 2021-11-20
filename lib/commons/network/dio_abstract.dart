import 'dart:async';
import 'package:dio/dio.dart';
import 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart';
import 'package:we_pei_yang_flutter/commons/network/net_check_interceptor.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

export 'package:dio/dio.dart' show DioError, ResponseType, InterceptorsWrapper;
export 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart'
    show WpyDioError;

/// [OnSuccess]和[OnResult]均为请求成功；[OnFailure]为请求失败
typedef OnSuccess = void Function();
typedef OnResult<T> = void Function(T data);
typedef OnFailure = void Function(DioError e);

abstract class DioAbstract {
  String baseUrl;
  Map<String, String> headers;
  List<InterceptorsWrapper> interceptors = [];
  ResponseType responseType = ResponseType.json;
  bool responseBody = false;
  Dio _dio;

  Dio get dio => _dio;

  DioAbstract() {
    BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 10000,
        receiveTimeout: 10000,
        responseType: responseType,
        headers: headers);
    _dio = Dio()
      ..options = options
      ..interceptors.add(NetCheckInterceptor())
      ..interceptors.addAll(interceptors)
      ..interceptors.add(ErrorInterceptor())
      ..interceptors.add(LogInterceptor(responseBody: responseBody));
  }
}

extension DioRequests on DioAbstract {
  /// 普通的[get]、[post]、[put]与[download]方法，返回[Response]
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio
        .get(path, queryParameters: queryParameters)
        .catchError((error, stack) {
      Logger.reportError(error, stack);
      throw error;
    });
  }

  Future<Response<dynamic>> post(String path,
      {Map<String, dynamic> queryParameters, FormData formData}) {
    return dio
        .post(path, queryParameters: queryParameters, data: formData)
        .catchError((error, stack) {
      Logger.reportError(error, stack);
      throw error;
    });
  }

  Future<Response<dynamic>> put(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio
        .put(path, queryParameters: queryParameters)
        .catchError((error, stack) {
      Logger.reportError(error, stack);
      throw error;
    });
  }

  Future<Response<dynamic>> download(String urlPath, String savePath,
      {ProgressCallback onReceiveProgress, Options options}) {
    return dio
        .download(urlPath, savePath,
            onReceiveProgress: onReceiveProgress, options: options)
        .catchError((error, stack) {
      Logger.reportError(error, stack);
      throw error;
    });
  }

  /// twt后台包装的[get]与[post]方法，返回[CommonBody.result]
  Future<Map> getRst(String path, {Map<String, dynamic> queryParameters}) {
    return dio
        .get(path, queryParameters: queryParameters)
        .then((value) => CommonBody.fromJson(value.data).result)
        .catchError((error, stack) {
      Logger.reportError(error, stack);
      throw error;
    });
  }

  Future<Map> postRst(String path,
      {Map<String, dynamic> queryParameters, FormData formData}) {
    return dio
        .post(path, queryParameters: queryParameters, data: formData)
        .then((value) => CommonBody.fromJson(value.data).result)
        .catchError((error, stack) {
      Logger.reportError(error, stack);
      throw error;
    });
  }
}

mixin AsyncTimer {
  static Map<String, bool> _map = {};

  static Future<void> runRepeatChecked<R>(
      String key, Future<void> body()) async {
    if (!_map.containsKey(key)) _map[key] = true;
    if (!_map[key]) return;
    _map[key] = false;
    await body();
    _map[key] = true;
  }
}

class CommonBody {
  int errorCode;
  String message;
  Map result;

  CommonBody.fromJson(dynamic jsonData) {
    errorCode = jsonData['error_code'];
    message = jsonData['message'];
    result = jsonData['result'];
  }
}
