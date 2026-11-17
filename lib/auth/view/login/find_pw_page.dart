import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/find_pw_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class FindPwWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '找回密码',
      subtitle: '天外天账号密码找回',
      children: [
        _OptionTile(
          icon: Icons.phone_iphone_rounded,
          title: '账号已绑定手机号',
          subtitle: '通过短信验证码重置密码',
          onTap: () => Navigator.pushNamed(context, AuthRouter.findPhone),
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: Icons.support_agent_rounded,
          title: '账号未绑定手机号',
          subtitle: '联系辅导员或天外天用户社区',
          onTap: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) => FindPwDialog()),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final accent = theme.get(WpyColorKey.primaryActionColor);
    return Material(
      color: theme.get(WpyColorKey.secondaryBackgroundColor),
      borderRadius: BorderRadius.circular(AuthLayout.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuthLayout.radius),
            border: Border.all(color: theme.get(WpyColorKey.lightBorderColor)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: authText(context, 15, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: authText(context, 12,
                            color: theme.get(WpyColorKey.secondaryTextColor))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.get(WpyColorKey.secondaryTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class FindPwByPhoneWidget extends StatefulWidget {
  @override
  _FindPwByPhoneWidgetState createState() => _FindPwByPhoneWidgetState();
}

class _FindPwByPhoneWidgetState extends State<FindPwByPhoneWidget>
    with AuthLoadingMixin {
  String phone = "";
  String code = "";

  void _fetchCaptcha(VoidCallback start) {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnReset(phone,
        onSuccess: start,
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  void _verifyCaptcha() {
    FocusScope.of(context).unfocus();
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
      return;
    }
    startLoading();
    AuthService.verifyOnReset(phone, code, onSuccess: () {
      stopLoading();
      if (!mounted) return;
      Navigator.pushNamed(context, AuthRouter.resetPw, arguments: phone);
    }, onFailure: (e) {
      stopLoading();
      ToastProvider.error(e.error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: '验证手机号',
      subtitle: '我们将向绑定的手机号发送验证码',
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
            text: '下一步', loading: loading, onPressed: _verifyCaptcha),
      ],
    );
  }
}
