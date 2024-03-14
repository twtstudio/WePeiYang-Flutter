import 'dart:convert' show base64Encode, json, utf8;
import 'dart:io';

import 'package:dio_cookie_caching_handler/dio_cookie_interceptor.dart';
import 'package:flutter/material.dart' show Navigator, debugPrint;
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:we_pei_yang_flutter/auth/model/nacid_info.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/main.dart';

class AuthDio extends DioAbstract {
  static const APP_KEY = "banana";
  static const APP_SECRET = "37b590063d593716405a2c5a382b1130b28bf8a7";
  static const DOMAIN = "weipeiyang.twt.edu.cn";
  static String ticket = base64Encode(utf8.encode(APP_KEY + '.' + APP_SECRET));

  @override
  String baseUrl = "https://api.twt.edu.cn/api/";

  @override
  Map<String, String>? headers = {"DOMAIN": DOMAIN, "ticket": ticket};

  @override
  List<Interceptor> interceptors = [cookieCachedHandler()];

  @override
  InterceptorsWrapper? get errorInterceptor =>
      InterceptorsWrapper(onRequest: (options, handler) {
        options.headers['token'] = CommonPreferences.token.value;
        print("token: " + CommonPreferences.token.value);
        return handler.next(options);
      }, onResponse: (response, handler) {
        var code = response.data['error_code'] ?? -1;
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
                WePeiYangApp.navigatorState.currentContext!,
                AuthRouter.login,
                (route) => false);
            error = "登录失效，请重新登录";
            break;
          case 50001:
            error = '未知错误';
            break;
          // error = "数据库错误";
          // break;
          case 50002:
            error = '未知错误';
            break;
          // error = "逻辑错误或数据库错误";
          // break;
          case 50003:
            error = '未知错误';
            break;
          // error = "未绑定的url，请联系管理员";
          // break;
          case 50004:
            error = '未知错误';
            break;
          // error = "错误的app_key或app_secret";
          // break;
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
          case 50010:
            error = "发生未知错误，请重新尝试或联系管理员：错误码$code";
        }
        if (error == "")
          return handler.next(response);
        else
          return handler.reject(WpyDioException(error: error), true);
      });
}

final authDio = AuthDio();

