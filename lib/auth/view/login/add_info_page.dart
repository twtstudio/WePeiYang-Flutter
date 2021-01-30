import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class AddInfoWidget extends StatefulWidget {
  @override
  _AddInfoWidgetState createState() => _AddInfoWidgetState();
}

class _AddInfoWidgetState extends State<AddInfoWidget> {
  String email = "";
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    getCaptchaOnRegister(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _submit() async {
    setState(() => isPress = false);
    if (email == "") {
      ToastProvider.error("E-mail不能为空");
    } else if (phone == "") {
      ToastProvider.error("手机号码不能为空");
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
    } else {
      addInfo(phone, code, email,
          onSuccess: () {
            ToastProvider.success("登录成功");
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text("请补全信息后登录",
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
                  focusNode: _emailFocus,
                  decoration: InputDecoration(
                      labelText: 'E-mail',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => email = input),
                  onEditingComplete: () {
                    _emailFocus.unfocus();
                    FocusScope.of(context).requestFocus(_phoneFocus);
                  },
                ),
              ),
            ),
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
                  focusNode: _phoneFocus,
                  decoration: InputDecoration(
                      labelText: '手机号码',
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onChanged: (input) => setState(() => phone = input),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
            child: Row(
              children: [
                Theme(
                  data: ThemeData(hintColor: Color.fromRGBO(98, 103, 123, 1)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100,
                      maxWidth: 180,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: '短信验证码',
                          filled: true,
                          fillColor: Color.fromRGBO(235, 238, 243, 1),
                          isCollapsed: true,
                          contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onChanged: (input) => setState(() => code = input),
                    ),
                  ),
                ),
                Expanded(child: Text("")),
                Container(
                    height: 55,
                    width: 140,
                    margin: const EdgeInsets.only(left: 20),
                    child: RaisedButton(
                      onPressed: _fetchCaptcha,
                      color: isPress
                          ? Color.fromRGBO(235, 238, 243, 1)
                          : Color.fromRGBO(53, 59, 84, 1.0),
                      splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                      child: Text('获取验证码',
                          style: TextStyle(
                              color: isPress
                                  ? Color.fromRGBO(201, 204, 209, 1)
                                  : Colors.white,
                              fontSize: 16)),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    )),
              ],
            ),
          ),
          Container(
              height: 50.0,
              width: 400.0,
              margin: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
              child: RaisedButton(
                onPressed: _submit,
                color: Color.fromRGBO(53, 59, 84, 1.0),
                splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                child: Text('提交并登录',
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