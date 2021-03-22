import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:wei_pei_yang_demo/main.dart';
import '../preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/auth/auth_router.dart';

/// 自定义错误拦截
class ErrorInterceptor extends InterceptorsWrapper {
  /// token出错或过期时可能需要重新登陆
  // _reLogin() async {
  //   var prefs = CommonPreferences();
  //   if (prefs.account.value == "" || prefs.password.value == "") {
  //     Navigator.pushNamedAndRemoveUntil(
  //         WeiPeiYangApp.navigatorState.currentContext,
  //         AuthRouter.login,
  //         (route) => false);
  //     throw DioError(error: "登录失效，请重新登录");
  //   }
  //   login(prefs.account.value, prefs.password.value,
  //       onSuccess: (_) {},
  //       onFailure: (e) => throw DioError(error: "登录失效，请重新登录"));
  //   throw DioError(error: "正在尝试自动重登");
  // }

  /// * 办公网输错验证码 / 密码: [DioErrorType.RESPONSE]: Http status error [401]
  /// * 没刷新验证码: [DioErrorType.DEFAULT]: RedirectException: Redirect limit exceeded
  /// * 连不上网: [DioErrorType.DEFAULT]: SocketException: Failed host lookup: '[host]'
  /// * More....

  // TODO 待完善

  // @override
  // Future onError(DioError err) async {
  //   if (err.type == DioErrorType.CONNECT_TIMEOUT) {
  //     return DioError(error: "网络连接超时");
  //   }
  //   if (err.type == DioErrorType.RESPONSE && err.response?.statusCode == 500) {
  //     return DioError(error: "网络连接发生了未知错误");
  //   }
  //   super.onError(err);
  // }

  @override
  Future onResponse(Response response) {
    print(response.data.toString() + '\n');
    var code = response?.data['error_code'] ?? -1;
    switch (code) {
      case 40002:
        throw DioError(error: "该用户不存在");
        break;
      case 40004:
        throw DioError(error: "用户名或密码错误");
        break;
      case 40005:
        // _reLogin();
        Navigator.pushNamedAndRemoveUntil(
            WeiPeiYangApp.navigatorState.currentContext,
            AuthRouter.login,
            (route) => false);
        throw DioError(error: "登录失效，请重新登录");
        break;
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
      case 50015:
        throw DioError(error: "升级失败，目标升级账号信息不存在");
        break;
      case 50016:
        throw DioError(error: "无此学院");
        break;
      case 50019:
        throw DioError(error: "用户名中含有非法字符");
        break;
      case 50020:
        throw DioError(error: "用户名过长");
        break;
      case 50021:
        throw DioError(error: "该学号所属用户已注册过");
        break;
      case 50022:
        throw DioError(error: "该身份证号未在系统中登记");
        break;
      case 40001:
      case 40003:
      case 50001:
      case 50002:
      case 50003:
      case 50004:
      case 50010:
        print("请求发生错误，error_code: $code, msg: ${response?.data['msg']}");
        throw DioError(error: "发生未知错误，请重新尝试");
    }
    return super.onResponse(response);
  }
}
