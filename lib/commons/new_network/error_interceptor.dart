import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends InterceptorsWrapper {
  /// * 办公网输错验证码 / 密码: [DioErrorType.RESPONSE]: Http status error [401]
  /// * 没刷新验证码（不会出现了）: [DioErrorType.DEFAULT]: RedirectException: Redirect limit exceeded
  /// * 连不上网（已检查）: [DioErrorType.DEFAULT]: SocketException: Failed host lookup: '[host]'
  /// * More....

  // TODO 待完善
  @override
  Future onError(DioError err) async {
    if (err is WpyDioError) return err;
    if (err.type == DioErrorType.CONNECT_TIMEOUT)
      return DioError(error: "网络连接超时");
    if (err.type == DioErrorType.RESPONSE && err.response?.statusCode == 500)
      return DioError(error: "网络连接发生了未知错误");
    if (err.type == DioErrorType.RESPONSE && err.response?.statusCode == 401)
      return DioError(error: "密码或验证码输入错误");
    if (err.type == DioErrorType.RESPONSE && err.response?.statusCode == 302)
      return DioError(error: "办公网绑定失效，请重新绑定");

    /// More...
    if (!kDebugMode) return DioError(error: "发生未知错误，请联系开发人员解决");
  }
}

class WpyDioError extends DioError {
  @override
  final String error;

  WpyDioError({@required this.error});
}
