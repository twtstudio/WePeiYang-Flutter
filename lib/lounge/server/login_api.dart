// @dart = 2.12

import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

import 'base.dart';

class LoginDio extends DioAbstract {
  LoginDio() : super();

  @override
  String get baseUrl => 'https://selfstudy.twt.edu.cn/';

  @override
  bool get showLog => false;

  @override
  Map<String, String>? get headers => {
        "DOMAIN": AuthDio.DOMAIN,
        "ticket": AuthDio.ticket,
      };

  @override
  List<InterceptorsWrapper> get interceptors => [
        ApiInterceptor(),
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['token'] = CommonPreferences().token.value;
            return handler.next(options);
          },
        )
      ];
}

final loginDio = LoginDio();
