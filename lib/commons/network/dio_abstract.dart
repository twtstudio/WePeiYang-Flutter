import 'dart:async';

import 'package:dio/dio.dart';
import 'package:we_pei_yang_flutter/lounge/service/net/api.dart';
import 'error_interceptor.dart';
import 'net_check_interceptor.dart';

export 'package:dio/src/interceptor.dart' show InterceptorsWrapper;
export 'package:dio/dio.dart';
export 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart'
    show WpyDioError;

/// [OnSuccess]和[OnResult]均为请求成功；[OnFailure]为请求失败
typedef OnSuccess = void Function();
typedef OnResult = void Function(dynamic data);
typedef OnFailure = void Function(DioError e);

abstract class DioAbstract {
  String baseUrl;
  Map<String, String> headers;
  List<InterceptorsWrapper> interceptors = List();
  ResponseType responseType = ResponseType.json;
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
      ..interceptors.add(LogInterceptor());
  }
}

extension DioRequests on DioAbstract {
  /// 普通的[get]、[post]、[put]与[download]方法，返回[Response]
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path,
      {Map<String, dynamic> queryParameters, FormData formData}) {
    return dio.post(path, queryParameters: queryParameters, data: formData);
  }

  Future<Response<dynamic>> put(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio.put(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> download(String urlPath, String savePath,
      {ProgressCallback onReceiveProgress, Options options}) {
    return dio.download(urlPath, savePath,
        onReceiveProgress: onReceiveProgress, options: options);
  }

  /// twt后台包装的[get]与[post]方法，返回[CommonBody.result]
  Future<Map> getRst(String path, {Map<String, dynamic> queryParameters}) {
    return dio
        .get(path, queryParameters: queryParameters)
        .then((value) => CommonBody.fromJson(value.data).result);
  }

  Future<Map> postRst(String path,
      {Map<String, dynamic> queryParameters, FormData formData}) {
    return dio
        .post(path, queryParameters: queryParameters, data: formData)
        .then((value) => CommonBody.fromJson(value.data).result);
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
