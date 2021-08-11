import 'dart:developer';

import 'package:we_pei_yang_flutter/commons/new_network/spider_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:flutter/material.dart' show Navigator, required;
import 'package:we_pei_yang_flutter/commons/new_network/dio_manager.dart';
import 'package:we_pei_yang_flutter/commons/new_network/error_interceptor.dart'
    show WpyDioError;
import 'package:dio/dio.dart' show Options, Response;
import 'dart:convert' show utf8, base64Encode;

class AuthDio extends DioAbstract {
  static const APP_KEY = "banana";
  static const APP_SECRET = "37b590063d593716405a2c5a382b1130b28bf8a7";
  static const DOMAIN = "weipeiyang.twt.edu.cn";
  static String ticket = base64Encode(utf8.encode(APP_KEY + '.' + APP_SECRET));

  @override
  String baseUrl = "https://api.twt.edu.cn/api/";

  @override
  Map<String, String> headers = {"DOMAIN": DOMAIN, "ticket": ticket};

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (Options options) {
      var pref = CommonPreferences();
      options.headers['token'] = pref.token.value;
      options.headers['Cookie'] = pref.captchaCookie.value;
    }, onResponse: (Response response) {
      print(response.toString());
      var code = response?.data['error_code'] ?? -1;
      switch (code) {
        case 40002:
          throw WpyDioError(error: "该用户不存在");
          break;
        case 40004:
          throw WpyDioError(error: "用户名或密码错误");
          break;
        case 40005:
          Navigator.pushNamedAndRemoveUntil(
              WePeiYangApp.navigatorState.currentContext,
              AuthRouter.login,
              (route) => false);
          throw WpyDioError(error: "登录失效，请重新登录");
          break;
        case 50005:
          throw WpyDioError(error: "学号和身份证号不匹配");
          break;
        case 50006:
          throw WpyDioError(error: "用户名和邮箱已存在");
          break;
        case 50007:
          throw WpyDioError(error: "用户名已存在");
          break;
        case 50008:
          throw WpyDioError(error: "邮箱已存在");
          break;
        case 50009:
          throw WpyDioError(error: "手机号码无效");
          break;
        case 50011:
          throw WpyDioError(error: "验证失败，请重新尝试");
          break;
        case 50012:
          throw WpyDioError(error: "电子邮件或手机号格式不规范");
          break;
        case 50013:
          throw WpyDioError(error: "电子邮件或手机号重复");
          break;
        case 50014:
          throw WpyDioError(error: "手机号已存在");
          break;
        case 50015:
          throw WpyDioError(error: "升级失败，目标升级账号信息不存在");
          break;
        case 50016:
          throw WpyDioError(error: "无此学院");
          break;
        case 50019:
          throw WpyDioError(error: "用户名中含有非法字符");
          break;
        case 50020:
          throw WpyDioError(error: "用户名过长");
          break;
        case 50021:
          throw WpyDioError(error: "该学号所属用户已注册过");
          break;
        case 50022:
          throw WpyDioError(error: "该身份证号未在系统中登记");
          break;
        case 40001:
        case 40003:
        case 50001:
        case 50002:
        case 50003:
        case 50004:
        case 50010:
          print("请求发生错误，error_code: $code, msg: ${response?.data['msg']}");
          throw WpyDioError(error: "发生未知错误，请重新尝试");
      }
    })
  ];
}

final _dio = AuthDio();

