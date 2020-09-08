import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; //Timer
import 'dart:io'; //Platform

import 'package:wei_pei_yang_demo/model.dart';
import 'package:wei_pei_yang_demo/home.dart';
import 'package:wei_pei_yang_demo/more.dart';
import 'package:wei_pei_yang_demo/user.dart';

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
        '/login': (ctx) => LoginWidget(),
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

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  var emailEdit = false;
  var pwEdit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Theme(
        //取消label文本高亮显示
        data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.grey))),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(30.0, 100.0, 30.0, 0.0),
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                    color: MyColors.deepBlue,
                    fontSize: 30.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40.0, 100.0, 40.0, 0.0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: 'email',
                    contentPadding: EdgeInsets.only(top: 5.0),
                    suffixIcon: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Icon(Icons.check_circle,
                            size: emailEdit ? 18.0 : 0.0))),
                onChanged: (input) => setState(() {
                  emailEdit = input.isNotEmpty;
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'password',
                    contentPadding: EdgeInsets.only(top: 5.0),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child:
                          Icon(Icons.check_circle, size: pwEdit ? 18.0 : 0.0),
                    )),
                onChanged: (input) => setState(() {
                  pwEdit = input.isNotEmpty;
                }),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 50.0),
              child: GestureDetector(
                child: Text(
                  'Forget password?',
                  style: TextStyle(fontSize: 12.0, color: Colors.blue),
                ),
                onTap: () {},
              ),
            ),
            Container(
                height: 50.0,
                width: 400.0,
                padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
                child: RaisedButton(
                  onPressed: login,
                  color: MyColors.deepBlue,
                  child: Text('login', style: TextStyle(color: Colors.white)),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                )),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 0.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Need an account ?',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      child: Text(
                        'signup',
                        style: TextStyle(fontSize: 12.0, color: Colors.blue),
                      ),
                      onTap: () {},
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  login() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
