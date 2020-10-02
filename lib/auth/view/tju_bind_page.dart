import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:wei_pei_yang_demo/auth/network/bind_dropout_service.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

class TjuBindWidget extends StatefulWidget {
  @override
  _TjuBindWidgetState createState() => _TjuBindWidgetState();
}

class _TjuBindWidgetState extends State<TjuBindWidget> {
  var nameEdit = false;
  var pwEdit = false;
  var tjuuname = "";
  var tjupasswd = "";

  _tjuBind() async {
    if (!nameEdit || !pwEdit) return;
    var prefs = CommonPreferences.create();
    bindTju(tjuuname, tjupasswd,
        onSuccess: () =>
            getToken(prefs.username, prefs.password, onSuccess: () {
              Fluttertoast.showToast(
                  msg: "办公网绑定成功",
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              Navigator.pop(context);
            }),
        onFailure: (e) {
          Fluttertoast.showToast(
              msg: e.error.toString(),
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        });
  }

  //TODO 输入框action icon
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Image.asset('assets/images/ic_tju_icon.png',
                fit: BoxFit.cover, width: 160, height: 160),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Text('办公网绑定',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 15),
            child: TextField(
              decoration: InputDecoration(
                  labelText: '办公网账号',
                  contentPadding: EdgeInsets.only(top: 5.0)),
              onChanged: (input) => setState(() {
                nameEdit = input.isNotEmpty;
                tjuuname = input;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                  labelText: '办公网密码',
                  contentPadding: EdgeInsets.only(top: 5.0)),
              onChanged: (input) => setState(() {
                pwEdit = input.isNotEmpty;
                tjupasswd = input;
              }),
            ),
          ),
          Container(
            height: 50,
            width: 250,
            margin: const EdgeInsets.only(top: 50),
            child: RaisedButton(
              onPressed: _tjuBind,
              color: MyColors.deepBlue,
              child: Text('绑定', style: TextStyle(color: Colors.white)),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    );
  }
}