class AuthService with AsyncTimer {
  /// 注册或完善信息时获取短信验证码
  static getCaptchaOnRegister(String phone,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnRegister', () async {
      try {
        await authDio
            .post("register/phone/msg", queryParameters: {"phone": phone});
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 在用户界面更新信息时获取短信验证码
  static getCaptchaOnInfo(String phone,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnInfo', () async {
      try {
        // TODO: 这个是坏的
        await authDio.post("user/phone/msg",
            data: {"phone": phone},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 修改密码时获取短信验证码
  static getCaptchaOnReset(String phone,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnReset', () async {
      try {
        await authDio
            .post("password/reset/msg", queryParameters: {"phone": phone});
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 修改密码时认证短信验证码
  static verifyOnReset(String phone, String code,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('verifyOnReset', () async {
      try {
        await authDio.post("password/reset/verify",
            data: {"phone": phone, "code": code},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 忘记密码时，使用手机号修改密码
  static resetPwByPhone(String phone, String password,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('resetPwByPhone', () async {
      try {
        await authDio.post("password/reset",
            data: {"phone": phone, "password": password},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  ///发通知用
  ///友盟flutter推送sdk直接接不进来，文档依托答辩，正在试别的方法
  // static postMessage()async
  // {
  //   AsyncTimer.runRepeatChecked('Message', () async {
  //     try {
  //       await authDio.post("notification/toUser",
  //           data: {"userNumbers": "3020233414", "title": "fxxk", "content": "yeeeeeeeee", "url": "https://img-blog.csdnimg.cn/img_convert/f9ba8d1271c648183b5097c409cb5028.png",},
  //           options: Options(contentType: Headers.formUrlEncodedContentType));
  //       ToastProvider.success("成啦兄弟");
  //     } on DioError catch (e) {
  //       ToastProvider.error(e.message);
  //     }
  //   });
  // }

  /// 登录状态下修改密码
  static resetPwByLogin(String password,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('resetPwByLogin', () async {
      try {
        await authDio.put("password/person/reset",
            queryParameters: {"password": password});
        CommonPreferences.password.value = password;
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 注册
  static register(String userNumber, String nickname, String phone,
      String verifyCode, String password, String email, String idNumber,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('register', () async {
      try {
        await authDio.post("register",
            data: {
              "userNumber": userNumber,
              "nickname": nickname,
              "phone": phone,
              "verifyCode": verifyCode,
              "password": password,
              "email": email,
              "idNumber": idNumber
            },
            options: Options(contentType: Headers.formUrlEncodedContentType));
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 使用学号/昵称/邮箱/手机号 + 密码登录
  static pwLogin(String account, String password,
      {required OnResult<Map> onResult, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('pwLogin', () async {
      try {
        var rsp = await authDio.post("auth/common",
            data: {"account": account, "password": password},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        var result = rsp.data['result'];
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
        CommonPreferences.accountUpgrade.value = result['upgradeNeed'] == null
            ? []
            : List<String>.from(
                result['upgradeNeed'].map((x) => json.encode(x)));
        onResult(result);

        /// 登录成功后尝试更新学期信息
        await getSemesterInfo();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 登陆时获取短信验证码
  static getCaptchaOnLogin(String phone,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getCaptchaOnLogin', () async {
      try {
        await authDio.post("auth/phone/msg",
            data: {"phone": phone},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 使用手机号 + 验证码登录
  static codeLogin(String phone, String code,
      {required OnResult<Map> onResult, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('codeLogin', () async {
      try {
        var rsp = await authDio.post("auth/phone",
            data: {"phone": phone, "code": code},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        var result = rsp.data['result'];
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
        CommonPreferences.accountUpgrade.value = result['upgradeNeed'] == null
            ? []
            : List<String>.from(
                result['upgradeNeed'].map((x) => json.encode(x)));
        onResult(result);

        /// 登录成功后尝试更新学期信息
        await getSemesterInfo();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取个人信息（刷新token用）
  static getInfo(
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('getInfo', () async {
      try {
        var rsp = await authDio.post('auth/updateToken');
        var result = rsp.data['result'];
        if (result != null) {
          CommonPreferences.token.value = result;
        }
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 补全信息（手机号和邮箱）
  static addInfo(String telephone, String verifyCode, String email,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
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
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 单独修改手机号
  static changePhone(String phone, String code,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('changePhone', () async {
      try {
        await authDio.put("user/single/phone",
            queryParameters: {'phone': phone, 'code': code});
        CommonPreferences.phone.value = phone;
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 单独修改邮箱
  static changeEmail(String email,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('changeEmail', () async {
      try {
        await authDio
            .put("user/single/email", queryParameters: {'email': email});
        CommonPreferences.email.value = email;
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 单独修改用户名
  static changeNickname(String username,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('changeNickname', () async {
      try {
        await authDio.put("user/single/username",
            queryParameters: {'username': username});
        CommonPreferences.nickname.value = username;
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 检测学号和用户名是否重复
  static checkInfo1(String userNumber, String username,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('checkInfo1', () async {
      try {
        await authDio.get("register/checking/$userNumber/$username",
            debug: true);
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 检测身份证、邮箱、手机号是否重复（其实手机号不用查重，获取验证码时已经查重过了）
  static checkInfo2(String idNumber, String email, String phone,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('checkInfo2', () async {
      try {
        await authDio.post("register/checking",
            data: {'idNumber': idNumber, 'email': email, 'phone': phone},
            options: Options(contentType: Headers.formUrlEncodedContentType));
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获得当前学期信息，在用户 手动/自动 登录后被调用
  static getSemesterInfo() async {
    try {
      var rsp = await authDio.get("semester");
      var result = rsp.data['result'];
      CommonPreferences.termStart.value = result['semesterStartTimestamp'];
      CommonPreferences.termName.value = result['semesterName'];
      CommonPreferences.termStartDate.value = result['semesterStartAt'];
      MethodChannel('com.twt.service/widget')
          .invokeMethod("refreshScheduleWidget");
    } on DioException catch (_) {}
  }

  /// 上传头像
  static uploadAvatar(File image,
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
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
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 注销账号
  static logoff(
      {required OnSuccess onSuccess, required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('logoff', () async {
      try {
        await authDio.post("auth/logoff");
        onSuccess();
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  /// 获取cid
  static updateCid(String cid,
      {required OnResult<String> onResult,
      required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('updateCid', () async {
      try {
        var res = await authDio.post("notification/cid",
            data: {'cid': cid},
            options: Options(contentType: Headers.formUrlEncodedContentType));

        onResult(res.data.toString());
      } on DioException catch (e) {
        onFailure(e);
      }
    });
  }

  static Future<NAcidInfo> checkNuclearAcid() async {
    try {
      var rsp = await authDio.get('checkHeSuan');
      if (rsp.data['result'] == '无核酸')
        return NAcidInfo(id: -1);
      else
        return NAcidInfo.fromJson(rsp.data['result']);
    } on DioException catch (e) {
      debugPrint(e.error.toString());
    }
    return NAcidInfo(id: -1);
  }

  static Future<bool> accountUpgrade() async {
    try {
      var tmp = CommonPreferences.accountUpgrade.value;
      var res = json.decode(tmp[0]);
      var rsp =
          await authDio.put("upgrade", queryParameters: {"typeId": res['id']});
      if (rsp.data['error_code'] == 0) {
        CommonPreferences.token.value = rsp.data['result'];
        return true;
      } else
        return false;
    } on DioException {
      return false;
    }
  }
}