/// 注册或完善信息时获取短信验证码
getCaptchaOnRegister(String phone,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    var response = await _dio
        .post("register/phone/msg", queryParameters: {"phone": phone});
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 在用户界面更新信息时获取短信验证码
getCaptchaOnInfo(String phone,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    var response =
        await _dio.post("user/phone/msg", queryParameters: {"phone": phone});
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 修改密码时获取短信验证码
getCaptchaOnReset(String phone,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    var response = await _dio
        .post("password/reset/msg", queryParameters: {"phone": phone});
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 修改密码时认证短信验证码
verifyOnReset(String phone, String code,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    var response = await _dio.post("password/reset/verify",
        queryParameters: {"phone": phone, "code": code});
    var cookie = response.headers.map['set-cookie'];
    if (cookie != null) {
      CommonPreferences().captchaCookie.value =
          getRegExpStr(r'\S+(?=\;)', cookie[0]);
    }
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 忘记密码时，使用手机号修改密码
resetPwByPhone(String phone, String password,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.post("password/reset",
        queryParameters: {"phone": phone, "password": password});
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 登录状态下修改密码
resetPwByLogin(String password,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    await _dio
        .put("password/person/reset", queryParameters: {"password": password});
    CommonPreferences().password.value = password;
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 注册
register(String userNumber, String nickname, String phone, String verifyCode,
    String password, String email, String idNumber,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.post("register", queryParameters: {
      "userNumber": userNumber,
      "nickname": nickname,
      "phone": phone,
      "verifyCode": verifyCode,
      "password": password,
      "email": email,
      "idNumber": idNumber
    });
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 使用学号/昵称/邮箱登录
void login(String account, String password,
    {@required OnResult onResult, OnFailure onFailure}) async {
  try {
    var result = await _dio.postRst("auth/common",
        queryParameters: {"account": account, "password": password});
    var prefs = CommonPreferences();
    prefs.token.value = result['token'] ?? "";
    if (prefs.account.value != account && prefs.account.value != "") {
      /// 使用新账户登陆时，清除旧帐户的课程表和gpa缓存
      prefs.clearTjuPrefs();
    }
    log(result.toString());
    prefs.account.value = account;
    prefs.password.value = password;
    prefs.nickname.value = result['nickname'] ?? "";
    prefs.userNumber.value = result['userNumber'] ?? "";
    prefs.phone.value = result['telephone'] ?? "";
    prefs.email.value = result['email'] ?? "";
    prefs.realName.value = result['realname'] ?? "";
    prefs.department.value = result['department'] ?? "";
    prefs.major.value = result['major'] ?? "";
    prefs.stuType.value = result['stuType'] ?? "";
    prefs.isLogin.value = true;
    onResult(result);

    /// 登录成功后尝试更新学期信息
    getSemesterInfo();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 补全信息（手机号和邮箱）
addInfo(String telephone, String verifyCode, String email,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.put("user/single", queryParameters: {
      "telephone": telephone,
      "verifyCode": verifyCode,
      "email": email
    });
    var prefs = CommonPreferences();
    prefs.phone.value = telephone;
    prefs.email.value = email;
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 单独修改手机号
changePhone(String phone, String code,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.put("user/single/phone",
        queryParameters: {'phone': phone, 'code': code});
    CommonPreferences().phone.value = phone;
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 单独修改邮箱
changeEmail(String email,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.put("user/single/email", queryParameters: {'email': email});
    CommonPreferences().email.value = email;
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 单独修改用户名
changeNickname(String username,
    {@required void Function() onSuccess, OnFailure onFailure}) async {
  try {
    await _dio
        .put("user/single/username", queryParameters: {'username': username});
    CommonPreferences().nickname.value = username;
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 检测学号和用户名是否重复
checkInfo1(String userNumber, String username,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.get("register/checking/$userNumber/$username");
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 检测身份证、邮箱、手机号是否重复（其实手机号不用查重，获取验证码时已经查重过了）
checkInfo2(String idNumber, String email, String phone,
    {@required OnSuccess onSuccess, OnFailure onFailure}) async {
  try {
    await _dio.post("register/checking", queryParameters: {
      'idNumber': idNumber,
      'email': email,
      'phone': phone
    });
    onSuccess();
  } on DioError catch (e) {
    if (onFailure != null) onFailure(e);
  }
}

/// 获得当前学期信息，在用户 手动/自动 登录后被调用
getSemesterInfo() async {
  try {
    var result = await _dio.getRst("semester");
    var pref = CommonPreferences();
    pref.termStart.value = result['semesterStartTimestamp'];
    pref.termName.value = result['semesterName'];
    pref.termStartDate.value = result['semesterStartAt'];
    // TODO: 这里留着下学期开学用
    // print("hahahhahahahahaahhahahahahahahahahahaha");
    // print(result);
    // print(result['semesterStartTimestamp']);
    // print(result['semesterName']);
    // print("dhsauodhaudhashdsahkdjshjdajdajshdjashjda");
  } on DioError catch (e) {
    log('获取学期信息失败\t$e\n\tMessage: ${e.message}');
  }
}
