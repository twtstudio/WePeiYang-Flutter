import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

final _hintStyle = TextUtil.base.bold.noLine
    .sp(15)
    .customColor(Color.fromRGBO(98, 103, 123, 1));

class TjuUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    ClassesService.logout();
    CommonPreferences.clearTjuPrefs();
    Provider.of<GPANotifier>(context, listen: false).clear();
    Provider.of<CourseProvider>(context, listen: false).clear();
    Provider.of<ExamProvider>(context, listen: false).clear();
    Navigator.pop(context);
  }

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
              child: Text(S.current.tju_unbind_hint,
                  textAlign: TextAlign.center,
                  style: TextUtil.base.normal.noLine
                      .sp(11)
                      .customColor(Color.fromRGBO(79, 88, 107, 1))),
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
                SizedBox(width: 30),
                GestureDetector(
                  onTap: () => _unbind(context),
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

class PhoneUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    CommonPreferences.phone.value = "";
    Navigator.pop(context);
  }

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
              child: Text(S.current.phone_unbind_hint,
                  textAlign: TextAlign.center,
                  style: TextUtil.base.normal.noLine
                      .sp(11)
                      .customColor(Color.fromRGBO(79, 88, 107, 1))),
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
                SizedBox(width: 30),
                GestureDetector(
                  onTap: () => _unbind(context),
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

class EmailUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    CommonPreferences.email.value = "";
    Navigator.pop(context);
  }

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
              child: Text(S.current.email_unbind_hint,
                  textAlign: TextAlign.center,
                  style: TextUtil.base.normal.noLine
                      .sp(11)
                      .customColor(Color.fromRGBO(79, 88, 107, 1))),
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
                SizedBox(width: 30),
                GestureDetector(
                  onTap: () => _unbind(context),
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

class LogoffDialog extends Dialog {
  void _logoff() {
    AuthService.logoff(onSuccess: () {
      ToastProvider.success("注销账号成功");
      UmengCommonSdk.onProfileSignOff();
      CommonPreferences.clearUserPrefs();
      CommonPreferences.clearTjuPrefs();
      Navigator.pushNamedAndRemoveUntil(
          WePeiYangApp.navigatorState.currentContext,
          AuthRouter.login,
          (route) => false);
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

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
              child: Text('注销账号后，账号数据将清空不能再找回，是否确认注销账号？',
                  textAlign: TextAlign.center,
                  style: TextUtil.base.w900.noLine
                      .sp(18)
                      .customColor(Color.fromRGBO(255, 0, 0, 1))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.cancel,
                        style: TextUtil.base.w900.mainColor.sp(20)),
                  ),
                ),
                SizedBox(width: 30),
                GestureDetector(
                  onTap: _logoff,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.ok,
                        style: TextUtil.base.w400.dangerousRed.sp(15)),
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
