import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/info/unbind_dialogs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

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
        SizedBox(height: 60),
        Text("${S.current.bind_email}: ",
            textAlign: TextAlign.center,
            style: FontManager.YaHeiRegular.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color.fromRGBO(79, 88, 107, 1))),
        SizedBox(height: 5),
        Text(pref.email.value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color.fromRGBO(79, 88, 107, 1))),
        SizedBox(height: 95),
        SizedBox(
          height: 50,
          width: 120,
          child: ElevatedButton(
            onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => EmailUnbindDialog())
                .then((_) => this.setState(() {})),
            child: Text(S.current.unbind,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Colors.white, fontSize: 13)),
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(3),
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed))
                  return MyColors.brightBlue;
                return Color.fromRGBO(79, 88, 107, 1);
              }),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromRGBO(79, 88, 107, 1)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
            ),
          ),
        ),
      ]);
    else {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
                  contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
              onChanged: (input) => setState(() => email = input),
            ),
          ),
        ),
        SizedBox(height: 30),
        Container(
            height: 50,
            width: 400,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: _bind,
              child: Text(S.current.bind,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Colors.white, fontSize: 13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return Color.fromRGBO(103, 110, 150, 1);
                  return Color.fromRGBO(53, 59, 84, 1);
                }),
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  return Color.fromRGBO(53, 59, 84, 1);
                }),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
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
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
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
                    margin: const EdgeInsets.fromLTRB(0, 32, 0, 30),
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
