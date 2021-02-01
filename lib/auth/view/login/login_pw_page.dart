import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class LoginPwWidget extends StatefulWidget {
  @override
  _LoginPwWidgetState createState() => _LoginPwWidgetState();
}

class _LoginPwWidgetState extends State<LoginPwWidget> {
  String account = "";
  String password = "";

  _login() async {
    if (account == "" || password == "") {
      ToastProvider.error("账号密码不能为空");
      return;
    }
    login(account, password,
        onSuccess: (result) {
          if (result['telephone'] == null || result['email'] == null) {
            Navigator.pushNamed(context, '/add_info');
          } else {
            ToastProvider.success("登录成功");
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          }
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  FocusNode _accountFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text("微北洋4.0",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: _accountFocus,
                  decoration: InputDecoration(
                      labelText: '学号/手机号/邮箱号/用户名',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => account = input),
                  onEditingComplete: () {
                    _accountFocus.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
            child: Theme(
              data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                ),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocus,
                  decoration: InputDecoration(
                      labelText: '密码',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  obscureText: true,
                  onChanged: (input) => setState(() => password = input),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(40, 25, 40, 80),
            child: GestureDetector(
              child: Text('忘记密码',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      decoration: TextDecoration.underline)),
              onTap: () => Navigator.pushNamed(context, '/find_home'),
            ),
          ),
          Container(
              height: 50.0,
              width: 400.0,
              padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
              child: RaisedButton(
                onPressed: _login,
                color: Color.fromRGBO(53, 59, 84, 1.0),
                splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                child: Text('登录',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              )),
        ],
      ),
    );
  }
}
