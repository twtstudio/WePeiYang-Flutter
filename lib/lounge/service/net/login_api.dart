// import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/commons/new_network/error_interceptor.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';

// import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'api.dart';
// import '../storage_manager.dart';

final Http loginApi = Http();

class Http extends BaseHttp {
  @override
  void init() {
    options.baseUrl = 'https://selfstudy.twt.edu.cn/';
    options.headers = {
      "DOMAIN": AuthDio.DOMAIN,
      "ticket": AuthDio.ticket,
    };
    interceptors
      ..add(ApiInterceptor())
      ..add(InterceptorsWrapper(onRequest: (Options options) {
        var pref = CommonPreferences();
        options.headers['token'] = pref.token.value;
        options.headers['Cookie'] = pref.captchaCookie.value;
      }))
      ..add(ErrorInterceptor());
  }
}

/// 玩Android API
class ApiInterceptor extends InterceptorsWrapper {

  @override
  Future onRequest(RequestOptions options) {
    // debugPrint('---api-request--->url--> ${options.baseUrl}${options.path}' +
    //     ' queryParameters: ${options.queryParameters}');
    // debugPrint('---api-request--->data--->${options.data}');
    return super.onRequest(options);
  }

  @override
  onResponse(Response response) async {
    final String data = response.data.toString();
    final bool isCompute = data.length > 10 * 1024;
    final Map<dynamic, dynamic> _map =
        isCompute ? await compute(parseData, data) : parseData(data);
    ResponseData respData = ResponseData.fromJson(_map);
    // print(respData.toJson());
    if (respData.success) {
      response.data = respData.data;
      return loginApi.resolve(response);
    } else {
      throw NotSuccessException.fromRespData(respData);
    }
  }
}

Map<dynamic, dynamic> parseData(String data) {
  return jsonDecode(data);
}

class ResponseData extends BaseResponseData {
  bool get success => 0 == code || 9 == code;

  ResponseData.fromJson(Map<String, dynamic> json) {
    code = json['error_code'];
    message = json['message'];
    data = json['data'];
  }

  Map toJson() => {
        'code': code,
        'message': message,
        'data': data,
      };
}
