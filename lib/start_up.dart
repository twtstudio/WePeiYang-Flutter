import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'model.dart';
import 'home/home_page.dart';
import 'home/more_page.dart';
import 'home/user_page.dart';
import 'home/net_page.dart';
import 'home/login_page.dart';

void main() {
  runApp(WeiPeiYangApp());
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeiPeiYangDemo',
      routes: <String, WidgetBuilder>{
        // '/login': (ctx) => LoginWidget(),
        '/login': (ctx) => CPage(),
        '/home': (ctx) => HomePage(),
        '/user': (ctx) => UserPage(),
        '/bicycle': (ctx) => LoginWidget(),
        '/telNum': (ctx) => LoginWidget(),
        '/learning': (ctx) => LoginWidget(),
        '/library': (ctx) => LoginWidget(),
        '/cards': (ctx) => LoginWidget(),
        '/gpa': (ctx) => LoginWidget(),
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    GlobalModel.getInstance().screenWidth = width;
    GlobalModel.getInstance().screenHeight = height;
    Timer(Duration(seconds: 5), () {
//      var prefs = await SharedPreferences.getInstance();
//      if (prefs.getBool('login') ?? false) {}
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
