import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/auth/view/login_phone_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login_pw_page.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'auth/view/find_pw_page.dart';
import 'auth/view/tju_bind_page.dart';
import 'home/model/home_model.dart';
import 'home/view/home_page.dart';
import 'home/view/more_page.dart';
import 'auth/view/user_page.dart';
import 'auth/view/login_page.dart';
import 'gpa/model/gpa_notifier.dart';
import 'gpa/view/gpa_page.dart' show GPAPage;
import 'schedule/view/schedule_page.dart'
    show SchedulePage;
import 'commons/preferences/common_prefs.dart';

void main() async {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => GPANotifier()),
    ChangeNotifierProvider(create: (context) => ScheduleNotifier()),
  ], child: WeiPeiYangApp()));

  /// 设置沉浸式状态栏
  if (Platform.isAndroid) {
    var dark = SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarDividerColor: null,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(dark);
  }
}

class WeiPeiYangApp extends StatelessWidget {
  /// 用于全局获取当前context
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeiPeiYangDemo',
      navigatorKey: navigatorState,
      theme: ThemeData(
          // fontFamily: 'Montserrat'
          ),
      routes: <String, WidgetBuilder>{
        '/login': (ctx) => LoginHomeWidget(),
        '/login_pw': (ctx) => LoginPwWidget(),
        '/login_phone': (ctx) => LoginPhoneWidget(),
        '/find_home': (ctx) => FindPwWidget(),
        '/find_phone': (ctx) => FindPwByPhoneWidget(),
        '/bind': (ctx) => TjuBindWidget(),
        '/home': (ctx) => HomePage(),
        '/user': (ctx) => UserPage(),
        '/schedule': (ctx) => SchedulePage(),
        '/telNum': (ctx) => LoginHomeWidget(),
        '/learning': (ctx) => LoginHomeWidget(),
        '/library': (ctx) => LoginHomeWidget(),
        '/cards': (ctx) => LoginHomeWidget(),
        '/gpa': (ctx) => GPAPage(),
        '/classroom': (ctx) => LoginHomeWidget(),
        '/coffee': (ctx) => LoginHomeWidget(),
        '/byBus': (ctx) => LoginHomeWidget(),
        '/more': (ctx) => MorePage(),
      },
      home: StartUpWidget(),
    );
  }
}

/// 启动页Widget
class StartUpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    GlobalModel.getInstance().screenWidth = width;
    GlobalModel.getInstance().screenHeight = height;

    _autoLogin(context);

    return ConstrainedBox(
      child: Image(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/splash_screen.png')),
      constraints: BoxConstraints.expand(),
    );
  }

  void _autoLogin(BuildContext context) async {
    /// 初始化sharedPrefs
    await CommonPreferences.initPrefs();
    var prefs = CommonPreferences.create();
    if (!prefs.isLogin.value ||
        prefs.account.value == "" ||
        prefs.password.value == "") {
      /// 既然没登陆过就多看会启动页吧
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    /// 稍微显示一会启动页，不然它的意义是什么555
    else {
      // TODO 为啥会请求两次呢 迷
      Timer(Duration(milliseconds: 500), () {
        /// 用缓存中的数据自动登录，失败则仍跳转至login页面
        login(prefs.account.value, prefs.password.value, onSuccess: () {
          if (context != null) Navigator.pushReplacementNamed(context, '/home');
        }, onFailure: (_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      });
    }
  }
}
