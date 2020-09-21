import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/gpa/gpa_notifier.dart';

import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'auth/view/tju_bind_page.dart';
import 'gpa/gpa_page.dart';
import 'home/model/home_model.dart';
import 'home/home_page.dart';
import 'home/more_page.dart';
import 'home/user_page.dart';
import 'auth/view/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GPANotifier(),
      child: WeiPeiYangApp(),
    )
  );
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
        '/bicycle': (ctx) => LoginWidget(),
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
    /// 微北洋启动页，显示3秒钟
    Timer(Duration(seconds: 3), () {
    //TODO 登录判断
      Navigator.pushReplacementNamed(context, '/login');
    });
    return ConstrainedBox(
      child: Image(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/splash_screen.png')),
      constraints: BoxConstraints.expand(),
    );
  }
}