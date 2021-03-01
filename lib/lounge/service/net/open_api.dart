// import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'api.dart';
// import '../storage_manager.dart';

final Http open_http = Http();

class Http extends BaseHttp {
  @override
  void init() {
    options.baseUrl = 'https://selfstudy.twt.edu.cn/';
    interceptors..add(ApiInterceptor());
    // cookie持久化 异步
    // ..add(CookieManager(
    //     PersistCookieJar(dir: StorageManager.temporaryDirectory.path)));
  }
}

/// 玩Android API
class ApiInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) async {
    // debugPrint('---api-request--->url--> ${options.baseUrl}${options.path}' +
    //     ' queryParameters: ${options.queryParameters}');
//    debugPrint('---api-request--->data--->${options.data}');
    return options;
  }

  @override
  onResponse(Response response) async {
    final String data = response.data.toString();
    final bool isCompute =  data.length > 10 * 1024;
    final Map<dynamic, dynamic> _map = isCompute ? await compute(parseData, data) : parseData(data);
    ResponseData respData = ResponseData.fromJson(_map);
    if (respData.success) {
      response.data = respData.data;
      return open_http.resolve(response);
    } else {
      /// TODO: 不知道开放接口会返回什么错误信息
      // if (respData.code == 2) {
      //   // 如果cookie过期,需要清除本地存储的登录信息
      //   // StorageManager.localStorage.deleteItem(UserModel.keyUser);
      //   throw const UnAuthorizedException(); // 需要登录
      // } else {
      //   throw NotSuccessException.fromRespData(respData);
      // }
      throw NotSuccessException.fromRespData(respData);
    }
  }
}

Map<dynamic, dynamic> parseData(String data) {
  return jsonDecode(data);
}

class ResponseData extends BaseResponseData {
  bool get success => 0 == code;

  ResponseData.fromJson(Map<String, dynamic> json) {
    code = json['error_code'];
    message = json['message'];
    data = json['data'];
  }
}
