import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class ResetPwWidget extends StatefulWidget {
  @override
  _ResetPwWidgetState createState() => _ResetPwWidgetState();
}

class _ResetPwWidgetState extends State<ResetPwWidget> with AuthLoadingMixin {
  String password1 = "";
  String password2 = "";

  final FocusNode _pwInput1 = FocusNode();
  final FocusNode _pwInput2 = FocusNode();

  @override
  void dispose() {
    _pwInput1.dispose();
    _pwInput2.dispose();
    super.dispose();
  }

  void _reset() {
    FocusScope.of(context).unfocus();
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
    startLoading();
    AuthService.resetPwByPhone(phone, password1, onSuccess: () {
      stopLoading();
      if (!mounted) return;
      Navigator.pushNamed(context, AuthRouter.resetDone);
    }, onFailure: (e) {
      stopLoading();
      ToastProvider.error(e.error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '设置新密码',
      subtitle: '请输入新的天外天账号密码',
      children: [
        AuthTextField(
          label: '新密码',
          hint: '请输入新密码',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          focusNode: _pwInput1,
          nextFocus: _pwInput2,
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
          focusNode: _pwInput2,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (v) => password2 = v,
          onSubmitted: (_) => _reset(),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(text: '确认修改', loading: loading, onPressed: _reset),
      ],
    );
  }
}
