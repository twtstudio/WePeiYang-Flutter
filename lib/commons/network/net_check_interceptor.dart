import 'package:dio/dio.dart';
import 'error_interceptor.dart' show WpyDioError;
import 'net_status_listener.dart';

class NetCheckInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) async {
    if (NetStatusListener().hasNetwork())
      return options;
    else
      throw WpyDioError(error: "网络未连接");
  }
}
