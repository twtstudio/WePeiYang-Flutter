import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/auth/view/info/unbind_dialogs.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class EmailBindPage extends StatefulWidget {
  @override
  _EmailBindPageState createState() => _EmailBindPageState();
}

class _EmailBindPageState extends State<EmailBindPage> {
  var pref = CommonPreferences();
  String email = "";

  _bind() async {
    if (email == "") {
      ToastProvider.error("邮箱不能为空");
      return;
    }
    changeEmail(email,
        onSuccess: () {
          ToastProvider.success("邮箱绑定成功");
          setState(() {});
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  Widget _detail(BuildContext context) {
    var hintStyle =
        TextStyle(color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);
    if (pref.email.value != "")
      return Column(children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 60, 0, 95),
          child: Text('已绑定邮箱：\n${pref.email.value}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color.fromRGBO(79, 88, 107, 1))),
        ),
        Container(
          height: 50,
          width: 120,
          child: RaisedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => EmailUnbindDialog())
                .then((_) => this.setState(() {})),
            color: Color.fromRGBO(79, 88, 107, 1),
            splashColor: MyColors.brightBlue,
            child: Text('解除绑定',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
      ]);
    else {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 55,
            ),
            child: TextField(
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  hintText: '邮箱',
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Color.fromRGBO(235, 238, 243, 1),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 20, 0, 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              onChanged: (input) => setState(() => email = input),
            ),
          ),
        ),
        Container(
            height: 50.0,
            width: 400.0,
            margin: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
            child: RaisedButton(
              onPressed: _bind,
              color: Color.fromRGBO(53, 59, 84, 1.0),
              splashColor: Color.fromRGBO(103, 110, 150, 1.0),
              child: Text('绑定',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            )),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.fromLTRB(35, 20, 20, 30),
                child: Text("邮箱绑定",
                    style: TextStyle(
                        color: Color.fromRGBO(48, 60, 102, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 28)),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 32, 0, 30),
                    child: Text((pref.email.value != "") ? "已绑定" : "未绑定",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          _detail(context)
        ],
      ),
    );
  }
}
