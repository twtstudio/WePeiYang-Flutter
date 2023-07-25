import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String oldPW = "";
  String newPW1 = "";
  String newPW2 = "";

  FocusNode oldPwNode = FocusNode();
  FocusNode newPwNode1 = FocusNode();
  FocusNode newPwNode2 = FocusNode();

  _reset() async {
    oldPwNode.unfocus();
    newPwNode1.unfocus();
    newPwNode2.unfocus();
    if (oldPW == "") {
      ToastProvider.error("请输入原来的密码");
      return;
    } else if (newPW1 == "") {
      ToastProvider.error("请输入新密码");
      return;
    } else if (newPW2 == "") {
      ToastProvider.error("请再次输入新密码");
      return;
    } else if (newPW1 != newPW2) {
      ToastProvider.error("两次输入新密码不一致");
      return;
    } else if (oldPW != CommonPreferences.password.value) {
      ToastProvider.error("旧密码输入错误");
      return;
    }
    AuthService.resetPwByLogin(newPW1,
        onSuccess: () => ToastProvider.success("密码修改成功"),
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextUtil.base.bold
        .sp(14.5)
        .customColor(Color.fromRGBO(98, 103, 122, 1));
    var hintStyle =
        TextUtil.base.w400.sp(13).customColor(Color.fromRGBO(205, 206, 212, 1));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(S.current.reset_password,
              style: TextUtil.base.bold
                  .sp(16)
                  .customColor(Color.fromRGBO(36, 43, 69, 1))),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(S.current.password1, style: titleStyle)),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 55,
                ),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: oldPwNode,
                  decoration: InputDecoration(
                      hintText: S.current.input_password3,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none)),
                  obscureText: true,
                  onChanged: (input) => setState(() => oldPW = input),
                  onEditingComplete: () {
                    oldPwNode.unfocus();
                    FocusScope.of(context).requestFocus(newPwNode1);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(S.current.password2, style: titleStyle)),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 55,
                ),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: newPwNode1,
                  decoration: InputDecoration(
                      hintText: S.current.input_password1,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none)),
                  obscureText: true,
                  onChanged: (input) => setState(() => newPW1 = input),
                  onEditingComplete: () {
                    newPwNode1.unfocus();
                    FocusScope.of(context).requestFocus(newPwNode2);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(S.current.password3, style: titleStyle)),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 55,
                ),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  focusNode: newPwNode2,
                  decoration: InputDecoration(
                      hintText: S.current.input_password4,
                      hintStyle: hintStyle,
                      filled: true,
                      fillColor: Color.fromRGBO(235, 238, 243, 1),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none)),
                  obscureText: true,
                  onChanged: (input) => setState(() => newPW2 = input),
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                child: Text(S.current.forget_password,
                    style: TextUtil.base.regular.underLine.sp(12)),
                onTap: () => Navigator.pushNamed(context, AuthRouter.findHome),
              ),
            ),
            Container(
                height: 50,
                width: 400,
                margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: ElevatedButton(
                  onPressed: _reset,
                  child: Text(S.current.reset_ok,
                      style: TextUtil.base.regular.white.sp(13)),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(5),
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed))
                        return Color.fromRGBO(103, 110, 150, 1);
                      return Color.fromRGBO(53, 59, 84, 1);
                    }),
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(53, 59, 84, 1)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
