import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

import 'token_manager.dart';

class LafTokenDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.LAF}v1/';

  static final LafTokenDio _instance = LafTokenDio._internal();

  factory LafTokenDio() {
    return _instance;
  }

  LafTokenDio._internal();
}

class LafTokenManager extends TokenManagerAbstract {
  static final LafTokenManager _instance = LafTokenManager._internal();

  factory LafTokenManager() {
    return _instance;
  }

  LafTokenManager._internal();

  @override
  Future<String> get token async {
    final token = CommonPreferences.lafToken.value;
    if (checkTokenLocal(token)) {
      return token;
    }
    return refreshToken();
  }

  Future<String> refreshToken() async {
    ///为什么刷新显示token失效
    try {
       final response = await LafTokenDio().get('laf/login',queryParameters: {
         'account':CommonPreferences.account.value,
         'password':CommonPreferences.password.value,
       });

      if (response.data['result'] != null &&
          response.data['result']['token'] != null) {
        CommonPreferences.lafToken.value = response.data['result']['token'];
        return response.data['result']['token'];
      }
      throw WpyDioException(error: '刷新失物招领token失败');
    } on DioException catch (e) {
      throw e;
    }
  }

}
