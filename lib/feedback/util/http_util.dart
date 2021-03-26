import 'package:dio/dio.dart';

// Simple encapsulation of Dio.
class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  Dio _client;

  factory HttpUtil() => _instance;

  HttpUtil._internal() {
    if (null == _client) {
      BaseOptions options = BaseOptions(
        // baseUrl: 'https://areas.twt.edu.cn/api/user/',
        baseUrl: 'http://47.94.198.197:10805/api/user/',
        receiveTimeout: 8000,
        connectTimeout: 8000,
      );
      _client = Dio(options);
    }
  }

  Future<Map<String, dynamic>> get(String path,
      [Map<String, dynamic> params]) async {
    Response response;
    if (null != params) {
      response = await _client.get(
        path,
        queryParameters: params,
      );
    } else {
      response = await _client.get(
        path,
      );
    }
    return response.data;
  }

  Future<Map<String, dynamic>> post(String path, dynamic data,
      {Map<String, dynamic> params}) async {
    Response response;
    if (null != params) {
      response = await _client.post(
        path,
        queryParameters: params,
        data: data,
      );
    } else {
      response = await _client.post(
        path,
        data: data,
      );
    }
    return response.data;
  }
}
