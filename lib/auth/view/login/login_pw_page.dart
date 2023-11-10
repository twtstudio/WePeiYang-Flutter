import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';

class LoginPwWidget extends StatefulWidget {
  @override
  _LoginPwWidgetState createState() => _LoginPwWidgetState();
}

class _LoginPwWidgetState extends State<LoginPwWidget> {
  final checkNotifier = ValueNotifier<bool>(false); // 是否勾选隐私政策
  bool _usePwLogin = true;
  String md = "";

  _login() async {
    // 隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());
    if (_usePwLogin) {
      if (account == "" || password == "")
        ToastProvider.error('账号密码不能为空');
      else if (!checkNotifier.value)
        ToastProvider.error('请同意用户协议与隐私政策并继续');
      else {
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
      }
    } else {
      if (account == "") {
        ToastProvider.error('手机号码不能为空');
      } else if (code == "") {
        ToastProvider.error('短信验证码不能为空');
      } else if (!checkNotifier.value)
        ToastProvider.error('请同意用户协议与隐私政策并继续');
      else {
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
  }

  @override
  void initState() {
    super.initState();

    ///隐私政策markdown加载
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      rootBundle.loadString('privacy/privacy_content.md').then((str) {
        setState(() {
          md = str;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(gradient: ColorUtil.gradientBlueAllScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: "Welcome\n\n",
                    style: TextUtil.base.normal.NotoSansSC.sp(40).w700.white),
              ])),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      _usePwLogin ? _pwWidget : _codeWidget,
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: checkNotifier,
                            builder: (context, bool value, _) {
                              return Checkbox(
                                value: value,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                activeColor: ColorUtil.blue2CColor,
                                onChanged: (_) {
                                  checkNotifier.value = !checkNotifier.value;
                                },
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          Text.rich(TextSpan(
                              text: "我已阅读并同意",
                              style: TextUtil.base.normal.NotoSansSC.w400
                                  .sp(10)
                                  .black2A)),
                          WButton(
                            onPressed: () => showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) =>
                                    UserAgreementDialog(check: checkNotifier)),
                            child: Text.rich(TextSpan(
                                text: "《用户协议》",
                                style: TextUtil.base.normal.NotoSansSC.w400
                                    .sp(10)
                                    .underLine)),
                          ),
                          Text.rich(TextSpan(
                              text: "与",
                              style: TextUtil.base.normal.NotoSansSC.w400
                                  .sp(10)
                                  .black2A)),
                          WButton(
                            onPressed: () => showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) =>
                                    PrivacyDialog(md, check: checkNotifier)),
                            child: Text.rich(TextSpan(
                                text: "《隐私政策》",
                                style: TextUtil.base.normal.NotoSansSC.w400
                                    .sp(10)
                                    .underLine)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30)
                    ],
                  )),
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
            text: "账号",
            style: TextUtil.base.normal.NotoSansSC.w400.sp(16).white)),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: TextField(
            style: TextUtil.base.normal.w400.sp(14).NotoSansSC.white,
            cursorColor: ColorUtil.whiteFFColor,
            textInputAction: TextInputAction.next,
            focusNode: _accountFocus,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorUtil.whiteFFColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorUtil.whiteFFColor,
                  width: 1.0,
                ),
              ),
              hintText: "学号/手机号/邮箱",
              hintStyle: TextUtil.base.normal.sp(14).w400.white,
              isCollapsed: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
            ),
            onChanged: (input) => setState(() => account = input),
            onEditingComplete: () {
              _accountFocus.unfocus();
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
        ),
        SizedBox(height: 20),
        Text.rich(TextSpan(
            text: "密码",
            style: TextUtil.base.normal.NotoSansSC.w400.sp(16).white)),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: ValueListenableBuilder(
            valueListenable: visNotifier,
            builder: (context, bool value, _) {
              return Theme(
                data:
                    Theme.of(context).copyWith(primaryColor: ColorUtil.blue53),
                child: TextField(
                  style: TextUtil.base.normal.w400.sp(14).NotoSansSC.white,
                  cursorColor: ColorUtil.whiteFFColor,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocus,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorUtil.whiteFFColor,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorUtil.whiteFFColor,
                          width: 1.0,
                        ),
                      ),
                      hintText: "请输入密码",
                      hintStyle: TextUtil.base.normal.sp(14).w400.white,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
                      suffixIcon: WButton(
                        onPressed: () {
                          visNotifier.value = !visNotifier.value;
                        },
                        child: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                          color: ColorUtil.whiteFFColor,
                        ),
                      )),
                  obscureText: value,
                  onChanged: (input) => setState(() => password = input),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 50),
        WButton(
          onPressed: _login,
          child: Container(
            width: width - 60,
            height: 48,
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text.rich(TextSpan(
                  text: "登录",
                  style: TextUtil.base.normal.NotoSansSC.w400.sp(16).blue2C)),
            ),
          ),
        ),
        SizedBox(height: 23), //这里的数值调整是为了两个界面的短信登陆等位置在同一个水平线上
        Row(
          children: [
            Spacer(),
            SizedBox(width: 16),
            WButton(
              child: Text.rich(TextSpan(
                  text: "短信登录",
                  style: TextUtil.base.normal.NotoSansSC.w400.sp(14).white)),
              onPressed: () {
                if (_usePwLogin) {
                  _accountFocus.unfocus();
                  _passwordFocus.unfocus();
                  password = '';
                  _usePwLogin = false;
                } else {
                  code = '';
                  _usePwLogin = true;
                }
                setState(() {});
              },
            ),
            SizedBox(width: 16),
            WButton(
              child: Text.rich(TextSpan(
                  text: "忘记密码?",
                  style: TextUtil.base.normal.NotoSansSC.w400.sp(14).white)),
              onPressed: () => Navigator.pushNamed(context, AuthRouter.findHome),
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
    final size = MediaQuery.of(context).size;
    double width = size.width;
    var builder = (index) {
      return Container(
        alignment: AlignmentDirectional.center,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorUtil.whiteOpacity04,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          code.length > index ? code.substring(index, index + 1) : '',
          style: TextUtil.base.normal.NotoSansSC.blue2C.sp(16),
        ),
      );
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
            text: "手机号",
            style: TextUtil.base.normal.NotoSansSC.w400.sp(16).white)),
        SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 55),
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextUtil.base.normal.w400.sp(14).NotoSansSC.white,
            cursorColor: ColorUtil.whiteFFColor,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorUtil.whiteFFColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorUtil.whiteFFColor,
                  width: 1.0,
                ),
              ),
              hintText: "请输入手机号",
              hintStyle: TextUtil.base.normal.sp(14).w400.white,
              isCollapsed: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
            ),
            onChanged: (input) => setState(() => account = input),
          ),
        ),
        SizedBox(height: 20),
        Text.rich(TextSpan(
          text: "验证码",
          style: TextUtil.base.normal.NotoSansSC.w400.sp(16).white,
        )),
        SizedBox(height: 20),
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, builder),
            ),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextUtil.base.normal.w400.sp(16).NotoSansSC.transParent,
              showCursor: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
              ),
              onChanged: (input) => setState(() => code = input),
            ),
          ],
        ),
        SizedBox(height: 11), // 这里的数值调整是为了两个界面的登录按钮对齐
        WButton(
          onPressed: _login,
          child: Container(
            width: width - 60,
            height: 48,
            decoration: BoxDecoration(
              color: ColorUtil.whiteFFColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text.rich(TextSpan(
                  text: "登录",
                  style: TextUtil.base.normal.NotoSansSC.w400.sp(16).blue2C)),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            ValueListenableBuilder(
              valueListenable: countDownNotifier,
              builder: (context, value, _) {
                if (value == 0) {
                  return WButton(
                    onPressed: (_fetchCaptcha),
                    child: Text(
                      '获取验证码',
                      style: TextUtil.base.normal.NotoSansSC.w400.sp(14).white,
                    ),
                  );
                } else {
                  return WButton(
                    onPressed: () {},
                    child: Text(
                      '重新获取验证码($value)',
                      style: TextUtil.base.normal.NotoSansSC.w400.sp(14).white,
                    ),
                  );
                }
              },
            ),
            Spacer(),
            WButton(
              child: Text.rich(TextSpan(
                  text: "密码登录",
                  style: TextUtil.base.normal.NotoSansSC.w400.sp(14).white)),
              onPressed: () {
                if (_usePwLogin) {
                  _accountFocus.unfocus();
                  _passwordFocus.unfocus();
                  password = '';
                  _usePwLogin = false;
                } else {
                  code = '';
                  _usePwLogin = true;
                }
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
