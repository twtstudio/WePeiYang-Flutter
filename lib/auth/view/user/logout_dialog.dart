import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class LogoutDialog extends Dialog {
  void _logout() {
    ToastProvider.success("退出登录成功");
    CommonPreferences().clearUserPrefs();
    CommonPreferences().clearTjuPrefs();
    Navigator.pushNamedAndRemoveUntil(
        WePeiYangApp.navigatorState.currentContext,
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
            SizedBox(height: 20),
            Text(S.current.logout_hint,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(79, 88, 107, 1),
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)),
            SizedBox(height: 20),
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
                SizedBox(width: 30),
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
