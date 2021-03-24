import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/gpa/model/gpa_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

class TjuUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    CommonPreferences().clearTjuPrefs();
    Provider.of<GPANotifier>(context, listen: false).clear();
    Provider.of<ScheduleNotifier>(context, listen: false).clear();
    Navigator.pop(context);
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
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text("解除办公网绑定后无法正常使用课表、GPA、校务专区功能。您是否确定解除绑定？",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromRGBO(79, 88, 107, 1),
                      fontSize: 11,
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
                  onTap: () => _unbind(context),
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

class PhoneUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    CommonPreferences().phone.value = "";
    Navigator.pop(context);
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
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(
                  "解除手机号绑定后无法使用手机号登陆微北洋。若本次登录为手机号登陆则将退出登陆，需要您重新进行账号密码登陆。您是否确定解除绑定？",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromRGBO(79, 88, 107, 1),
                      fontSize: 11,
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
                  onTap: () => _unbind(context),
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

class EmailUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    CommonPreferences().email.value = "";
    Navigator.pop(context);
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
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(
                  "解除邮箱绑定后无法使用邮箱登陆微北洋。若本次登录为邮箱登陆则将退出登陆，需要您重新进行账号密码登陆。您是否确定解除绑定？",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromRGBO(79, 88, 107, 1),
                      fontSize: 11,
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
                  onTap: () => _unbind(context),
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
