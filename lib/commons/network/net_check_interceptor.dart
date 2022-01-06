import 'package:dio/dio.dart' show InterceptorsWrapper;
import 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart'
    show WpyDioError;
import 'package:we_pei_yang_flutter/commons/network/net_status_listener.dart';

class NetCheckInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(options, handler) async {
    if (NetStatusListener().hasNetwork())
      return handler.next(options);
    else
      return handler.reject(WpyDioError(error: "网络未连接"));
  }
}
