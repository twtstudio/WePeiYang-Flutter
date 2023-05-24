import 'package:we_pei_yang_flutter/auth/model/banner_pic.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class ThemeDio extends DioAbstract {
  @override
  String baseUrl = 'https://haitang.twt.edu.cn/api/v1/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(
      onResponse: (response, handler) {
        var code = response.data['error_code'] ?? 0;
        switch (code) {
          case 0: // 成功
            return handler.next(response);
          default: // 其他错误
            return handler.reject(
                WpyDioError(error: response.data['message']), true);
        }
      },
    )
  ];
}

final themeDio = ThemeDio();

class ThemeService with AsyncTimer {
  static Future<List<BannerPic>> getBanner() async {
    try {
      var response = await themeDio.get('banner');
      var result = response.data['result'];
      var list = <BannerPic>[];
      result.forEach((e) {
        list.add(BannerPic.fromJson(e));
      });
      return list;
    } catch (e, stack) {
      Logger.reportError(e, stack);
      return [];
    }
  }
}
