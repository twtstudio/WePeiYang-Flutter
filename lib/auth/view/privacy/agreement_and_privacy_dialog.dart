import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';

class AgreementAndPrivacyDialog extends Dialog {
  final String result;

  AgreementAndPrivacyDialog(this.result);

  void _doQuit() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    var textColor = Color.fromRGBO(98, 103, 124, 1);
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            horizontal: 30, vertical: WePeiYangApp.screenHeight / 10),
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(251, 251, 251, 1)),
        child: Column(
          children: [
            Expanded(
              child: DefaultTextStyle(
                textAlign: TextAlign.start,
                style: TextUtil.base.regular.sp(13).customColor(textColor),
                child: Markdown(
                  controller: ScrollController(),
                  selectable: true,
                  data: result,
                ),
              ),
            ),
            SizedBox(height: 13),
            Divider(height: 1, color: Color.fromRGBO(172, 174, 186, 1)),
            _detail(context),
          ],
        ),
      ),
    );
  }

  Widget _detail(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            _doQuit();
          },
          child: Container(
            decoration: BoxDecoration(), // 加个这个扩大点击事件范围
            padding: const EdgeInsets.all(16),
            child: Text('拒绝', style: TextUtil.base.bold.greyA6.noLine.sp(16)),
          ),
        ),
        GestureDetector(
          onTap: () {
            CommonPreferences.isFirstUse.value = false;
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(), // 加个这个扩大点击事件范围
            padding: const EdgeInsets.all(16),
            child: Text('同意',
                style: TextUtil.base.bold.noLine
                    .sp(16)
                    .customColor(Color.fromRGBO(98, 103, 123, 1))),
          ),
        ),
      ],
    );
  }
}

class BoldText extends StatelessWidget {
  final String text;

  BoldText(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontWeight: FontWeight.bold));
}
