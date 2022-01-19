import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show required;
import 'package:flutter/foundation.dart' show kDebugMode;

class ErrorInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError e, handler) async {
    if (e is WpyDioError) return handler.reject(e);
    if (e.type == DioErrorType.connectTimeout)
      e.error = "网络连接超时";
    else if (e.type == DioErrorType.sendTimeout)
      e.error = "发送请求超时";
    else if (e.type == DioErrorType.receiveTimeout)
      e.error = "响应超时";
    else if (e.type == DioErrorType.response && e.response?.statusCode == 500)
      e.error = "网络连接发生了未知错误";
    else if (e.type == DioErrorType.response && e.response?.statusCode == 401)
      e.error = "密码或验证码输入错误";
    else if (e.type == DioErrorType.response && e.response?.statusCode == 302)
      e.error = "办公网绑定失效，请重新绑定";

    /// 除了以上列出的错误之外，其他的所有错误给一个统一的名称，防止让用户看到奇奇怪怪的错误代码
    else if (!kDebugMode) e.error = "发生未知错误，请联系开发人员解决";

    return handler.reject(e);
  }
}

class WpyDioError extends DioError {
  @override
  final String error;

  WpyDioError({@required this.error});
}
