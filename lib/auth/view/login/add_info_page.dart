import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class AddInfoWidget extends StatefulWidget {
  @override
  _AddInfoWidgetState createState() => _AddInfoWidgetState();
}

class _AddInfoWidgetState extends State<AddInfoWidget> with AuthLoadingMixin {
  String email = "";
  String phone = "";
  String code = "";

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _fetchCaptcha(VoidCallback start) {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnRegister(phone,
        onSuccess: start,
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (email == "")
      ToastProvider.error("E-mail不能为空");
    else if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      startLoading();
      AuthService.addInfo(phone, code, email, onSuccess: () {
        stopLoading();
        // 第一次登录成功后载入用户资料
        LakeTokenManager().refreshToken();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, HomeRouter.home, (route) => false);
      }, onFailure: (e) {
        stopLoading();
        ToastProvider.error(e.error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '完善账号信息',
      subtitle: '请补全邮箱和手机号后登录',
      children: [
        AuthTextField(
          label: '邮箱',
          hint: '请输入邮箱',
          icon: Icons.mail_outline_rounded,
          focusNode: _emailFocus,
          nextFocus: _phoneFocus,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onChanged: (v) => email = v,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '手机号',
          hint: '请输入手机号',
          icon: Icons.phone_iphone_rounded,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.telephoneNumber],
          onChanged: (v) => phone = v,
          trailing: CaptchaButton(onFetch: _fetchCaptcha),
        ),
        const SizedBox(height: 16),
        AuthCodeInput(onChanged: (v) => code = v),
        const SizedBox(height: 24),
        AuthPrimaryButton(text: '提交并登录', loading: loading, onPressed: _submit),
      ],
    );
  }
}
