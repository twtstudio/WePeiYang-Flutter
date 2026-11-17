import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/auth/view/login/widgets/auth_widgets.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import '../../../commons/themes/wpy_theme.dart';

class FindPwDialog extends StatelessWidget {
  static const _groups = [
    ('2群', '738064793'),
    ('3群', '337647539'),
    ('4群', '758808130'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final secondary = theme.get(WpyColorKey.secondaryTextColor);
    return Dialog(
      backgroundColor: theme.get(WpyColorKey.primaryBackgroundColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('联系辅导员重置密码',
                  style: authText(context, 18, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('您好！请联系辅导员进行密码重置。若有疑问，请加入天外天用户社区 QQ 群：',
                  style: authText(context, 14, color: secondary)),
              const SizedBox(height: 16),
              for (final (name, id) in _groups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: theme.get(WpyColorKey.secondaryBackgroundColor),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: id));
                        ToastProvider.success('已复制群号 $id');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Text(name,
                                style: authText(context, 14, color: secondary)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(id,
                                  style: authText(context, 15,
                                      weight: FontWeight.w600)),
                            ),
                            Icon(Icons.copy_rounded,
                                size: 18, color: secondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: AuthTextButton(
                    text: '我知道了', onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
