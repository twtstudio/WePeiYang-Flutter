import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart'
    show DeviceInfoPlugin, AndroidDeviceInfo;
import 'package:flutter/material.dart' show required;
import 'package:package_info/package_info.dart' show PackageInfo;
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'error_interceptor.dart';
import 'network_model.dart';
import 'signature.dart';

// TODO 单例的写法可能不太对，可以参考common_prefs
class DioService {
  static const TRUSTED_HOST = "open.twt.edu.cn";
  static const BASE_URL = "https://$TRUSTED_HOST/api/";

  static const APP_KEY = "9GTdynvrCm1EKKFfVmTC";
  static const APP_SECRET = "1aVhfAYBFUfqrdlcT621d9d6OzahMI";

  /// to create a [Dio] object
  ///
  /// usage:
  /// ```dart
  ///
  /// in service page:
  /// getToken(String name, String pw, {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  ///   var dio = await DioService().create();
  ///   await dio.getCall("v1/auth/token/get",
  ///       queryParameters: {"twtuname": name, "twtpasswd": pw},
  ///       onSuccess: onSuccess,
  ///       onFailure: onFailure);
  /// }
  ///
  /// in view page:
  /// _login() async {
  ///   getToken(email, password, onSuccess: (commonBody) {
  ///     prefs.token = Token.fromJson(commonBody.data).token;
  ///     Navigator.pushReplacementNamed(context, '/home');
  ///   });
  /// }
  /// ```

  static var brand;
  static var product;
  static var sdkInt;
  static var version;

  static Future<Dio> create({bool shorted = false}) async {
    if (brand == null || product == null || sdkInt == null) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      brand = androidInfo.brand;
      product = androidInfo.product;
      sdkInt = androidInfo.version.sdkInt;
    }
    //TODO version seems to be null
    version ??= PackageInfo().version;
    var userAgent = "WePeiYang/$version ($brand $product; Android $sdkInt)";

    /// 配置网络请求参数
    /// 需加上两个header [User-Agent] 和 [Authorization]
    BaseOptions _options = BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: shorted ? 3000 : 10000,
        receiveTimeout: shorted ? 3000 : 10000,
        headers: {
          "User-Agent": userAgent,
          "Authorization": "Bearer{${CommonPreferences.create().token.value}}",
        });
    var _dio = Dio()
      ..options = _options
      ..interceptors.add(SignatureInterceptor())
      ..interceptors.add(ErrorInterceptor())
      ..interceptors.add(LogInterceptor(requestBody: false));
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
      print("DioServiceLog: \"${e.type}\" error happened!!!");
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
