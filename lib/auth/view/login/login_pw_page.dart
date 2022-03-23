import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

class LoginPwWidget extends StatefulWidget {
  @override
  _LoginPwWidgetState createState() => _LoginPwWidgetState();
}

class _LoginPwWidgetState extends State<LoginPwWidget> {
  final checkNotifier = ValueNotifier<bool>(false); // 是否勾选隐私政策

  _login() async {
    if (CommonPreferences().usePwLogin.value) {
      _passwordFocus.unfocus();
      if (account == "" || password == "")
        ToastProvider.error("账号密码不能为空");
      else if (!checkNotifier.value)
        ToastProvider.error("请同意用户协议与隐私政策并继续");
      else
        AuthService.pwLogin(account, password,
            onResult: (result) {
              if (result['telephone'] == null || result['email'] == null) {
                Navigator.pushNamed(context, AuthRouter.addInfo);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeRouter.home, (route) => false);
              }
            },
            onFailure: (e) => ToastProvider.error(e.error.toString()));
    } else {
      if (account == "") {
        ToastProvider.error("手机号码不能为空");
      } else if (code == "") {
        ToastProvider.error("短信验证码不能为空");
      } else if (!checkNotifier.value)
        ToastProvider.error("请同意用户协议与隐私政策并继续");
      else
        AuthService.codeLogin(account, code,
            onResult: (result) {
              if (result['telephone'] == null || result['email'] == null) {
                Navigator.pushNamed(context, AuthRouter.addInfo);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeRouter.home, (route) => false);
              }
            },
            onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

  static final _normalStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(79, 88, 107, 1), fontSize: 11);

  static final _highlightStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 11, color: Colors.blue, decoration: TextDecoration.underline);

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
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("${S.current.WBY}4.0",
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Color.fromRGBO(98, 103, 123, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            SizedBox(height: 30),
            CommonPreferences().usePwLogin.value ? _pwWidget : _codeWidget,
            SizedBox(height: 25),
            SizedBox(
                height: 50,
                width: 400,
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text(S.current.login,
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
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(53, 59, 84, 1)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                )),
            SizedBox(height: 20),
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: checkNotifier,
                  builder: (context, value, _) {
                    return Checkbox(
                      value: value,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      activeColor: Color.fromRGBO(98, 103, 123, 1),
                      onChanged: (_) {
                        checkNotifier.value = !checkNotifier.value;
                      },
                    );
                  },
                ),
                Text(S.current.register_hint1, style: _normalStyle),
                GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) =>
                          UserAgreementDialog(check: checkNotifier)),
                  child: Text('《用户协议》', style: _highlightStyle),
                ),
                Text('与', style: _normalStyle),
                GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) =>
                          PrivacyDialog(check: checkNotifier)),
                  child: Text('《隐私政策》', style: _highlightStyle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final visNotifier = ValueNotifier<bool>(true); // 是否隐藏密码
  final countDownNotifier = ValueNotifier<int>(0); // 获取验证码冷却
  String account = "";
  String password = "";

  String code = "";

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  Widget get _pwWidget {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: TextField(
            textInputAction: TextInputAction.next,
            focusNode: _accountFocus,
            decoration: InputDecoration(
                hintText: S.current.account,
                hintStyle: _hintStyle,
                filled: true,
                fillColor: Color.fromRGBO(235, 238, 243, 1),
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none)),
            onChanged: (input) => setState(() => account = input),
            onEditingComplete: () {
              _accountFocus.unfocus();
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
        ),
        SizedBox(height: 20),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: ValueListenableBuilder(
            valueListenable: visNotifier,
            builder: (context, value, _) {
              return Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: Color.fromRGBO(53, 59, 84, 1)),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocus,
                  decoration: InputDecoration(
                    hintText: S.current.password,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    suffixIcon: GestureDetector(
                      child:
                          Icon(value ? Icons.visibility_off : Icons.visibility),
                      onTap: () {
                        visNotifier.value = !visNotifier.value;
                      },
                    ),
                  ),
                  obscureText: value,
                  onChanged: (input) => setState(() => password = input),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            SizedBox(width: 10),
            GestureDetector(
              child: Text(S.current.forget_password, style: _highlightStyle),
              onTap: () => Navigator.pushNamed(context, AuthRouter.findHome),
            ),
            Spacer(),
            GestureDetector(
              child: Text('短信登陆→', style: _normalStyle),
              onTap: () {
                if (CommonPreferences().usePwLogin.value) {
                  _accountFocus.unfocus();
                  _passwordFocus.unfocus();
                  password = '';
                  CommonPreferences().usePwLogin.value = false;
                } else {
                  code = '';
                  CommonPreferences().usePwLogin.value = true;
                }
                setState(() {});
              },
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  _fetchCaptcha() async {
    if (account == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnReset(account,
        onSuccess: () {
          setState(() {
            countDownNotifier.value = 60;
            Stream.periodic(Duration(seconds: 1)).take(60).listen((event) {
              countDownNotifier.value = countDownNotifier.value - 1;
            });
          });
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  Widget get _codeWidget {
    double width = WePeiYangApp.screenWidth - 80;
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: TextField(
            decoration: InputDecoration(
                hintText: S.current.phone,
                hintStyle: _hintStyle,
                filled: true,
                fillColor: Color.fromRGBO(235, 238, 243, 1),
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none)),
            onChanged: (input) => setState(() => account = input),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
                maxWidth: width / 2 + 20,
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: S.current.text_captcha,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
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
              child: ValueListenableBuilder(
                valueListenable: countDownNotifier,
                builder: (context, value, _) {
                  if (value == 0) {
                    return ElevatedButton(
                      onPressed: _fetchCaptcha,
                      child: Text(S.current.fetch_captcha,
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
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(53, 59, 84, 1)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                      ),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () {},
                      child: Text('$value秒后重试',
                          style: FontManager.YaHeiRegular.copyWith(
                              color: Color.fromRGBO(98, 103, 123, 1),
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                        overlayColor:
                            MaterialStateProperty.all(Colors.grey[300]),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[300]),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Spacer(),
            GestureDetector(
              child: Text('密码登陆→', style: _normalStyle),
              onTap: () {
                if (CommonPreferences().usePwLogin.value) {
                  _accountFocus.unfocus();
                  _passwordFocus.unfocus();
                  password = '';
                  CommonPreferences().usePwLogin.value = false;
                } else {
                  code = '';
                  CommonPreferences().usePwLogin.value = true;
                }
                setState(() {});
              },
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
