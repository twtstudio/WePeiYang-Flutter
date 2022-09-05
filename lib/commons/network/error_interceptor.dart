// @dart = 2.12
part of 'wpy_dio.dart';

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

    /// 除了以上列出的错误之外，其他的所有错误给一个统一的名称，防止让用户看到奇奇怪怪的错误代码
    else if (!EnvConfig.isTest) e.error = "发生未知错误，请联系开发人员解决";

    return handler.reject(e);
  }
}

/// 办公网Error判定
class ClassesErrorInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError e, handler) async {
    if (e is WpyDioError) return handler.reject(e);
    if (e.type == DioErrorType.response) {
      switch (e.response?.statusCode) {
        case 500:
          e.error = "服务器发生了未知错误";
          break;
        case 401:
          if ((e.response?.data.toString().contains("验证码错误") ?? false) ||
              (e.response?.data.toString().contains("Mismatch") ?? false))
            e.error = "验证码输入错误";
          else
            e.error = "密码输入错误";
          break;
        case 302:
          // e.error = "办公网绑定失效，请重新绑定";
          e.error = '';
          break;
      }
    }

    /// 除了以上列出的错误之外，其他的所有错误给一个统一的名称，防止让用户看到奇奇怪怪的错误代码
    else if (!EnvConfig.isTest) e.error = "发生未知错误，请联系开发人员解决";

    return handler.reject(e);
  }
}

class WpyDioError extends DioError {
  @override
  final String error;

  WpyDioError({required this.error, String path = 'unknown'})
      : super(requestOptions: RequestOptions(path: path));
}
