import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart'
    show DeviceInfoPlugin, AndroidDeviceInfo;
import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart' show PackageInfo;
import 'error_interceptor.dart';
import 'network_model.dart';
import 'signature.dart';

var _dio = Dio();

class DioService {
  static const TRUSTED_HOST = "open.twt.edu.cn";
  static const BASE_URL = "https://$TRUSTED_HOST/api/";

  static const APP_KEY = "9GTdynvrCm1EKKFfVmTC";
  static const APP_SECRET = "1aVhfAYBFUfqrdlcT621d9d6OzahMI";

  static String defaultToken = "";

  Future<Dio> create() async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    var brand = androidInfo.brand;
    var product = androidInfo.product;
    var sdkInt = androidInfo.version.sdkInt;
    //TODO version seems to be null
    var version = PackageInfo().version;
    final String userAgent =
        "WePeiYang/$version ($brand $product; Android $sdkInt)";
    final BaseOptions _options = BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: 20000,
        receiveTimeout: 20000,
        headers: {
          "User-Agent": userAgent,
          "Authorization": "Bearer{$defaultToken}",
        });
    _dio = Dio()
      ..options = _options
      ..interceptors.add(SignatureInterceptor())
      ..interceptors.add(ErrorInterceptor())
      ..interceptors.add(LogInterceptor(requestBody: false));
    return _dio;
  }
}

typedef OnSuccess = void Function(CommonBody body);
typedef OnFailure = void Function(DioError e);

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
      print("DioServiceLog: \"${e.type}\" error happened");
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
      print("DioServiceLog: \"${e.type}\" error happened");
      if (onFailure != null) onFailure(e);
    }
  }
}
