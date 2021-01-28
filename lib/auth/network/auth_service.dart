import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import '../../commons/network/dio_server_new.dart';
import 'package:flutter/material.dart' show required;

/// 注册或完善信息时获取短信验证码
getCaptchaOnRegister(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("register/phone/msg",
      queryParameters: {"phone": phone},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 使用手机号登陆时获取短信验证码
getCaptchaOnLogin(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("auth/phone/msg",
      queryParameters: {"phone": phone},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 修改密码时获取短信验证码
getCaptchaOnReset(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("password/reset/msg",
      queryParameters: {"phone": phone},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

register(String userNumber, String nickname, String phone, String verifyCode,
    String password, String email, String idNumber,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("register",
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
  await dio.getCall("auth/common",
      queryParameters: {"account": account, "password": password},
      onSuccess: (commonBody) {
    var prefs = CommonPreferences.create();
    prefs.token.value = commonBody.result['token'] ?? "";
    prefs.account.value = account;
    prefs.password.value = password;
    prefs.nickname.value = commonBody.result['nickname'] ?? "";
    prefs.isLogin.value = true;
  }, onFailure: onFailure);
}

/// 使用手机号+验证码登录
loginByCaptcha(String phone, String code,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  var dio = DioService.create();
  await dio.getCall("auth/phone",
      queryParameters: {"phone": phone, "code": code}, onSuccess: (commonBody) {
    var prefs = CommonPreferences.create();
    prefs.token.value = commonBody.result['token'] ?? "";
    prefs.phone.value = phone;
    prefs.nickname.value = commonBody.result['nickname'] ?? "";
    prefs.isLogin.value = true;
  }, onFailure: onFailure);
}
