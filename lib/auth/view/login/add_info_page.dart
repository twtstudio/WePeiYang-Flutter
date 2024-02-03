import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/widgets/w_button.dart';

class AddInfoWidget extends StatefulWidget {
  @override
  _AddInfoWidgetState createState() => _AddInfoWidgetState();
}

class _AddInfoWidgetState extends State<AddInfoWidget> {
  String email = "";
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnRegister(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _submit() async {
    if (email == "")
      ToastProvider.error("E-mail不能为空");
    else if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      AuthService.addInfo(phone, code, email,
          onSuccess: () {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();

  static final TextStyle _hintStyle = TextUtil.base.regular.sp(13).oldHintDarker;

  @override
  Widget build(BuildContext context) {
    double width = WePeiYangApp.screenWidth - 80;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: ColorUtil.reverseTextColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child:
                    Icon(Icons.arrow_back, color: ColorUtil.oldThirdActionColor, size: 35),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Center(
            child: Text(S.current.add_info_hint,
                style: TextUtil.base.bold.sp(16).oldThirdAction),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                    hintText: S.current.email,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: ColorUtil.white235,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => email = input),
                onEditingComplete: () {
                  _emailFocus.unfocus();
                  FocusScope.of(context).requestFocus(_phoneFocus);
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
                focusNode: _phoneFocus,
                decoration: InputDecoration(
                    hintText: S.current.phone,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: ColorUtil.white235,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => phone = input),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 50,
                    maxWidth: width / 2 + 20,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: S.current.text_captcha,
                        hintStyle: _hintStyle,
                        filled: true,
                        fillColor: ColorUtil.white235,
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 18, 0, 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                    onChanged: (input) => setState(() => code = input),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                    height: 55,
                    width: width / 2 - 20,
                    child: isPress
                        ? StreamBuilder<int>(
                            stream: Stream.periodic(
                                    Duration(seconds: 1), (time) => time + 1)
                                .take(60),
                            builder: (context, snap) {
                              var time = 60 - (snap.data ?? 0);
                              if (time == 0)
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => setState(() => isPress = false));
                              return ElevatedButton(
                                onPressed: () {},
                                child: Text('$time秒后重试',
                                    style: TextUtil.base.bold.sp(13).oldThirdAction),
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(5),
                                  overlayColor: MaterialStateProperty.all(
                                      ColorUtil.greyShade300),
                                  backgroundColor: MaterialStateProperty.all(
                                      ColorUtil.greyShade300),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                ),
                              );
                            })
                        : ElevatedButton(
                            onPressed: _fetchCaptcha,
                            child: Text(S.current.fetch_captcha,
                                style: TextUtil.base.regular.reverse.sp(13)),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(5),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                if (states.contains(MaterialState.pressed))
                                  return ColorUtil.oldActionRippleColor;
                                return ColorUtil.oldActionColor;
                              }),
                              backgroundColor:
                                  MaterialStateProperty.all(ColorUtil.oldActionColor),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                          )),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
              height: 50,
              width: 400,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(S.current.login2,
                    style: TextUtil.base.regular.reverse.sp(13)),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(5),
                  overlayColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.pressed))
                      return ColorUtil.oldActionRippleColor;
                    return ColorUtil.oldActionColor;
                  }),
                  backgroundColor: MaterialStateProperty.all(ColorUtil.oldActionColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
                ),
              )),
        ],
      ),
    );
  }
}
