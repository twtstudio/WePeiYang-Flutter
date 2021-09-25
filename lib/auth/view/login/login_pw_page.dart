import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/auth/view/login/register_dialog.dart';

class LoginPwWidget extends StatefulWidget {
  @override
  _LoginPwWidgetState createState() => _LoginPwWidgetState();
}

class _LoginPwWidgetState extends State<LoginPwWidget> {
  String account = "";
  String password = "";
  bool check = false;

  _login() async {
    _passwordFocus.unfocus();
    if (account == "" || password == "")
      ToastProvider.error("账号密码不能为空");
    else if (!check)
      ToastProvider.error("请阅读用户须知");
    else
      AuthService.login(account, password,
          onResult: (result) {
            if (result['telephone'] == null || result['email'] == null) {
              Navigator.pushNamed(context, AuthRouter.addInfo);
            } else {
              ToastProvider.success("登录成功");
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeRouter.home, (route) => false);
            }
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  FocusNode _accountFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
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
            child: Text("${S.current.WBY}4.0",
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                textInputAction: TextInputAction.next,
                focusNode: _accountFocus,
                decoration: InputDecoration(
                    hintText: S.current.account,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => account = input),
                onEditingComplete: () {
                  _accountFocus.unfocus();
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                keyboardType: TextInputType.visiblePassword,
                focusNode: _passwordFocus,
                decoration: InputDecoration(
                    hintText: S.current.password,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                obscureText: true,
                onChanged: (input) => setState(() => password = input),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(40, 15, 40, 25),
            child: GestureDetector(
              child: Text(S.current.forget_password,
                  style: FontManager.YaHeiRegular.copyWith(
                      fontSize: 11,
                      color: Colors.blue,
                      decoration: TextDecoration.underline)),
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.findHome),
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
                child: Text(S.current.login,
                    style: FontManager.YaHeiRegular.copyWith(
                        color: Colors.white, fontSize: 13)),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              )),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(25, 20, 40, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Checkbox(
                    value: this.check,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    activeColor: Color.fromRGBO(98, 103, 123, 1),
                    onChanged: (bool val) =>
                        this.setState(() => this.check = !this.check),
                  ),
                ),
                Text(S.current.register_hint1,
                    style: FontManager.YaHeiRegular.copyWith(
                        color: Color.fromRGBO(79, 88, 107, 1), fontSize: 11)),
                GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) => RegisterDialog()),
                  child: Text(S.current.register_hint2,
                      style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 11,
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
