import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/auth/view/info/email_bind_page.dart';
import 'package:we_pei_yang_flutter/auth/view/info/phone_bind_page.dart';
import 'package:we_pei_yang_flutter/auth/view/info/reset_password_page.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_bind_page.dart';
import 'package:we_pei_yang_flutter/auth/view/info/reset_nickname_page.dart';
import 'package:we_pei_yang_flutter/auth/view/info/user_info_page.dart';
import 'package:we_pei_yang_flutter/auth/view/info/avatar_crop_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/add_info_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/find_pw_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/login_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/login_pw_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/register_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/reset_done_page.dart';
import 'package:we_pei_yang_flutter/auth/view/login/reset_pw_page.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/color_setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/general_setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/language_setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/theme_change_page.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/schedule_setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/settings/setting_page.dart';
import 'package:we_pei_yang_flutter/auth/view/user/debug_page.dart';
import 'package:we_pei_yang_flutter/auth/view/user/about_twt_page.dart';

import 'view/message/user_mails_page.dart';

class AuthRouter {
  /// 登录部分
  static String login = 'login/home';
  static String loginPw = 'login/login_pw';
  static String register1 = 'login/register1';
  static String register2 = 'login/register2';
  static String register3 = 'login/register3';
  static String addInfo = 'login/add_info';
  static String findHome = 'login/find_home';
  static String findPhone = 'login/find_phone';
  static String resetPw = 'login/reset';
  static String resetDone = 'login/reset_done';

  /// 个人信息页
  static String tjuBind = 'info/tjuBind';
  static String phoneBind = 'info/phoneBind';
  static String emailBind = 'info/emailBind';
  static String resetName = 'info/resetName';
  static String resetPassword = 'info/resetPassword';
  static String userInfo = 'info/home';
  static String avatarCrop = 'info/avatar_crop';

  /// 个人页 & 设置页
  static String setting = 'setting/home';
  static String generalSetting = 'setting/general_setting';
  static String languageSetting = 'setting/language_setting';
  static String scheduleSetting = 'setting/schedule_setting';
  static String colorSetting = 'setting/color_setting';
  static String themeSetting = 'setting/theme_setting';

  static String mailbox = "user/mailbox";
  static String aboutTwt = "user/about_twt";

  /// debug页面
  static String debug = 'user/debug';

  static final Map<String, Widget Function(Object arguments)> routers = {
    login: (_) => LoginHomeWidget(),
    loginPw: (_) => LoginPwWidget(),
    register1: (_) => RegisterPageOne(),
    register2: (arg) {
      var map = arg as Map;
      return RegisterPageTwo(
          map['userNum'], map['nickname'], map['idNum'], map['email']);
    },
    register3: (arg) {
      var map = arg as Map;
      return RegisterPageThree(map['userNum'], map['nickname'], map['idNum'],
          map['email'], map['phone'], map['code']);
    },
    addInfo: (_) => AddInfoWidget(),
    findHome: (_) => FindPwWidget(),
    findPhone: (_) => FindPwByPhoneWidget(),
    resetPw: (_) => ResetPwWidget(), // 这个是登录时的修改密码
    resetDone: (_) => ResetDoneWidget(),
    tjuBind: (_) => TjuBindPage(),
    phoneBind: (_) => PhoneBindPage(),
    emailBind: (_) => EmailBindPage(),
    resetName: (_) => ResetNicknamePage(),
    resetPassword: (_) => ResetPasswordPage(), // 这个是个人信息页面的修改密码
    userInfo: (_) => UserInfoPage(),
    avatarCrop: (_) => AvatarCropPage(),
    setting: (_) => SettingPage(),
    generalSetting: (_) => GeneralSettingPage(),
    languageSetting: (_) => LanguageSettingPage(),
    scheduleSetting: (_) => ScheduleSettingPage(),
    themeSetting: (_) => ThemeChangePage(),
    colorSetting: (_) => ColorSettingPage(),
    mailbox: (_) => UserMailboxPage(),
    aboutTwt: (_) => AboutTwtPage(),
    debug: (_) => DebugPage(),
  };
}
