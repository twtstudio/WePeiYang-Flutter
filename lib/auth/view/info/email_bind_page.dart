import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

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
    AuthService.changeEmail(email,
        onSuccess: () {
          ToastProvider.success("邮箱绑定成功");
          setState(() {});
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  Widget _detail(BuildContext context) {
    var hintStyle = FontManager.YaHeiRegular.copyWith(
        color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);
    if (pref.email.value != "")
      return Column(children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
          child: Text("${S.current.bind_email}: ",
              textAlign: TextAlign.center,
              style: FontManager.YaHeiRegular.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color.fromRGBO(79, 88, 107, 1))),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 95),
          child: Text(pref.email.value,
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
            child: Text(S.current.unbind,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Colors.white, fontSize: 13)),
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
              decoration: InputDecoration(
                  hintText: S.current.email2,
                  hintStyle: hintStyle,
                  filled: true,
                  fillColor: Color.fromRGBO(235, 238, 243, 1),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
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
              child: Text(S.current.bind,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
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
            padding: const EdgeInsets.only(left: 15),
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
                child: Text(S.current.email_bind,
                    style: FontManager.YaQiHei.copyWith(
                        color: Color.fromRGBO(48, 60, 102, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 28)),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 32, 0, 30),
                    child: Text(
                        (pref.email.value != "")
                            ? S.current.is_bind
                            : S.current.not_bind,
                        style: FontManager.YaHeiRegular.copyWith(
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
