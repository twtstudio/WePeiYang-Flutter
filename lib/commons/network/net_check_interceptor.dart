part of 'wpy_dio.dart';

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

  List<ConnectivityResult> _status = [ConnectivityResult.none];

  bool get hasNetwork => !_instance._status.contains(ConnectivityResult.none);
}

class NetCheckInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(options, handler) async {
    if (NetStatusListener().hasNetwork)
      return handler.next(options);
    else
      return handler.reject(WpyDioException(error: '网络未连接'));
  }
}
