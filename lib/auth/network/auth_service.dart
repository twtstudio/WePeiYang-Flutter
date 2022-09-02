import 'dart:io';
import 'dart:convert' show utf8, base64Encode;
import 'package:flutter/material.dart' show BuildContext, Navigator, required;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

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
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.token.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response?.data['error_code'] ?? -1;
      var error = "";
      switch (code) {
        case 40002:
          error = "该用户不存在";
          break;
        case 40004:
          error = "用户名或密码错误";
          break;
        case 40005:
          Navigator.pushNamedAndRemoveUntil(
              WePeiYangApp.navigatorState.currentContext,
              AuthRouter.login,
              (route) => false);
          error = "登录失效，请重新登录";
          break;
        case 50005:
          error = "学号和身份证号不匹配";
          break;
        case 50006:
          error = "用户名和邮箱已存在";
          break;
        case 50007:
          error = "用户名已存在";
          break;
        case 50008:
          error = "邮箱已存在";
          break;
        case 50009:
          error = "手机号码无效";
          break;
        case 50011:
          error = "验证失败，请重新尝试";
          break;
        case 50012:
          error = "电子邮件或手机号格式不规范";
          break;
        case 50013:
          error = "电子邮件或手机号重复";
          break;
        case 50014:
          error = "手机号已存在";
          break;
        case 50015:
          error = "升级失败，目标升级账号信息不存在";
          break;
        case 50016:
          error = "无此学院";
          break;
        case 50019:
          error = "用户名中含有非法字符";
          break;
        case 50020:
          error = "用户名过长";
          break;
        case 50021:
          error = "该学号所属用户已注册过";
          break;
        case 50022:
          error = "该身份证号未在系统中登记";
          break;
        case 40001:
        case 40003:
        case 50001:
        case 50002:
        case 50003:
        case 50004:
        case 50010:
          error = "发生未知错误，请重新尝试 $code";
      }
      if (error == "")
        return handler.next(response);
      else
        return handler.reject(WpyDioError(error: error), true);
    })
  ];
}

final authDio = AuthDio();

