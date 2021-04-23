import 'dart:async';

import 'package:dio/dio.dart';
import 'error_interceptor.dart';
import 'net_check_interceptor.dart';

export 'package:dio/src/interceptor.dart' show InterceptorsWrapper;
export 'package:dio/dio.dart' show DioError;

/// [OnSuccess]和[OnResult]均为请求成功；[OnFailure]为请求失败
typedef OnSuccess = void Function();
typedef OnResult = void Function(dynamic data);
typedef OnFailure = void Function(DioError e);

abstract class DioAbstract {
  String baseUrl;
  Map<String, String> headers;
  List<InterceptorsWrapper> interceptors;

  Dio _dio;

  Dio get dio => _dio;

  DioAbstract() {
    BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 10000,
        receiveTimeout: 10000,
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
  /// 普通的[get]、[post]与[put]方法，返回[Response]
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio.post(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> postForm(String path, {FormData form}) {
    return dio.post(path, data: form);
  }

  Future<Response<dynamic>> put(String path,
      {Map<String, dynamic> queryParameters}) {
    return dio.put(path, queryParameters: queryParameters);
  }

  /// twt后台包装的[get]与[post]方法，返回[CommonBody.result]
  Future<Map> getRst(String path, {Map<String, dynamic> queryParameters}) {
    return dio
        .get(path, queryParameters: queryParameters)
        .then((value) => CommonBody.fromJson(value.data).result);
  }

  Future<Map> postRst(String path, {Map<String, dynamic> queryParameters}) {
    return dio
        .post(path, queryParameters: queryParameters)
        .then((value) => CommonBody.fromJson(value.data).result);
  }
}

class CommonBody {
  // ignore: non_constant_identifier_names
  int error_code;
  String message;
  Map result;

  CommonBody.fromJson(dynamic jsonData) {
    error_code = jsonData['error_code'];
    message = jsonData['message'];
    result = jsonData['result'];
  }
}
