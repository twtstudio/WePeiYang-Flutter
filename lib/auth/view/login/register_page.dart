import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

const _registerSteps = ['基本信息', '验证手机', '设置密码'];

class RegisterPageOne extends StatefulWidget {
  @override
  _RegisterPageOneState createState() => _RegisterPageOneState();
}

class _RegisterPageOneState extends State<RegisterPageOne>
    with AuthLoadingMixin {
  String userNum = "";
  String nickname = "";
  String idNum = "";
  String email = "";

  final FocusNode _userNumFocus = FocusNode();
  final FocusNode _nicknameFocus = FocusNode();
  final FocusNode _idNumFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void dispose() {
    _userNumFocus.dispose();
    _nicknameFocus.dispose();
    _idNumFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onFailure(dynamic e) {
    stopLoading();
    ToastProvider.error(e.error.toString());
  }

  void _toNextPage() {
    FocusScope.of(context).unfocus();
    if (userNum == "")
      ToastProvider.error("学号不能为空");
    else if (nickname == "")
      ToastProvider.error("昵称不能为空");
    else if (idNum == "")
      ToastProvider.error("身份证号不能为空");
    else {
      startLoading();
      AuthService.checkInfo1(userNum, nickname, onSuccess: () {
        //第一个页面没有电话号码，接口是固定的，随便串传一个电话号码
        AuthService.checkInfo2(idNum, email, "99999999999", onSuccess: () {
          stopLoading();
          if (!mounted) return;
          Navigator.pushNamed(context, AuthRouter.register2, arguments: {
            'userNum': userNum,
            'nickname': nickname,
            'idNum': idNum,
            'email': email,
          });
        }, onFailure: _onFailure);
      }, onFailure: _onFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '新用户注册',
      subtitle: '填写你的学籍信息以创建天外天账号',
      header:
          const AuthStepIndicator(step: 1, total: 3, labels: _registerSteps),
      children: [
        AuthTextField(
          label: '学号',
          hint: '请输入学号',
          icon: Icons.badge_outlined,
          focusNode: _userNumFocus,
          nextFocus: _nicknameFocus,
          onChanged: (v) => userNum = v,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '昵称',
          hint: '请输入昵称',
          icon: Icons.face_outlined,
          focusNode: _nicknameFocus,
          nextFocus: _idNumFocus,
          onChanged: (v) => nickname = v,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '身份证号',
          hint: '请输入身份证号',
          icon: Icons.credit_card_outlined,
          focusNode: _idNumFocus,
          nextFocus: _emailFocus,
          onChanged: (v) => idNum = v,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '邮箱',
          hint: '请输入邮箱',
          icon: Icons.mail_outline_rounded,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onChanged: (v) => email = v,
          onSubmitted: (_) => _toNextPage(),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
            text: '下一步', loading: loading, onPressed: _toNextPage),
      ],
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

class _RegisterPageTwoState extends State<RegisterPageTwo>
    with AuthLoadingMixin {
  String phone = "";
  String code = ""; // 短信验证码

  void _fetchCaptcha(VoidCallback start) {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnRegister(phone,
        onSuccess: start,
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  void _toNextPage() {
    FocusScope.of(context).unfocus();
    if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      startLoading();
      AuthService.checkInfo2(widget.idNum, widget.email, phone, onSuccess: () {
        stopLoading();
        if (!mounted) return;
        Navigator.pushNamed(context, AuthRouter.register3, arguments: {
          'userNum': widget.userNum,
          'nickname': widget.nickname,
          'idNum': widget.idNum,
          'email': widget.email,
          'phone': phone,
          'code': code
        });
      }, onFailure: (e) {
        stopLoading();
        ToastProvider.error(e.error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '验证手机号',
      subtitle: '绑定手机号后可使用短信验证码登录',
      header:
          const AuthStepIndicator(step: 2, total: 3, labels: _registerSteps),
      children: [
        AuthTextField(
          label: '手机号',
          hint: '请输入手机号',
          icon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.telephoneNumber],
          onChanged: (v) => phone = v,
          trailing: CaptchaButton(onFetch: _fetchCaptcha),
        ),
        const SizedBox(height: 16),
        AuthCodeInput(onChanged: (v) => code = v),
        const SizedBox(height: 24),
        AuthPrimaryButton(
            text: '下一步', loading: loading, onPressed: _toNextPage),
      ],
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

class _RegisterPageThreeState extends State<RegisterPageThree>
    with AuthLoadingMixin {
  String password1 = "";
  String password2 = "";
  final checkNotifier = ValueNotifier<bool>(false);

  final FocusNode _pw1Focus = FocusNode();
  final FocusNode _pw2Focus = FocusNode();

  @override
  void dispose() {
    checkNotifier.dispose();
    _pw1Focus.dispose();
    _pw2Focus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (password1 == "")
      ToastProvider.error("请输入密码");
    else if (password2 == "")
      ToastProvider.error("请再次输入密码");
    else if (password1 != password2)
      ToastProvider.error("两次输入密码不一致");
    else if (!checkNotifier.value)
      ToastProvider.error("请同意用户协议与隐私政策并继续");
    else {
      startLoading();
      AuthService.register(widget.userNum, widget.nickname, widget.phone,
          widget.code, password1, widget.email, widget.idNum, onSuccess: () {
        stopLoading();
        FeedbackService.getTokenByPw(widget.userNum, password1,
            onSuccess: () {
              FeedbackService.changeNickname(
                  nickName: widget.nickname,
                  onSuccess: () {},
                  onFailure: (e) => ToastProvider.error(e.error.toString()));
            },
            onFailure: (e) => ToastProvider.error(e.error.toString()));
        ToastProvider.success("注册成功");
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, AuthRouter.login, (route) => false);
      }, onFailure: (e) {
        stopLoading();
        ToastProvider.error(e.error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '设置密码',
      subtitle: '最后一步，为你的账号设置登录密码',
      header:
          const AuthStepIndicator(step: 3, total: 3, labels: _registerSteps),
      footer: AuthAgreement(checked: checkNotifier),
      children: [
        AuthTextField(
          label: '设置密码',
          hint: '请输入密码',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          focusNode: _pw1Focus,
          nextFocus: _pw2Focus,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (v) => password1 = v,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '确认密码',
          hint: '请再次输入密码',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          focusNode: _pw2Focus,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (v) => password2 = v,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(text: '注册并登录', loading: loading, onPressed: _submit),
      ],
    );
  }
}