class AuthService with AsyncTimer {
  /// 注册或完善信息时获取短信验证码
  static getCaptchaOnRegister(String phone,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnRegister', () async {
      try {
        await authDio
            .post("register/phone/msg", queryParameters: {"phone": phone});
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 在用户界面更新信息时获取短信验证码
  static getCaptchaOnInfo(String phone,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnInfo', () async {
      try {
        await authDio.post("user/phone/msg", queryParameters: {"phone": phone});
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 修改密码时获取短信验证码
  static getCaptchaOnReset(String phone,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnReset', () async {
      try {
        await authDio
            .post("password/reset/msg", queryParameters: {"phone": phone});
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 修改密码时认证短信验证码
  static verifyOnReset(String phone, String code,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('verifyOnReset', () async {
      try {
        await authDio.post("password/reset/verify",
            queryParameters: {"phone": phone, "code": code});
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 忘记密码时，使用手机号修改密码
  static resetPwByPhone(String phone, String password,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('resetPwByPhone', () async {
      try {
        await authDio.post("password/reset",
            queryParameters: {"phone": phone, "password": password});
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 登录状态下修改密码
  static resetPwByLogin(String password,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('resetPwByLogin', () async {
      try {
        await authDio.put("password/person/reset",
            queryParameters: {"password": password});
        CommonPreferences.password.value = password;
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 注册
  static register(String userNumber, String nickname, String phone,
      String verifyCode, String password, String email, String idNumber,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('register', () async {
      try {
        await authDio.post("register", queryParameters: {
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
        onFailure(e);
      }
    });
  }

  /// 使用学号/昵称/邮箱/手机号 + 密码登录
  static pwLogin(String account, String password,
      {@required OnResult<Map> onResult, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('pwLogin', () async {
      try {
        var result = await authDio.postRst("auth/common",
            queryParameters: {"account": account, "password": password});
        CommonPreferences.token.value = result['token'] ?? "";
        if (CommonPreferences.account.value != account &&
            CommonPreferences.account.value != "") {
          /// 使用新账户登录时，清除旧帐户的课程表和gpa缓存
          CommonPreferences.clearTjuPrefs();
        }
        CommonPreferences.account.value = account;
        CommonPreferences.password.value = password;
        CommonPreferences.nickname.value = result['nickname'] ?? "";
        CommonPreferences.userNumber.value = result['userNumber'] ?? "";
        CommonPreferences.phone.value = result['telephone'] ?? "";
        CommonPreferences.email.value = result['email'] ?? "";
        CommonPreferences.realName.value = result['realname'] ?? "";
        CommonPreferences.department.value = result['department'] ?? "";
        CommonPreferences.major.value = result['major'] ?? "";
        CommonPreferences.stuType.value = result['stuType'] ?? "";
        CommonPreferences.avatar.value = result['avatar'] ?? "";
        CommonPreferences.area.value = result['area'] ?? "";
        CommonPreferences.building.value = result['building'] ?? "";
        CommonPreferences.floor.value = result['floor'] ?? "";
        CommonPreferences.room.value = result['room'] ?? "";
        CommonPreferences.bed.value = result['bed'] ?? "";
        CommonPreferences.isLogin.value = true;
        onResult(result);

        /// 登录成功后尝试更新学期信息
        await getSemesterInfo();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 登陆时获取短信验证码
  static getCaptchaOnLogin(String phone,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnLogin', () async {
      try {
        await authDio.post("auth/phone/msg", queryParameters: {"phone": phone});
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 使用手机号 + 验证码登录
  static codeLogin(String phone, String code,
      {@required OnResult<Map> onResult, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('codeLogin', () async {
      try {
        var result = await authDio.postRst("auth/phone",
            queryParameters: {"phone": phone, "code": code});
        CommonPreferences.token.value = result['token'] ?? "";
        if (CommonPreferences.phone.value != phone &&
            CommonPreferences.phone.value != "") {
          /// 使用新账户登录时，清除旧帐户的课程表和gpa缓存
          CommonPreferences.clearTjuPrefs();
        }
        CommonPreferences.nickname.value = result['nickname'] ?? "";
        CommonPreferences.userNumber.value = result['userNumber'] ?? "";
        CommonPreferences.phone.value = phone;
        CommonPreferences.email.value = result['email'] ?? "";
        CommonPreferences.realName.value = result['realname'] ?? "";
        CommonPreferences.department.value = result['department'] ?? "";
        CommonPreferences.major.value = result['major'] ?? "";
        CommonPreferences.stuType.value = result['stuType'] ?? "";
        CommonPreferences.avatar.value = result['avatar'] ?? "";
        CommonPreferences.area.value = result['area'] ?? "";
        CommonPreferences.building.value = result['building'] ?? "";
        CommonPreferences.floor.value = result['floor'] ?? "";
        CommonPreferences.room.value = result['room'] ?? "";
        CommonPreferences.bed.value = result['bed'] ?? "";
        CommonPreferences.isLogin.value = true;
        onResult(result);

        /// 登录成功后尝试更新学期信息
        await getSemesterInfo();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取个人信息（刷新token用）
  static getInfo(
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getInfo', () async {
      try {
        var result = await authDio.getRst('user/single');
        if (result['token'] != null) {
          CommonPreferences.token.value = result['token'];
        }
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 补全信息（手机号和邮箱）
  static addInfo(String telephone, String verifyCode, String email,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('addInfo', () async {
      try {
        await authDio.put("user/single", queryParameters: {
          "telephone": telephone,
          "verifyCode": verifyCode,
          "email": email
        });
        CommonPreferences.phone.value = telephone;
        CommonPreferences.email.value = email;
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 单独修改手机号
  static changePhone(String phone, String code,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('changePhone', () async {
      try {
        await authDio.put("user/single/phone",
            queryParameters: {'phone': phone, 'code': code});
        CommonPreferences.phone.value = phone;
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 单独修改邮箱
  static changeEmail(String email,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('changeEmail', () async {
      try {
        await authDio
            .put("user/single/email", queryParameters: {'email': email});
        CommonPreferences.email.value = email;
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 单独修改用户名
  static changeNickname(String username,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('changeNickname', () async {
      try {
        await authDio.put("user/single/username",
            queryParameters: {'username': username});
        CommonPreferences.nickname.value = username;
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 检测学号和用户名是否重复
  static checkInfo1(String userNumber, String username,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('checkInfo1', () async {
      try {
        await authDio.get("register/checking/$userNumber/$username");
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 检测身份证、邮箱、手机号是否重复（其实手机号不用查重，获取验证码时已经查重过了）
  static checkInfo2(String idNumber, String email, String phone,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('checkInfo2', () async {
      try {
        await authDio.post("register/checking", queryParameters: {
          'idNumber': idNumber,
          'email': email,
          'phone': phone
        });
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获得当前学期信息，在用户 手动/自动 登录后被调用
  static getSemesterInfo() async {
    try {
      var result = await authDio.getRst("semester");
      CommonPreferences.termStart.value = result['semesterStartTimestamp'];
      CommonPreferences.termName.value = result['semesterName'];
      CommonPreferences.termStartDate.value = result['semesterStartAt'];
    } on DioError catch (_) {}
  }

  /// 上传头像
  static uploadAvatar(File image,
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('uploadAvatar', () async {
      try {
        var data = FormData.fromMap({
          'avatar': MultipartFile.fromBytes(
            image.readAsBytesSync(),
            filename: image.path,
            contentType: MediaType("image", "jpg"),
          ),
        });
        await authDio.post("user/avatar", formData: data);
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 注销账号
  static logoff(
      {@required OnSuccess onSuccess, @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('logoff', () async {
      try {
        await authDio.post("auth/logoff");
        onSuccess();
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取cid
  static updateCid(BuildContext context,
      {@required OnResult<String> onResult,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('updateCid', () async {
      try {
        final manager = context.read<PushManager>();
        final cid = await manager.getCid();
        await authDio.post("notification/cid",
            formData: FormData.fromMap({'cid': cid}));
        onResult(cid);
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}
