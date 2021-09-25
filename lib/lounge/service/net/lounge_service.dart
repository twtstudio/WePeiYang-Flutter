import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';

class LoginDio extends DioAbstract {
  @override
  String baseUrl = 'https://selfstudy.twt.edu.cn/';

  @override
  Map<String, String> headers = {
    "DOMAIN": AuthDio.DOMAIN,
    "ticket": AuthDio.ticket
  };

  @override
  List<InterceptorsWrapper> interceptors = [
    ApiInterceptor(),
    InterceptorsWrapper(onRequest: (Options options) {
      var pref = CommonPreferences();
      options.headers['token'] = pref.token.value;
      options.headers['Cookie'] = pref.captchaCookie.value;
    })
  ];
}

class OpenDio extends DioAbstract {
  @override
  String baseUrl = 'https://selfstudy.twt.edu.cn/';

  @override
  List<InterceptorsWrapper> interceptors = [ApiInterceptor()];
}

final loginDio = LoginDio();

final openDio = OpenDio();

class ApiInterceptor extends InterceptorsWrapper {
  @override
  onResponse(Response response) async {
    final String data = response.data.toString();
    final bool isCompute = data.length > 10 * 1024;
    final Map<dynamic, dynamic> _map =
        isCompute ? await compute(parseData, data) : parseData(data);
    var respData = ResponseData.fromJson(_map);
    if (respData.success) {
      response.data = respData.data;
      return loginDio.dio.resolve(response);
    } else {
      throw WpyDioError(error: respData.message);
    }
  }
}

Map<dynamic, dynamic> parseData(String data) {
  return jsonDecode(data);
}

class ResponseData {
  bool get success => 0 == code || 9 == code;

  ResponseData.fromJson(Map<String, dynamic> json) {
    code = json['error_code'];
    message = json['message'];
    data = json['data'];
  }

  int code;
  String message;
  dynamic data;
}
