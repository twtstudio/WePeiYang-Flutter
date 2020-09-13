import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart' show sha1; //for sha-1 encoding
import 'dart:typed_data' show Uint8List; //for hex method
import 'dart:convert' show utf8; //for utf8.encode method

import 'dio_server.dart';

/// 网络请求的拦截器，用于向uri中添加签名
class SignatureInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    Map<String,String> map = _getTimeStampAndSign(options);
    var queryMap = {
      "t": map.keys.elementAt(0),
      "sign": map.values.elementAt(0),
      "app_key": DioService.APP_KEY
    };
    //TODO
    switch (options.method) {
      case "GET":
      case "POST":
        options.queryParameters.addAll(queryMap);
    }
    return super.onRequest(options);
  }

  Map<String, String> _getTimeStampAndSign(RequestOptions options) {
    StringBuffer buffer = StringBuffer();
    var oq = options.queryParameters;
    for (var i = oq.length - 1; i >= 0; i--) {
      buffer.write(oq.keys.elementAt(i));
      buffer.write(oq.values.elementAt(i));
    }
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String unEncode =
        "${DioService.APP_KEY}t$timeStamp${buffer.toString()}${DioService.APP_SECRET}";
    List<dynamic> bytes = utf8.encode(unEncode);
    return {
      timeStamp: _formatBytesAsHexString(sha1.convert(bytes).bytes)
          .toString()
          .toUpperCase()
    };
  }
}

/// Returns a hex string by a `Uint8List`.
String _formatBytesAsHexString(Uint8List bytes) {
  if (bytes == null) throw new ArgumentError("The list is null");

  var result = new StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}
