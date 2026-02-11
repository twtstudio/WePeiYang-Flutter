

import '../../commons/environment/config.dart';
import '../../commons/network/wpy_dio.dart';
import '../../commons/token/lake_token_manager.dart';
import '../../commons/util/logger.dart';

class ScreenSplashDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/splash';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = (await LakeTokenManager().token);
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        default: // 其他错误
          return handler.reject(
              WpyDioException(error: response.data['msg']), true);
      }
    })
  ];
}

final splashDio = ScreenSplashDio();

class SplashService with AsyncTimer {
  static Future<String> getSplashLight() async {
    try {
      var url = await splashDio.get('image_url');
      return url.toString();
    } catch (e, stack) {
      Logger.reportError(e, stack);
      return "assets/images/splash_screen.png";
    }
  }

  static Future<String> getSplashDark() async {
    try {
      var url = await splashDio.get('image_url_dark');
      return url.toString();
    } catch (e, stack) {
      Logger.reportError(e, stack);
      return "assets/images/splash_screen_dark.png";
    }
  }
}
