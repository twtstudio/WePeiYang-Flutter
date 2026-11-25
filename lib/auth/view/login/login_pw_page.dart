import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class LoginPwWidget extends StatefulWidget {
  @override
  _LoginPwWidgetState createState() => _LoginPwWidgetState();
}

class _LoginPwWidgetState extends State<LoginPwWidget> with AuthLoadingMixin {
  final checkNotifier = ValueNotifier<bool>(false); // 是否勾选隐私政策
  bool _usePwLogin = true;

  String account = "";
  String password = "";
  String phone = "";
  String code = "";

  final FocusNode _accountFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void dispose() {
    checkNotifier.dispose();
    _accountFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _onLoginResult(Map result) async {
    if (!mounted) return;
    if (result['telephone'] == null || result['email'] == null) {
      stopLoading();
      Navigator.pushNamed(context, AuthRouter.addInfo);
    } else {
      // 第一次登录的时候载入用户资料
      // TODO: 应该统一管理 token 而不是想到刷新一下就重新请求
      try {
        await LakeTokenManager().refreshToken();
        await FeedbackService.getUserInfo(onSuccess: () {}, onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
      } catch (e) {
        ToastProvider.error(e.toString());
      } finally {
        stopLoading();
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, HomeRouter.home, (route) => false);
    }
  }

  void _onLoginFailure(dynamic e) {
    stopLoading();
    ToastProvider.error(e.error.toString());
  }

  void _login() {
    FocusScope.of(context).unfocus();
    if (_usePwLogin) {
      if (account == "" || password == "") {
        ToastProvider.error('账号密码不能为空');
      } else if (!checkNotifier.value) {
        ToastProvider.error('请同意用户协议与隐私政策并继续');
      } else {
        startLoading();
        AuthService.pwLogin(account, password,
            onResult: _onLoginResult, onFailure: _onLoginFailure);
      }
    } else {
      if (phone == "") {
        ToastProvider.error('手机号码不能为空');
      } else if (code == "") {
        ToastProvider.error('短信验证码不能为空');
      } else if (!checkNotifier.value) {
        ToastProvider.error('请同意用户协议与隐私政策并继续');
      } else {
        startLoading();
        AuthService.codeLogin(phone, code,
            onResult: _onLoginResult, onFailure: _onLoginFailure);
      }
    }
  }

  void _fetchCaptcha(VoidCallback start) {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnReset(phone,
        onSuccess: start,
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  void _switchMode(int index) {
    final usePw = index == 0;
    if (usePw == _usePwLogin) return;
    FocusScope.of(context).unfocus();
    setState(() => _usePwLogin = usePw);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '登录微北洋',
      subtitle: _usePwLogin ? '使用天外天账号密码登录' : '使用已绑定的手机号登录',
      footer: AuthAgreement(checked: checkNotifier),
      children: [
        AuthSegmented(
          items: const ['密码登录', '短信登录'],
          index: _usePwLogin ? 0 : 1,
          onChanged: _switchMode,
        ),
        const SizedBox(height: 20),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _usePwLogin ? _pwFields() : _codeFields(),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(text: '登录', loading: loading, onPressed: _login),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AuthTextButton(
              text: '忘记密码？',
              color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
              onPressed: () =>
                  Navigator.pushNamed(context, AuthRouter.findHome),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pwFields() {
    return Column(
      key: const ValueKey('pw'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          hint: '学号 / 手机号 / 邮箱',
          icon: Icons.person_outline_rounded,
          focusNode: _accountFocus,
          nextFocus: _passwordFocus,
          autofillHints: const [AutofillHints.username],
          onChanged: (v) => account = v,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          hint: '密码',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          focusNode: _passwordFocus,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
          onChanged: (v) => password = v,
          onSubmitted: (_) => _login(),
        ),
      ],
    );
  }

  Widget _codeFields() {
    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          hint: '手机号',
          icon: Icons.phone_iphone_rounded,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.telephoneNumber],
          onChanged: (v) => phone = v,
          trailing: CaptchaButton(onFetch: _fetchCaptcha),
        ),
        const SizedBox(height: 14),
        AuthCodeInput(onChanged: (v) => code = v),
      ],
    );
  }
}
