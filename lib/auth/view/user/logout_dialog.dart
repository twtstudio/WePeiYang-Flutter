import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class LogoutDialog extends Dialog {
  void _logout(BuildContext context) {
    ToastProvider.success("退出登录成功");
    UmengCommonSdk.onProfileSignOff();
    CommonPreferences.clearAllPrefs();
    if (CommonPreferences.lakeToken.value != '')
      context.read<LakeModel>().clearAll();
    Navigator.pushNamedAndRemoveUntil(
        WePeiYangApp.navigatorState.currentContext!,
        AuthRouter.login,
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final _hintStyle = TextUtil.base.bold.noLine.sp(15).oldThirdAction(context);
    return Center(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(S.current.logout_hint,
                style: TextUtil.base.normal.noLine
                    .sp(13)
                    .oldSecondaryAction(context)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                SizedBox(width: 30),
                WButton(
                  onPressed: () => _logout(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.ok, style: _hintStyle),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
