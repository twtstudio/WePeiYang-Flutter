import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'auth/view/tju_bind_page.dart';
import 'home/model/home_model.dart';
import 'home/home_page.dart';
import 'home/more_page.dart';
import 'home/user_page.dart';
import 'auth/view/login_page.dart';
import 'package:wei_pei_yang_demo/gpa/gpa_notifier.dart';
import 'gpa/gpa_page.dart' show GPAPage;
import 'package:wei_pei_yang_demo/schedule/view/schedule_page.dart'
    show SchedulePage;
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

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
        '/login': (ctx) => LoginWidget(),
        '/bind': (ctx) => TjuBindWidget(),
        '/home': (ctx) => HomePage(),
        '/user': (ctx) => UserPage(),
        '/schedule': (ctx) => SchedulePage(),
        '/telNum': (ctx) => LoginWidget(),
        '/learning': (ctx) => LoginWidget(),
        '/library': (ctx) => LoginWidget(),
        '/cards': (ctx) => LoginWidget(),
        '/gpa': (ctx) => GPAPage(),
        '/classroom': (ctx) => LoginWidget(),
        '/coffee': (ctx) => LoginWidget(),
        '/byBus': (ctx) => LoginWidget(),
        '/more': (ctx) => MorePage(),
      },
      home: StartUpWidget(),
    );
  }
}

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
    if (!prefs.isLogin) {
      /// 既然没登陆过就多看会启动页吧
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    /// 稍微显示一会启动页，不然它的意义是什么555
    else {
      // TODO 为啥会请求两次呢 迷
      Timer(Duration(milliseconds: 500), () {
        /// 用缓存中的数据自动登录，失败则仍跳转至login页面（shorted的意思是：3秒内登不上就撤）
        getToken(prefs.username, prefs.password, shorted: true, onSuccess: () {
          if (context != null) Navigator.pushReplacementNamed(context, '/home');
        }, onFailure: (_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      });
    }
  }
}
