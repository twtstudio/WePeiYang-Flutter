import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ResetPwWidget extends StatefulWidget {
  @override
  _ResetPwWidgetState createState() => _ResetPwWidgetState();
}

class _ResetPwWidgetState extends State<ResetPwWidget> {
  String password1 = "";
  String password2 = "";

  _reset() async {
    if (password1 == "") {
      ToastProvider.error("密码不能为空");
      return;
    } else if (password2 == "") {
      ToastProvider.error("请再次输入密码");
      return;
    } else if (password1 != password2) {
      ToastProvider.error("两次输入密码不一致");
      return;
    }
    String phone = ModalRoute.of(context)?.settings.arguments as String;
    AuthService.resetPwByPhone(phone, password1,
        onSuccess: () => Navigator.pushNamed(context, AuthRouter.resetDone),
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  final FocusNode _pwInput1 = FocusNode();
  final FocusNode _pwInput2 = FocusNode();

  static final TextStyle _hintStyle = TextUtil.base.regular
      .sp(13)
      .whiteHint201;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: ColorUtil.white250,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: ColorUtil.blue98, size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Center(
            child: Text(S.current.find_password_title,
                style: TextUtil.base.bold
                    .sp(16)
                    .blue98),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                focusNode: _pwInput1,
                decoration: InputDecoration(
                    hintText: S.current.input_password1,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: ColorUtil.white235,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                obscureText: true,
                onChanged: (input) => setState(() => password1 = input),
                onEditingComplete: () {
                  _pwInput1.unfocus();
                  FocusScope.of(context).requestFocus(_pwInput2);
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                keyboardType: TextInputType.visiblePassword,
                focusNode: _pwInput2,
                decoration: InputDecoration(
                    hintText: S.current.input_password2,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: ColorUtil.white235,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                obscureText: true,
                onChanged: (input) => setState(() => password2 = input),
              ),
            ),
          ),
          Spacer(),
          Container(
            height: 50,
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(30),
            child: GestureDetector(
              onTap: _reset,
              child: Image(image: AssetImage('assets/images/arrow_round.png')),
            ),
          ),
        ],
      ),
    );
  }
}
