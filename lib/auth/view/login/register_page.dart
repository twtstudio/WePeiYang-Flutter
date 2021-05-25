import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/auth/view/login/register_dialog.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

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
      ToastProvider.error("用户名不能为空");
    else {
      checkInfo1(userNum, nickname,
          onSuccess: () {
            _userNumFocus.unfocus();
            _nicknameFocus.unfocus();
            Navigator.pushNamed(context, AuthRouter.register2, arguments: {
              'userNum': userNum,
              'nickname': nickname,
            });
          },
          onFailure: (e) => ToastProvider.error(e.error));
    }
  }

  FocusNode _userNumFocus = FocusNode();
  FocusNode _nicknameFocus = FocusNode();

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

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
          Container(
            alignment: Alignment.center,
            child: Text(S.current.register2,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
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
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                focusNode: _nicknameFocus,
                decoration: InputDecoration(
                    hintText: S.current.user_name,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => nickname = input),
              ),
            ),
          ),
          Expanded(child: Text("")),
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
    getCaptchaOnRegister(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error));
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
      checkInfo2(idNum, email, phone,
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
          onFailure: (e) => ToastProvider.error(e.error));
    }
  }

  FocusNode _idNumFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();
  FocusNode _codeFocus = FocusNode();

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

  @override
  Widget build(BuildContext context) {
    /// 两边的padding各30，中间间隔20
    double width = GlobalModel().screenWidth - 80;
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
          Container(
            alignment: Alignment.center,
            child: Text(S.current.register2,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
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
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
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
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
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
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => phone = input),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
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
                        contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                    onChanged: (input) => setState(() => code = input),
                  ),
                ),
                Container(
                    height: 55,
                    width: width / 2 - 20,
                    margin: const EdgeInsets.only(left: 20),
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
                              return RaisedButton(
                                onPressed: () {},
                                color: Colors.grey[300],
                                splashColor: Colors.grey[300],
                                child: Text('$time秒后重试',
                                    style: FontManager.YaHeiRegular.copyWith(
                                        color: Color.fromRGBO(98, 103, 123, 1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              );
                            })
                        : RaisedButton(
                            onPressed: _fetchCaptcha,
                            color: Color.fromRGBO(53, 59, 84, 1.0),
                            splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                            child: Text(S.current.fetch_captcha,
                                style: FontManager.YaHeiRegular.copyWith(
                                    color: Colors.white, fontSize: 13)),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          )),
              ],
            ),
          ),
          Expanded(child: Text("")),
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
              Expanded(child: Text("")),
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
  bool check = false;

  _submit() async {
    if (password1 == "")
      ToastProvider.error("请输入密码");
    else if (password2 == "")
      ToastProvider.error("请再次输入密码");
    else if (password1 != password2)
      ToastProvider.error("两次输入密码不一致");
    else if (!check)
      ToastProvider.error("请阅读用户须知");
    else {
      register(widget.userNum, widget.nickname, widget.phone, widget.code,
          password1, widget.email, widget.idNum,
          onSuccess: () {
            ToastProvider.success("注册成功");
            Navigator.pushNamedAndRemoveUntil(
                context, AuthRouter.login, (route) => false);
          },
          onFailure: (e) => ToastProvider.error(e.error));
    }
  }

  FocusNode _pw1Focus = FocusNode();
  FocusNode _pw2Focus = FocusNode();

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

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
          Container(
            alignment: Alignment.center,
            child: Text(S.current.register2,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
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
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
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
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 22),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => password2 = input),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  child: Checkbox(
                    value: this.check,
                    activeColor: Color.fromRGBO(98, 103, 123, 1),
                    onChanged: (bool val) {
                      // val 是布尔值
                      this.setState(() {
                        this.check = !this.check;
                      });
                    },
                  ),
                ),
                Text(S.current.register_hint1,
                    style: FontManager.YaHeiRegular.copyWith(
                        color: Color.fromRGBO(79, 88, 107, 1))),
                GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) => RegisterDialog()),
                  child: Text(S.current.register_hint2,
                      style: FontManager.YaHeiRegular.copyWith(
                          color: Colors.blue,
                          textBaseline: TextBaseline.alphabetic,
                          decoration: TextDecoration.underline)),
                )
              ])),
          Expanded(child: Text("")),
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
              Expanded(child: Text("")),
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
