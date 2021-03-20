import 'package:dio/dio.dart';
import 'error_interceptor.dart';
import 'net_check_interceptor.dart';

export 'package:dio/src/interceptor.dart' show InterceptorsWrapper;
export 'package:dio/dio.dart' show DioError;

typedef OnSuccess = void Function(dynamic data);
typedef OnFailure = void Function(DioError e);

abstract class DioInterface {
  String baseUrl;
  Map<String, String> headers;
  List<InterceptorsWrapper> interceptors;

  Dio _dio;

  DioInterface() {
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
      ..interceptors.add(LogInterceptor(requestBody: false));
  }
}

extension DioRequests on DioInterface {
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic> queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Map> getRst(String path, {Map<String, dynamic> queryParameters}) {
    return _dio
        .get(path, queryParameters: queryParameters)
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
