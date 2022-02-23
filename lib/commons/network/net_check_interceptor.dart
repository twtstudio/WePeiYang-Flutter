// @dart = 2.12
import 'package:dio/dio.dart' show InterceptorsWrapper;
import 'package:connectivity/connectivity.dart';
import 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart'
    show WpyDioError;

class NetStatusListener {
  static final NetStatusListener _instance = NetStatusListener._();

  NetStatusListener._();

  factory NetStatusListener() => _instance;

  static Future<void> init() async {
    _instance._status = await Connectivity().checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _instance._status = result;
    });
  }

  ConnectivityResult _status = ConnectivityResult.none;

  bool get hasNetwork => _instance._status != ConnectivityResult.none;
}

class NetCheckInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(options, handler) async {
    if (NetStatusListener().hasNetwork)
      return handler.next(options);
    else
      return handler.reject(WpyDioError(error: '网络未连接'));
  }
}