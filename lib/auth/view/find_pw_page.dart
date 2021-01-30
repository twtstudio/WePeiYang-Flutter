import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';

import 'find_pw_dialog.dart';

class FindPwWidget extends StatelessWidget {
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
            padding: const EdgeInsets.only(top: 120),
            child: Text("天外天账号密码找回",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 25),
            child: RaisedButton(
              onPressed: () => Navigator.pushNamed(context, '/find_phone'),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('账号已绑定手机号',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.only(top: 30),
            child: RaisedButton(
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => FindPwDialog()),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('账号未绑定手机号',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          )
        ],
      ),
    );
  }
}

class FindPwByPhoneWidget extends StatefulWidget {
  @override
  _FindPwByPhoneWidgetState createState() => _FindPwByPhoneWidgetState();
}

class _FindPwByPhoneWidgetState extends State<FindPwByPhoneWidget> {
  String userNumber = "";
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      Fluttertoast.showToast(
          msg: "手机号码不能为空",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    getCaptchaOnReset(phone, onSuccess: () {
      setState(() => isPress = true);
    }, onFailure: (e) {
      Fluttertoast.showToast(
          msg: e.error.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  _verifyCaptcha() async {
    if (phone == "") {
      Fluttertoast.showToast(
          msg: "手机号码不能为空",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    } else if (code == "") {
      Fluttertoast.showToast(
          msg: "短信验证码不能为空",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    verifyOnReset(phone, code, onSuccess: () {});
  }

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
            child: Text("天外天账号密码找回",
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
                  decoration: InputDecoration(
                      labelText: '手机号',
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
                      onPressed: () async {
                        getCaptchaOnReset(phone, onSuccess: () {
                          setState(() => isPress = true);
                        }, onFailure: (e) {
                          Fluttertoast.showToast(
                              msg: e.error.toString(),
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        });
                      },
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
          Expanded(child: Text("")),
          GestureDetector(
            onTap: () async {
              // TODO 账号密码找回
            },
            child: Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.fromLTRB(300, 0, 0, 30),
                child:
                    Image(image: AssetImage('assets/images/arrow_round.png'))),
          ),
        ],
      ),
    );
  }
}
