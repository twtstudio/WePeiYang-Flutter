import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import '../../commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;

/// 注册或完善信息时获取短信验证码
getCaptchaOnRegister(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("register/phone/msg",
      queryParameters: {"phone": phone},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 使用手机号登陆时获取短信验证码
getCaptchaOnLogin(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("auth/phone/msg",
      queryParameters: {"phone": phone},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 修改密码时获取短信验证码
getCaptchaOnReset(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("password/reset/msg",
      queryParameters: {"phone": phone},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 修改密码时认证短信验证码
verifyOnReset(String phone, String code,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("password/reset/verify",
      queryParameters: {"phone": phone, "code": code},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 修改密码
resetPw(String phone, String password,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("password/reset",
      queryParameters: {"phone": phone, "password": password},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 注册
register(String userNumber, String nickname, String phone, String verifyCode,
    String password, String email, String idNumber,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("register",
      queryParameters: {
        "userNumber": userNumber,
        "nickname": nickname,
        "phone": phone,
        "verifyCode": verifyCode,
        "password": password,
        "email": email,
        "idNumber": idNumber
      },
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 使用学号/昵称/邮箱登录
login(String account, String password,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("auth/common",
      queryParameters: {"account": account, "password": password},
      onSuccess: (result) {
    var prefs = CommonPreferences.create();
    prefs.token.value = result['token'] ?? "";
    prefs.account.value = account;
    prefs.password.value = password;
    prefs.nickname.value = result['nickname'] ?? "";
    prefs.isLogin.value = true;
    onSuccess();
  }, onFailure: onFailure);
}

/// 使用手机号+验证码登录
loginByCaptcha(String phone, String code,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.postCall("auth/phone",
      queryParameters: {"phone": phone, "code": code}, onSuccess: (result) {
    var prefs = CommonPreferences.create();
    prefs.token.value = result['token'] ?? "";
    prefs.phone.value = phone;
    prefs.nickname.value = result['nickname'] ?? "";
    prefs.isLogin.value = true;
    onSuccess();
  }, onFailure: onFailure);
}
