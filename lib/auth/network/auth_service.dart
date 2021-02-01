import 'package:wei_pei_yang_demo/commons/network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import '../../commons/network/dio_server.dart';
import 'package:flutter/material.dart' show required;

/// 注册或完善信息时获取短信验证码
getCaptchaOnRegister(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().originPost("register/phone/msg",
      queryParameters: {"phone": phone}, onSuccess: (response) {
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences.create().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  }, onFailure: onFailure);
}

/// 使用手机号登陆时获取短信验证码
getCaptchaOnLogin(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().originPost("auth/phone/msg",
      queryParameters: {"phone": phone}, onSuccess: (response) {
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences.create().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  }, onFailure: onFailure);
}

/// 修改密码时获取短信验证码
getCaptchaOnReset(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().originPost("password/reset/msg",
      queryParameters: {"phone": phone}, onSuccess: (response) {
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences.create().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  }, onFailure: onFailure);
}

/// 修改密码时认证短信验证码
verifyOnReset(String phone, String code,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().originPost("password/reset/verify",
      queryParameters: {"phone": phone, "code": code}, onSuccess: (response) {
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences.create().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  }, onFailure: onFailure);
}

/// 修改密码
resetPw(String phone, String password,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().post("password/reset",
      queryParameters: {"phone": phone, "password": password},
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}

/// 注册
register(String userNumber, String nickname, String phone, String verifyCode,
    String password, String email, String idNumber,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().post("register",
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
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  await DioService().post("auth/common",
      queryParameters: {"account": account, "password": password},
      onSuccess: (result) {
    var prefs = CommonPreferences.create();
    prefs.token.value = result['token'] ?? "";
    prefs.account.value = account;
    prefs.password.value = password;
    prefs.nickname.value = result['nickname'] ?? "";
    prefs.isLogin.value = true;
    onSuccess(result);
  }, onFailure: onFailure);
}

/// 补全信息（手机号和邮箱）
addInfo(String telephone, String verifyCode, String email,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().put("user/single",
      queryParameters: {
        "telephone": telephone,
        "verifyCode": verifyCode,
        "email": email
      },
      onSuccess: (_) => onSuccess(),
      onFailure: onFailure);
}
