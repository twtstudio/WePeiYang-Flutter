import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/main.dart';

class LogoutDialog extends Dialog {
  void _logout() {
    // TODO 其他退出逻辑
    ToastProvider.success("退出登录成功");
    CommonPreferences().clearPrefs();
    Navigator.pushNamedAndRemoveUntil(
        WeiPeiYangApp.navigatorState.currentContext,
        '/login',
        (route) => false);
  }

  static const _hintStyle = TextStyle(
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
              child: Text("您确定要退出登录吗？",
                  style: TextStyle(
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
                    child: Text("取消", style: _hintStyle),
                  ),
                ),
                Container(width: 30),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text("确定", style: _hintStyle),
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
