import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:wei_pei_yang_demo/main.dart';
import '../preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';

/// 自定义错误拦截
class ErrorInterceptor extends InterceptorsWrapper {
  // /// token出错或过期时可能需要重新登陆
  // _reLogin() async {
  //   var prefs = CommonPreferences.create();
  //   if (prefs.username.value == "" || prefs.password.value == "") {
  //     Navigator.pushNamedAndRemoveUntil(
  //         WeiPeiYangApp.navigatorState.currentContext,
  //         '/login',
  //         (route) => false);
  //     throw DioError(error: "登录失败，请重新登录");
  //   }
  //   getToken(prefs.username.value, prefs.password.value, onSuccess: () {}, onFailure: (e) {
  //     throw DioError(error: "登录失败，请重新登录");
  //   });
  //   throw DioError(error: "登录失效，正在尝试自动重登");
  // }
  //
  // @override
  // Future onError(DioError err) {
  //   // TODO 细化、调整错误分类
  //   print(err);
  //   if (err.type == DioErrorType.CONNECT_TIMEOUT) {
  //     throw DioError(error: "网络连接超时");
  //   } else if (err.type == DioErrorType.RESPONSE) {
  //     if (err.response?.statusCode == 500) {
  //       throw DioError(error: "网络连接发生了未知错误");
  //     }
  //     var code = err.response?.data['error_code'] ?? -1;
  //     var request = err.response?.request;
  //     switch (code) {
  //       case 10001:
  //         if (request.headers.containsKey("Authorization")) _reLogin();
  //         break;
  //       case 10003:
  //       case 10004:
  //         _reLogin();
  //         break;
  //       case 40000:
  //       case 40011:
  //         //TODO 办公网相关（到底是40000还是40011啊我吐力）
  //         Navigator.pushNamedAndRemoveUntil(
  //             WeiPeiYangApp.navigatorState.currentContext,
  //             '/bind',
  //             (route) => false);
  //         throw DioError(error: "办公网帐号或密码错误");
  //         break;
  //       case 30001:
  //       case 30002:
  //         //TODO 判断当前context是否为login，否则打开login
  //         throw DioError(error: "账号或密码错误");
  //         break;
  //       default:
  //         print(
  //             "Unhandled error code $code, forRequest: $request Response: ${err.response}");
  //     }
  //   }
  //   return null;
  // }

  @override
  Future onResponse(Response response) {
    var code = response?.data['error_code'] ?? -1;
    switch (code) {
      case 40002:
        throw DioError(error: "该用户不存在");
        break;
      case 40004:
        throw DioError(error: "用户名或密码错误");
        break;
      case 40005:
        // TODO 使用缓存重新登录
        Navigator.pushNamedAndRemoveUntil(
            WeiPeiYangApp.navigatorState.currentContext,
            '/login',
            (route) => false);
        throw DioError(error: "登录失效，请重新登录");
        break; // TODO 有必要break吗
      case 50005:
        throw DioError(error: "学号和身份证号不匹配");
        break;
      case 50006:
        throw DioError(error: "用户名和邮箱已存在");
        break;
      case 50007:
        throw DioError(error: "用户名已存在");
        break;
      case 50008:
        throw DioError(error: "邮箱已存在");
        break;
      case 50009:
        throw DioError(error: "手机号码无效");
        break;
      case 50011:
        throw DioError(error: "验证失败，请重新尝试");
        break;
      case 50012:
        throw DioError(error: "电子邮件或手机号格式不规范");
        break;
      case 50013:
        throw DioError(error: "电子邮件或手机号重复");
        break;
      case 50014:
        throw DioError(error: "手机号已存在");
        break;
      case 50016:
        throw DioError(error: "无此学院");
        break;
      case 40001:
      case 40003:
      case 50001:
      case 50002:
      case 50003:
      case 50004:
      case 50010:
      case 50015:
        print("请求发生错误，error_code: $code, msg: ${response?.data['msg']}");
        throw DioError(error: "发生未知错误，请重新尝试");
    }
    return null;
  }
}
