import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';

class RegisterPageOne extends StatefulWidget {
  @override
  _RegisterPageOneState createState() => _RegisterPageOneState();
}

class _RegisterPageOneState extends State<RegisterPageOne> {
  String userNum = "";
  String nickname = "";
  String idNum = "";
  String email = "";
  String md = "";

  _toNextPage() async {
    if (userNum == "")
      ToastProvider.error("学号不能为空");
    else if (nickname == "")
      ToastProvider.error("昵称不能为空");
    else if (idNum == "")
      ToastProvider.error("身份证号不能为空");
    else {
      AuthService.checkInfo1(userNum, nickname,
          onSuccess: () {
            _userNumFocus.unfocus();
            _nicknameFocus.unfocus();
            //第一个页面没有电话号码，接口是固定的，随便串传一个电话号码
            AuthService.checkInfo2(idNum, email, "99999999999",
                onSuccess: () {
                  _idNumFocus.unfocus();
                  _emailFocus.unfocus();
                  Navigator.pushNamed(context, AuthRouter.register2,
                      arguments: {
                        'userNum': userNum,
                        'nickname': nickname,
                        'idNum': idNum,
                        'email': email,
                      });
                },
                onFailure: (e) => ToastProvider.error(e.error.toString()));
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  final FocusNode _userNumFocus = FocusNode();
  final FocusNode _nicknameFocus = FocusNode();
  final FocusNode _idNumFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Container(
        height: 1.sh,
        decoration: BoxDecoration(
          gradient: WpyTheme.of(context)
              .getGradient(WpyColorSetKey.primaryGradientAllScreen),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
                child: Text('新用户注册',
                    style: TextUtil.base.normal.NotoSansSC
                        .sp(40)
                        .w700
                        .bright(context)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 130.h),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 62),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "学号",
                                  style: TextUtil.base.normal.NotoSansSC.w400
                                      .sp(16)
                                      .bright(context),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 55,
                                ),
                                child: TextField(
                                  style: TextUtil.base.normal.w400
                                      .sp(14)
                                      .NotoSansSC
                                      .bright(context),
                                  cursorColor: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  textInputAction: TextInputAction.next,
                                  focusNode: _userNumFocus,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    hintText: "请输入学号",
                                    //S.current.student_id,
                                    hintStyle: TextUtil.base.normal
                                        .sp(14)
                                        .w400
                                        .bright(context),
                                    isCollapsed: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 18),
                                  ),
                                  onChanged: (input) =>
                                      setState(() => userNum = input),
                                  onEditingComplete: () {
                                    _userNumFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_nicknameFocus);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: '昵称',
                                  style: TextUtil.base.normal.NotoSansSC.w400
                                      .sp(16)
                                      .bright(context),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 55,
                                ),
                                child: TextField(
                                  style: TextUtil.base.normal.w400
                                      .sp(14)
                                      .NotoSansSC
                                      .bright(context),
                                  cursorColor: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  textInputAction: TextInputAction.next,
                                  focusNode: _nicknameFocus,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    hintText: "请输入昵称",
                                    //S.current.user_name,
                                    hintStyle: TextUtil.base.normal
                                        .sp(14)
                                        .w400
                                        .bright(context),
                                    isCollapsed: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 18),
                                  ),
                                  onChanged: (input) =>
                                      setState(() => nickname = input),
                                  onEditingComplete: () {
                                    _nicknameFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_idNumFocus);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "身份证号",
                                  style: TextUtil.base.normal.NotoSansSC.w400
                                      .sp(16)
                                      .bright(context),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 55,
                                ),
                                child: TextField(
                                  style: TextUtil.base.normal.w400
                                      .sp(14)
                                      .NotoSansSC
                                      .bright(context),
                                  cursorColor: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  textInputAction: TextInputAction.next,
                                  focusNode: _idNumFocus,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    hintText: "请输入身份证号",
                                    //S.current.user_name,
                                    hintStyle: TextUtil.base.normal
                                        .sp(14)
                                        .w400
                                        .bright(context),
                                    isCollapsed: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 18),
                                  ),
                                  onChanged: (input) =>
                                      setState(() => idNum = input),
                                  onEditingComplete: () {
                                    _idNumFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_emailFocus);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "邮箱",
                                  style: TextUtil.base.normal.NotoSansSC.w400
                                      .sp(16)
                                      .bright(context),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 55,
                                ),
                                child: TextField(
                                  style: TextUtil.base.normal.w400
                                      .sp(14)
                                      .NotoSansSC
                                      .bright(context),
                                  cursorColor: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  textInputAction: TextInputAction.next,
                                  focusNode: _emailFocus,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: WpyTheme.of(context).get(
                                            WpyColorKey.primaryBackgroundColor),
                                        width: 1.0,
                                      ),
                                    ),
                                    hintText: "请输入邮箱",
                                    //S.current.user_name,
                                    hintStyle: TextUtil.base.normal
                                        .sp(14)
                                        .w400
                                        .bright(context),
                                    isCollapsed: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 18, 0, 18),
                                  ),
                                  onChanged: (input) =>
                                      setState(() => email = input),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                          SizedBox(
                              child: WButton(
                            onPressed: _toNextPage,
                            child: Container(
                              height: 48,
                              width: width - 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.primaryBackgroundColor),
                              ),
                              child: Center(
                                child: Text("下一步",
                                    style: TextUtil.base.normal.NotoSansSC.w400
                                        .sp(16)
                                        .primaryAction(context)),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ) //
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPageTwo extends StatefulWidget {
  final String userNum;
  final String nickname;
  final String idNum;
  final String email;

  RegisterPageTwo(this.userNum, this.nickname, this.idNum, this.email);

  @override
  _RegisterPageTwoState createState() => _RegisterPageTwoState();
}

class _RegisterPageTwoState extends State<RegisterPageTwo> {
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
    if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      AuthService.checkInfo2(widget.idNum, widget.email, phone,
          onSuccess: () {
            _phoneFocus.unfocus();
            Navigator.pushNamed(context, AuthRouter.register3, arguments: {
              'userNum': widget.userNum,
              'nickname': widget.nickname,
              'idNum': widget.idNum,
              'email': widget.email,
              'phone': phone,
              'code': code
            });
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  final FocusNode _phoneFocus = FocusNode();

  //6个密码框
  final TextEditingController codeController1 = TextEditingController();
  final TextEditingController codeController2 = TextEditingController();
  final TextEditingController codeController3 = TextEditingController();
  final TextEditingController codeController4 = TextEditingController();
  final TextEditingController codeController5 = TextEditingController();
  final TextEditingController codeController6 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// 两边的padding各30，中间间隔20
    double width = WePeiYangApp.screenWidth;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: WpyTheme.of(context)
              .getGradient(WpyColorSetKey.primaryGradientAllScreen),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: "新用户注册",
                    style: TextUtil.base.normal.NotoSansSC
                        .sp(40)
                        .w700
                        .bright(context)),
              ])),
            ),
            SizedBox(height: 62),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                        text: "手机号",
                        style: TextUtil.base.normal.NotoSansSC.w400
                            .sp(16)
                            .bright(context),
                      )),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 55,
                        ),
                        child: TextField(
                          style: TextUtil.base.normal.w400
                              .sp(14)
                              .NotoSansSC
                              .bright(context),
                          cursorColor: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          textInputAction: TextInputAction.next,
                          focusNode: _phoneFocus,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.primaryBackgroundColor),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.primaryBackgroundColor),
                                width: 1.0,
                              ),
                            ),
                            hintText: "请输入手机号",
                            hintStyle: TextUtil.base.normal
                                .sp(14)
                                .w400
                                .bright(context),
                            isCollapsed: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 18, 0, 18),
                          ),
                          onChanged: (input) => setState(() => phone = input),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                        text: "验证码",
                        style: TextUtil.base.normal.NotoSansSC.w400
                            .sp(16)
                            .bright(context),
                      )),
                      SizedBox(height: 20),
                      Stack(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryBackgroundColor)
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    code.length > 0 ? code.substring(0, 1) : "",
                                    style: TextUtil.base.normal.NotoSansSC
                                        .primaryAction(context)
                                        .sp(16),
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryBackgroundColor)
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    code.length > 1 ? code.substring(1, 2) : "",
                                    style: TextUtil.base.normal.NotoSansSC
                                        .primaryAction(context)
                                        .sp(16),
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryBackgroundColor)
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    code.length > 2 ? code.substring(2, 3) : "",
                                    style: TextUtil.base.normal.NotoSansSC
                                        .primaryAction(context)
                                        .sp(16),
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryBackgroundColor)
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    code.length > 3 ? code.substring(3, 4) : "",
                                    style: TextUtil.base.normal.NotoSansSC
                                        .primaryAction(context)
                                        .sp(16),
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryBackgroundColor)
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    code.length > 4 ? code.substring(4, 5) : "",
                                    style: TextUtil.base.normal.NotoSansSC
                                        .primaryAction(context)
                                        .sp(16),
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: WpyTheme.of(context)
                                        .get(WpyColorKey.primaryBackgroundColor)
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    code.length > 5 ? code.substring(5, 6) : "",
                                    style: TextUtil.base.normal.NotoSansSC
                                        .primaryAction(context)
                                        .sp(16),
                                  ),
                                ),
                              ]),
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextUtil.base.normal.w400
                                .sp(16)
                                .NotoSansSC
                                .transParent,
                            showCursor: false,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(0, 18, 0, 18),
                            ),
                            onChanged: (input) => setState(() => code = input),
                          ),
                        ],
                      ),
                      SizedBox(height: 39),
                      //"下一步"按钮
                      SizedBox(
                          child: WButton(
                        onPressed: _toNextPage,
                        child: Container(
                          height: 48,
                          width: width - 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor),
                          ),
                          child: Center(
                            child: Text("下一步",
                                style: TextUtil.base.normal.NotoSansSC.w400
                                    .sp(16)
                                    .primaryAction(context)),
                          ),
                        ),
                      )),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Spacer(),
                          WButton(
                            child: isPress
                                ? StreamBuilder<int>(
                                    stream: Stream.periodic(
                                        Duration(seconds: 1),
                                        (time) => time + 1).take(60),
                                    builder: (context, snap) {
                                      var time = 60 - (snap.data ?? 0);
                                      if (time == 0)
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                                setState(
                                                    () => isPress = false));
                                      return WButton(
                                          onPressed: () {},
                                          child: Text.rich(TextSpan(
                                            text: '$time秒后重试',
                                            style: TextUtil
                                                .base.normal.NotoSansSC.w400
                                                .sp(14)
                                                .bright(context),
                                          )));
                                    })
                                : WButton(
                                    onPressed: _fetchCaptcha,
                                    child: Text(
                                      "获取验证码",
                                      style: TextUtil
                                          .base.normal.NotoSansSC.w400
                                          .sp(14)
                                          .bright(context),
                                    ),
                                  ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
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
  String md = '';

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
      AuthService.register(widget.userNum, widget.nickname, widget.phone,
          widget.code, password1, widget.email, widget.idNum,
          onSuccess: () {
            FeedbackService.getTokenByPw(widget.userNum, password1,
                onSuccess: () {
                  FeedbackService.changeNickname(
                      nickName: widget.nickname,
                      onSuccess: () {},
                      onFailure: (e) =>
                          ToastProvider.error(e.error.toString()));
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
    double width = WePeiYangApp.screenWidth;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: WpyTheme.of(context)
              .getGradient(WpyColorSetKey.primaryGradientAllScreen),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(30, 70, 0, 0),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: "新用户注册",
                    style: TextUtil.base.normal.NotoSansSC
                        .sp(40)
                        .w700
                        .bright(context)),
              ])),
            ),
            SizedBox(height: 62),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "设置密码",
                            style: TextUtil.base.normal.NotoSansSC.w400
                                .sp(16)
                                .bright(context),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 55,
                          ),
                          child: TextField(
                            cursorColor: WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor),
                            style: TextUtil.base.normal.w400
                                .sp(14)
                                .NotoSansSC
                                .bright(context),
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            focusNode: _pw1Focus,
                            obscureText: true,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  width: 1.0,
                                ),
                              ),
                              hintText: "请输入密码",
                              hintStyle: TextUtil.base.normal
                                  .sp(14)
                                  .w400
                                  .bright(context),
                              isCollapsed: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(0, 18, 0, 18),
                            ),
                            onChanged: (input) =>
                                setState(() => password1 = input),
                            onEditingComplete: () {
                              _pw1Focus.unfocus();
                              FocusScope.of(context).requestFocus(_pw2Focus);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "确认密码",
                            style: TextUtil.base.normal.NotoSansSC.w400
                                .sp(16)
                                .bright(context),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 55,
                          ),
                          child: TextField(
                            style: TextUtil.base.normal.w400
                                .sp(14)
                                .NotoSansSC
                                .bright(context),
                            cursorColor: WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor),
                            keyboardType: TextInputType.visiblePassword,
                            focusNode: _pw2Focus,
                            obscureText: true,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.primaryBackgroundColor),
                                  width: 1.0,
                                ),
                              ),
                              hintText: '请再次输入您的密码',
                              hintStyle: TextUtil.base.normal
                                  .sp(14)
                                  .w400
                                  .bright(context),
                              isCollapsed: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(0, 18, 0, 18),
                            ),
                            onChanged: (input) =>
                                setState(() => password2 = input),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      height: 48,
                      //这样的地方改了，便于屏幕适配
                      width: width - 60,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text.rich(TextSpan(
                            text: '注册并登录',
                            style: TextUtil.base.normal.NotoSansSC.w400
                                .sp(16)
                                .primaryAction(context))),
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (states.contains(MaterialState.pressed))
                              return WpyTheme.of(context)
                                  .get(WpyColorKey.reverseBackgroundColor)
                                  .withOpacity(0.1);
                            return WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor);
                          }),
                          backgroundColor: MaterialStateProperty.all(
                              WpyTheme.of(context)
                                  .get(WpyColorKey.primaryBackgroundColor)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24))),
                        ),
                      ),
                    ),
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
                              activeColor: WpyTheme.of(context)
                                  .get(WpyColorKey.primaryActionColor),
                              onChanged: (_) {
                                checkNotifier.value = !checkNotifier.value;
                              },
                            );
                          },
                        ),
                        Text.rich(TextSpan(
                            text: "我已阅读并同意",
                            style: TextUtil.base.normal.NotoSansSC.w400
                                .sp(10)
                                .label(context))),
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
                                .label(context))),
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
                    const SizedBox(height: 30),
                    // Row(
                    //   children: [
                    //     Container(
                    //       height: 50,
                    //       alignment: Alignment.bottomLeft,
                    //       margin: const EdgeInsets.all(30),
                    //       child: WButton(
                    //         onPressed: () => Navigator.pop(context),
                    //         child: Image(
                    //             image: AssetImage(
                    //                 'assets/images/arrow_round_back.png')),
                    //       ),
                    //     ),
                    //     Spacer(),
                    //     Container(
                    //       height: 50,
                    //       alignment: Alignment.bottomRight,
                    //       margin: const EdgeInsets.all(30),
                    //       child: WButton(
                    //         onPressed: _submit,
                    //         child: Image(
                    //             image: AssetImage(
                    //                 'assets/images/arrow_round.png')),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
