import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';

class LoginHomeWidget extends StatelessWidget {
  // TODO 简单记一下登录部分可以优化的地方：
  // TODO 外观、textField输入类型、点击按钮取消focus、键盘类型与next按钮
  // TODO "获取验证码"按钮的逻辑、Navigator push还是replace、toast样式

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
            child: Text("Hello,\n微北洋4.0",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 124, 1),
                    fontSize: 50,
                    fontWeight: FontWeight.w300)),
          ),
          Container(height: 90),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 100,
                child: RaisedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login_pw'),
                  color: MyColors.deepBlue,
                  splashColor: MyColors.brightBlue,
                  child: Text('登录',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
              Container(
                height: 50,
                width: 100,
                margin: const EdgeInsets.only(left: 50),
                child: RaisedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login_phone'),
                  color: MyColors.deepBlue,
                  splashColor: MyColors.brightBlue,
                  child: Text('注册',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text("首次登陆微北洋4.0请使用天外天账号密码登录，\n在登陆后绑定手机号码即可手机验证登录。",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: Color.fromRGBO(98, 103, 124, 1))),
          )
        ],
      ),
    );
  }
}
