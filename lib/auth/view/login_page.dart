import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;

import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/network/network_model.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart'
    as prefs;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  var emailEdit = false;
  var pwEdit = false;
  String email = "";
  String password = "";

  _login() async {
    if (!emailEdit || !pwEdit) {
      Fluttertoast.showToast(
          msg: "账号密码不能为空",
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    getToken(email, password, onSuccess: (commonBody) {
      prefs.token = Token.fromJson(commonBody.data).token;
      prefs.username = email;
      prefs.password = password;
      Navigator.pushReplacementNamed(context, '/home');
    }, onFailure: (e) {
      Fluttertoast.showToast(
          msg: e.error.toString(),
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Theme(
        ///取消label文本高亮显示
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
                  email = input;
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
                  password = input;
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
                onTap: () {
                  // TODO 测试用
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ),
            Container(
                height: 50.0,
                width: 400.0,
                padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
                child: RaisedButton(
                  onPressed: _login,
                  color: MyColors.deepBlue,
                  splashColor: MyColors.brightBlue,
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
}
