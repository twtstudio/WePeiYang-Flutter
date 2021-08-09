import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

final _hintStyle = FontManager.YaQiHei.copyWith(
    fontSize: 15,
    color: Color.fromRGBO(98, 103, 123, 1),
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none);

class TjuUnbindDialog extends Dialog {
  void _unbind(BuildContext context) {
    ToastProvider.success("解除绑定成功");
    CommonPreferences().clearTjuPrefs();
    Provider.of<GPANotifier>(context, listen: false).clear();
    Provider.of<ScheduleNotifier>(context, listen: false).clear();
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
                  style: FontManager.YaHeiRegular.copyWith(
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
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                Container(width: 30),
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
    CommonPreferences().phone.value = "";
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
              child: Text(S.current.not_bind,
                  textAlign: TextAlign.center,
                  style: FontManager.YaHeiRegular.copyWith(
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
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                Container(width: 30),
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
    CommonPreferences().email.value = "";
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
                  style: FontManager.YaHeiRegular.copyWith(
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
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                Container(width: 30),
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
