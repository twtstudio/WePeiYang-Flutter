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
      CommonPreferences().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  }, onFailure: onFailure);
}

/// 在用户界面更新信息时获取短信验证码
getCaptchaOnInfo(String phone,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().originPost("user/phone/msg",
      queryParameters: {"phone": phone}, onSuccess: (response) {
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences().captchaCookie.value =
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
      CommonPreferences().captchaCookie.value =
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
      CommonPreferences().captchaCookie.value =
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
    var prefs = CommonPreferences();
    prefs.token.value = result['token'] ?? "";
    prefs.account.value = account;
    prefs.password.value = password;
    prefs.nickname.value = result['nickname'] ?? "";
    prefs.userNumber.value = result['userNumber'] ?? "";
    prefs.phone.value = result['telephone'] ?? "";
    prefs.email.value = result['email'] ?? "";
    prefs.isLogin.value = true;
    onSuccess(result);
  }, onFailure: onFailure);
}

/// 补全信息（手机号和邮箱）
addInfo(String telephone, String verifyCode, String email,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().put("user/single", queryParameters: {
    "telephone": telephone,
    "verifyCode": verifyCode,
    "email": email
  }, onSuccess: (_) {
    var prefs = CommonPreferences();
    prefs.phone.value = telephone;
    prefs.email.value = email;
    onSuccess();
  }, onFailure: onFailure);
}

/// 单独修改手机号
changePhone(String phone, String code,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().put("user/single/phone",
      queryParameters: {'phone': phone, 'code': code}, onSuccess: (_) {
    CommonPreferences().phone.value = phone;
    onSuccess();
  }, onFailure: onFailure);
}

/// 单独修改邮箱
changeEmail(String email,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  await DioService().put("user/single/email", queryParameters: {'email': email},
      onSuccess: (_) {
    CommonPreferences().email.value = email;
    onSuccess();
  }, onFailure: onFailure);
}

/// 检测学号和用户名是否重复
checkInfo1(String userNumber, String username,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  await DioService().get("register/checking/$userNumber/$username",
      onSuccess: onSuccess, onFailure: onFailure);
}

/// 检测身份证、邮箱、手机号是否重复（其实手机号不用查重，获取验证码时已经查重过了）
checkInfo2(String idNumber, String email, String phone,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  await DioService().post("register/checking",
      queryParameters: {'idNumber': idNumber, 'email': email, 'phone': phone},
      onSuccess: onSuccess,
      onFailure: onFailure);
}

/// 获得当前学期信息，仅在用户手动登录后被调用
getSemesterInfo({@required OnSuccess onSuccess, OnFailure onFailure}) async {
  await DioService()
      .get("semester", onSuccess: onSuccess, onFailure: onFailure);
}
