import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';

class ResetDoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final success = theme.get(WpyColorKey.primaryActionColor);
    return AuthScaffold(
      title: '密码修改完成',
      subtitle: '请使用新密码重新登录',
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: success, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text('你的天外天账号密码已重置成功',
            textAlign: TextAlign.center,
            style: authText(context, 14,
                color: theme.get(WpyColorKey.secondaryTextColor))),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: '前往登录',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AuthRouter.login, (route) => false),
        ),
      ],
    );
  }
}
