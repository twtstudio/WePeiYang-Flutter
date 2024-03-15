import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

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
    final _hintStyle = TextUtil.base.bold.noLine.sp(15).oldThirdAction(context);
    return Center(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(S.current.tju_unbind_hint,
                  textAlign: TextAlign.center,
                  style: TextUtil.base.normal.noLine
                      .sp(11)
                      .oldSecondaryAction(context)),
            ),
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
                  onPressed: () => _unbind(context),
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
    final _hintStyle = TextUtil.base.bold.noLine.sp(15).oldThirdAction(context);
    return Center(
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(S.current.phone_unbind_hint,
                  textAlign: TextAlign.center,
                  style: TextUtil.base.normal.noLine
                      .sp(11)
                      .oldSecondaryAction(context)),
            ),
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
                  onPressed: () => _unbind(context),
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
    final _hintStyle = TextUtil.base.bold.noLine.sp(15).oldThirdAction(context);
    return Center(
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Text(S.current.email_unbind_hint,
                  textAlign: TextAlign.center,
                  style: TextUtil.base.normal.noLine
                      .sp(11)
                      .oldSecondaryAction(context)),
            ),
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
                  onPressed: () => _unbind(context),
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
    // AuthService.logoff(onSuccess: () {
    //   ToastProvider.success("注销账号成功");
    //   UmengCommonSdk.onProfileSignOff();
    //   CommonPreferences.clearAllPrefs();
    //   Navigator.pushNamedAndRemoveUntil(
    //       WePeiYangApp.navigatorState.currentContext!,
    //       AuthRouter.login,
    //       (route) => false);
    // }, onFailure: (e) {
    //   ToastProvider.error(e.error.toString());
    // });
    // TODO: 太危险了 请去网页
    Clipboard.setData(ClipboardData(text: "https://i.twt.edu.cn"));
    ToastProvider.success("网页已经复制到剪贴板");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(children: [
        Container(
          // height: 160,

          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text('警告',
                    textAlign: TextAlign.center,
                    style:
                        TextUtil.base.bold.noLine.sp(18).dangerousRed(context)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Text(
                    '注销账号后，账号数据将清空不能再找回，该操作属于危险操作\n请前往https://i.twt.edu.cn 处理',
                    textAlign: TextAlign.center,
                    style: TextUtil.base.noLine.sp(16).dangerousRed(context)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WButton(
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(S.current.cancel,
                          style:
                              TextUtil.base.w400.primaryAction(context).sp(15)),
                    ),
                  ),
                  SizedBox(width: 30),
                  WButton(
                    onPressed: _logoff,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Text("复制到剪贴板",
                          style: TextUtil.base.w400.label(context).sp(15)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
