import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart'
    show DeviceInfoPlugin, AndroidDeviceInfo;
import 'package:package_info/package_info.dart' show PackageInfo;
import 'package:wei_pei_yang_demo/home/home_model.dart';

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
      ..interceptors.add(LogInterceptor(requestBody: false));
    return _dio;
  }
}

extension CommonBodyMethod on Dio {
  Future<CommonBody> getCall(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) async {
    var response = await get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
    return CommonBody.fromJson(response.data);
  }

  Future<CommonBody> postCall(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) async {
    var response = await post(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
    return CommonBody.fromJson(response.data);
  }
}
