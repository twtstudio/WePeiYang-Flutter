import 'package:dio/dio.dart';
import 'dart:io';
import 'package:device_info/device_info.dart';

class DioService {
  DioService._();

  static DioService _service;

  static Dio create() {
    if (_service == null) _service = DioService._();
    _service._getInfo();
    return _service._dio;
  }

  void _getInfo() async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    _brand = androidInfo.brand;
    _product = androidInfo.product;
    _sdkInt = androidInfo.version.sdkInt;
  }

  static const _VERSION_CODE = "3.8.2";

  String _brand = "";
  String _product;
  int _sdkInt;

  final String _userAgent =
      "WePeiYang/$_VERSION_CODE (${_service._brand} ${_service._product}; Android ${_service._sdkInt})";

  String defaultToken = "";

  final BaseOptions _options = BaseOptions(
      baseUrl: "https://open.twt.edu.cn/api/",
      connectTimeout: 20000,
      receiveTimeout: 20000,
      headers: {
        HttpHeaders.userAgentHeader: _service._userAgent,
        "authorization": "Bearer{${_service.defaultToken}}",

      });

  Dio _dio = Dio()..interceptors.add(LogInterceptor(requestBody: false));
}
