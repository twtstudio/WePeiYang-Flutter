import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart'
    show DeviceInfoPlugin, AndroidDeviceInfo;
import 'package:package_info/package_info.dart' show PackageInfo;
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
