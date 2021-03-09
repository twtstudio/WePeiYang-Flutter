import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/auth_router.dart';

class ResetDoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 180),
            child: Text("密码修改完成",
                style: TextStyle(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Container(
            height: 55,
            width: 140,
            margin: const EdgeInsets.only(top: 20),
            child: RaisedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AuthRouter.login, (route) => false),
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('前往登录',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
        ],
      ),
    );
  }
}
