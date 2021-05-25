import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/main.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';

class LogoutDialog extends Dialog {
  void _logout() {
    ToastProvider.success("退出登录成功");
    CommonPreferences().clearUserPrefs();
    Navigator.pushNamedAndRemoveUntil(
        WeiPeiYangApp.navigatorState.currentContext,
        AuthRouter.login,
        (route) => false);
  }

  static final _hintStyle = FontManager.YaQiHei.copyWith(
      fontSize: 15,
      color: Color.fromRGBO(98, 103, 123, 1),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(S.current.logout_hint,
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Color.fromRGBO(79, 88, 107, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                Container(width: 30),
                GestureDetector(
                  onTap: _logout,
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
