import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

import 'token_manager.dart';

class LakeTokenDio extends DioAbstract {
  @override
  String baseUrl = '${EnvConfig.QNHD}api/v1/f/';

  static final LakeTokenDio _instance = LakeTokenDio._internal();

  factory LakeTokenDio() {
    return _instance;
  }

  LakeTokenDio._internal();
}

class LakeTokenManager extends TokenManagerAbstract {
  static final LakeTokenManager _instance = LakeTokenManager._internal();

  factory LakeTokenManager() {
    return _instance;
  }

  LakeTokenManager._internal();

  @override
  Future<String> get token async {
    final token = CommonPreferences.lakeToken.value;
    if (checkTokenLocal(token)) return token;
    return refreshToken();
  }

  Future<String> refreshToken() async {
    try {
      final response = await LakeTokenDio().get('auth/token', queryParameters: {
        'token': CommonPreferences.token.value,
      });
      if (response.data['data'] != null &&
          response.data['data']['token'] != null) {
        CommonPreferences.lakeToken.value = response.data['data']['token'];
        CommonPreferences.lakeUid.value =
            response.data['data']['uid'].toString();
        if (response.data['data']['user'] != null) {
          CommonPreferences.isSuper.value =
              response.data['data']['user']['is_super'];
          CommonPreferences.isSchAdmin.value =
              response.data['data']['user']['is_sch_admin'];
          CommonPreferences.isStuAdmin.value =
              response.data['data']['user']['is_stu_admin'];
          CommonPreferences.isUser.value =
              response.data['data']['user']['is_user'];
          CommonPreferences.avatarBoxMyUrl.value =
              response.data['data']['user']['avatar_frame'];
        }
        return response.data['data']['token'];
      }
      throw WpyDioException(error: '刷新湖底token失败');
    } on DioException catch (e) {
      throw e;
    }
  }
}
