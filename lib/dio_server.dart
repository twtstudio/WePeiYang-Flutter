import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart';
import 'dart:typed_data'; //for hex method
import 'package:crypto/crypto.dart'; //for sha-1 encoding
import 'dart:convert'; //for utf8.encode method

var _dio = Dio();

class DioService {

  static const _VERSION_CODE = "3.8.2";
  static const APP_KEY = "9GTdynvrCm1EKKFfVmTC";
  static const APP_SECRET = "1aVhfAYBFUfqrdlcT621d9d6OzahMI";
  static String defaultToken = "";

  Future<Dio> getDio() async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    var _brand = androidInfo.brand;
    var _product = androidInfo.product;
    var _sdkInt = androidInfo.version.sdkInt;
    final String _userAgent =
        "WePeiYang/$_VERSION_CODE ($_brand $_product; Android $_sdkInt)";
    final BaseOptions _options = BaseOptions(
        baseUrl: "https://open.twt.edu.cn/api/",
        connectTimeout: 20000,
        receiveTimeout: 20000,
        headers: {
          "User-Agent": _userAgent,
          "Authorization": "Bearer{$defaultToken}",
        });
    _dio = Dio()
      ..options = _options
      ..interceptors.add(SignatureInterceptor())
      ..interceptors.add(LogInterceptor(requestBody: false));
    return _dio;
  }
}

class SignatureInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    var queryMap = {
      "t": getTimeStamp(),
      "sign": generateSign(options),
      "app_key": DioService.APP_KEY
    };
    switch (options.method) {
      case "GET":
      case "POST":
        options.queryParameters.addAll(queryMap);
    }
    return super.onRequest(options);
  }

  String getTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String generateSign(RequestOptions options) {
    StringBuffer buffer = StringBuffer();
    //TODO 太丑力
    var oq = options.queryParameters;
    for (var i = oq.length - 1; i >= 0; i--) {
      buffer.write(oq.keys.elementAt(i));
      buffer.write(oq.values.elementAt(i));
    }
    String unEncode = DioService.APP_KEY + "t" + getTimeStamp() +
        buffer.toString() +
        DioService.APP_SECRET;
    List<dynamic> bytes = utf8.encode(unEncode);
    return formatBytesAsHexString(sha1
        .convert(bytes)
        .bytes).toString().toUpperCase();
  }
}

String formatBytesAsHexString(Uint8List bytes) {
  if (bytes == null) throw new ArgumentError("The list is null");

  var result = new StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}
