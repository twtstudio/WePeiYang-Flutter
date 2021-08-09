import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

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
    } else if (oldPW != CommonPreferences().password.value) {
      ToastProvider.error("旧密码输入错误");
      return;
    }
    resetPwByLogin(newPW1,
        onSuccess: () => ToastProvider.success("密码修改成功"),
        onFailure: (e) => ToastProvider.error(e.error));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 14.5,
        color: Color.fromRGBO(98, 103, 122, 1),
        fontWeight: FontWeight.bold);
    final hintStyle = FontManager.YaHeiRegular.copyWith(
        fontSize: 13,
        color: Color.fromRGBO(205, 206, 212, 1),
        fontWeight: FontWeight.w400);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(S.current.reset_password,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 16,
                  color: Color.fromRGBO(36, 43, 69, 1),
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          brightness: Brightness.light,
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
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Text(S.current.password1, style: titleStyle)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
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
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
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
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Text(S.current.password2, style: titleStyle)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
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
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
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
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Text(S.current.password3, style: titleStyle)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
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
                      contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none)),
                  obscureText: true,
                  onChanged: (input) => setState(() => newPW2 = input),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 15, 30, 0),
              child: GestureDetector(
                child: Text(S.current.forget_password,
                    style: FontManager.YaHeiRegular.copyWith(
                        fontSize: 12, decoration: TextDecoration.underline)),
                onTap: () => Navigator.pushNamed(context, AuthRouter.findHome),
              ),
            ),
            Container(
                height: 50,
                width: 400,
                margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: RaisedButton(
                  onPressed: _reset,
                  color: Color.fromRGBO(53, 59, 84, 1),
                  splashColor: Color.fromRGBO(103, 110, 150, 1),
                  child: Text(S.current.reset_ok,
                      style: FontManager.YaHeiRegular.copyWith(
                          color: Colors.white, fontSize: 13)),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                )),
          ],
        ),
      ),
    );
  }
}
