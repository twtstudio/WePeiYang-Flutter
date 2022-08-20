import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
    color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

class RegisterPageOne extends StatefulWidget {
  @override
  _RegisterPageOneState createState() => _RegisterPageOneState();
}

class _RegisterPageOneState extends State<RegisterPageOne> {
  String userNum = "";
  String nickname = "";

  _toNextPage() async {
    if (userNum == "")
      ToastProvider.error("学号不能为空");
    else if (nickname == "")
      ToastProvider.error("昵称不能为空");
    else {
      AuthService.checkInfo1(userNum, nickname,
          onSuccess: () {
            _userNumFocus.unfocus();
            _nicknameFocus.unfocus();
            Navigator.pushNamed(context, AuthRouter.register2, arguments: {
              'userNum': userNum,
              'nickname': nickname,
            });
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  final FocusNode _userNumFocus = FocusNode();
  final FocusNode _nicknameFocus = FocusNode();

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
      body: Column(
        children: [
          Center(
            child: Text(S.current.register2,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
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
                focusNode: _userNumFocus,
                decoration: InputDecoration(
                    hintText: S.current.student_id,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => userNum = input),
                onEditingComplete: () {
                  _userNumFocus.unfocus();
                  FocusScope.of(context).requestFocus(_nicknameFocus);
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
                focusNode: _nicknameFocus,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]|[0-9]'))
                ],
                decoration: InputDecoration(
                    hintText: '昵称',
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => nickname = input),
              ),
            ),
          ),
          Spacer(),
          Container(
            height: 50,
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(30),
            child: GestureDetector(
              onTap: _toNextPage,
              child: Image(image: AssetImage('assets/images/arrow_round.png')),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterPageTwo extends StatefulWidget {
  final String userNum;
  final String nickname;

  RegisterPageTwo(this.userNum, this.nickname);

  @override
  _RegisterPageTwoState createState() => _RegisterPageTwoState();
}

class _RegisterPageTwoState extends State<RegisterPageTwo> {
  String idNum = ""; // 身份证号
  String email = "";
  String phone = "";
  String code = ""; // 短信验证码
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

  _toNextPage() async {
    if (idNum == "")
      ToastProvider.error("身份证号不能为空");
    else if (email == "")
      ToastProvider.error("E-mail不能为空");
    else if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      AuthService.checkInfo2(idNum, email, phone,
          onSuccess: () {
            _idNumFocus.unfocus();
            _emailFocus.unfocus();
            _phoneFocus.unfocus();
            _codeFocus.unfocus();
            Navigator.pushNamed(context, AuthRouter.register3, arguments: {
              'userNum': widget.userNum,
              'nickname': widget.nickname,
              'idNum': idNum,
              'email': email,
              'phone': phone,
              'code': code
            });
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  final FocusNode _idNumFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _codeFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    /// 两边的padding各30，中间间隔20
    double width = WePeiYangApp.screenWidth - 80;
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
      body: Column(
        children: [
          Center(
            child: Text(S.current.register2,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
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
                focusNode: _idNumFocus,
                decoration: InputDecoration(
                    hintText: S.current.person_id,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => idNum = input),
                onEditingComplete: () {
                  _idNumFocus.unfocus();
                  FocusScope.of(context).requestFocus(_emailFocus);
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
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                    hintText: S.current.email,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
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
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
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
                    maxHeight: 55,
                    maxWidth: width / 2 + 20,
                  ),
                  child: TextField(
                    focusNode: _codeFocus,
                    decoration: InputDecoration(
                        hintText: S.current.text_captcha,
                        hintStyle: _hintStyle,
                        filled: true,
                        fillColor: Color.fromRGBO(235, 238, 243, 1),
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
                                style: FontManager.YaHeiRegular.copyWith(
                                    color: Color.fromRGBO(98, 103, 123, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(5),
                              overlayColor: MaterialStateProperty.all(
                                  Colors.grey[300]),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.grey[300]),
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
                          style: FontManager.YaHeiRegular.copyWith(
                              color: Colors.white, fontSize: 13)),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                        overlayColor:
                        MaterialStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(MaterialState.pressed))
                                return Color.fromRGBO(103, 110, 150, 1);
                              return Color.fromRGBO(53, 59, 84, 1);
                            }),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(53, 59, 84, 1)),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                      ),
                    )),
              ],
            ),
          ),
          Spacer(),
          Row(
            children: [
              Container(
                height: 50,
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image(
                      image: AssetImage('assets/images/arrow_round_back.png')),
                ),
              ),
              Spacer(),
              Container(
                height: 50,
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: _toNextPage,
                  child:
                  Image(image: AssetImage('assets/images/arrow_round.png')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterPageThree extends StatefulWidget {
  final String userNum;
  final String nickname;
  final String idNum;
  final String email;
  final String phone;
  final String code;

  RegisterPageThree(this.userNum, this.nickname, this.idNum, this.email,
      this.phone, this.code);

  @override
  _RegisterPageThreeState createState() => _RegisterPageThreeState();
}

class _RegisterPageThreeState extends State<RegisterPageThree> {
  String password1 = "";
  String password2 = "";
  var checkNotifier = ValueNotifier<bool>(false);

  _submit() async {
    if (password1 == "")
      ToastProvider.error("请输入密码");
    else if (password2 == "")
      ToastProvider.error("请再次输入密码");
    else if (password1 != password2)
      ToastProvider.error("两次输入密码不一致");
    else if (!checkNotifier.value)
      ToastProvider.error("请同意用户协议与隐私政策并继续");
    else {
      AuthService.register(
          widget.userNum,
          widget.nickname,
          widget.phone,
          widget.code,
          password1,
          widget.email,
          widget.idNum,
          onSuccess: () {
            FeedbackService.getTokenByPw(
                widget.userNum, password1, onSuccess: () {
              FeedbackService.changeNickname(
                  nickName: widget.nickname,
                  onSuccess: () {},
                  onFailure: (e) => ToastProvider.error(e.error.toString()));
            },
                onFailure: (e) => ToastProvider.error(e.error.toString()));
            ToastProvider.success("注册成功");
            Navigator.pushNamedAndRemoveUntil(
                context, AuthRouter.login, (route) => false);
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  final FocusNode _pw1Focus = FocusNode();
  final FocusNode _pw2Focus = FocusNode();

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
      body: Column(
        children: [
          Center(
            child: Text(S.current.register2,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
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
                focusNode: _pw1Focus,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: S.current.input_password1,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => password1 = input),
                onEditingComplete: () {
                  _pw1Focus.unfocus();
                  FocusScope.of(context).requestFocus(_pw2Focus);
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
                focusNode: _pw2Focus,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: S.current.input_password2,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => password2 = input),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(25, 20, 40, 0),
            child: Row(
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
                  onTap: () =>
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) =>
                              UserAgreementDialog(check: checkNotifier)),
                  child: Text('《用户协议》', style: _highlightStyle),
                ),
                Text('与', style: _normalStyle),
                GestureDetector(
                  onTap: () =>
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) =>
                              PrivacyDialog(check: checkNotifier)),
                  child: Text('《隐私政策》', style: _highlightStyle),
                ),
              ],
            ),
          ),
          Spacer(),
          Row(
            children: [
              Container(
                height: 50,
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image(
                      image: AssetImage('assets/images/arrow_round_back.png')),
                ),
              ),
              Spacer(),
              Container(
                height: 50,
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: _submit,
                  child:
                  Image(image: AssetImage('assets/images/arrow_round.png')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
