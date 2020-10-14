import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:wei_pei_yang_demo/start_up.dart';
import '../preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';

/// 自定义错误拦截
class ErrorInterceptor extends InterceptorsWrapper {
  /// token出错或过期时可能需要重新登陆
  _reLogin() async {
    var prefs = CommonPreferences.create();
    if (prefs.username.value == "" || prefs.password.value == "") {
      Navigator.pushNamedAndRemoveUntil(
          WeiPeiYangApp.navigatorState.currentContext,
          '/login',
          (route) => false);
      throw DioError(error: "登录失败，请重新登录");
    }
    getToken(prefs.username.value, prefs.password.value, onSuccess: () {}, onFailure: (e) {
      throw DioError(error: "登录失败，请重新登录");
    });
    throw DioError(error: "登录失效，正在尝试自动重登");
  }

  @override
  Future onError(DioError err) {
    // TODO 细化、调整错误分类
    print(err);
    if (err.type == DioErrorType.CONNECT_TIMEOUT) {
      throw DioError(error: "网络连接超时");
    } else if (err.type == DioErrorType.RESPONSE) {
      if (err.response?.statusCode == 500) {
        throw DioError(error: "网络连接发生了未知错误");
      }
      var code = err.response?.data['error_code'] ?? -1;
      var request = err.response?.request;
      switch (code) {
        case 10001:
          if (request.headers.containsKey("Authorization")) _reLogin();
          break;
        case 10003:
        case 10004:
          _reLogin();
          break;
        case 40000:
        case 40011:
          //TODO 办公网相关（到底是40000还是40011啊我吐力）
          Navigator.pushNamedAndRemoveUntil(
              WeiPeiYangApp.navigatorState.currentContext,
              '/bind',
              (route) => false);
          throw DioError(error: "办公网帐号或密码错误");
          break;
        case 30001:
        case 30002:
          //TODO 判断当前context是否为login，否则打开login
          throw DioError(error: "账号或密码错误");
          break;
        default:
          print(
              "Unhandled error code $code, forRequest: $request Response: ${err.response}");
      }
    }
    return null;
  }
}
