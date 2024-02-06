import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class PrivacyDialog extends Dialog {
  final ValueNotifier? check;
  final String result;

  PrivacyDialog(this.result, {this.check});

  @override
  Widget build(BuildContext context) {
    var textColor = WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor);
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            horizontal: 30, vertical: WePeiYangApp.screenHeight / 10),
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
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
            Divider(height: 1, color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor)),
            _detail(context),
          ],
        ),
      ),
    );
  }

  Widget _detail(BuildContext context) {
    if (check == null) {
      return WButton(
        onPressed: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(), // 加个这个扩大点击事件范围
          padding: const EdgeInsets.all(16),
          child: Text('确定',
              style: TextUtil.base.bold.noLine
                  .sp(16)
                  .oldThirdAction(context)),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          WButton(
            onPressed: () {
              check!.value = false;
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(), // 加个这个扩大点击事件范围
              padding: const EdgeInsets.all(16),
              child: Text('拒绝', style: TextUtil.base.bold.unlabeled(context).noLine.sp(16)),
            ),
          ),
          WButton(
            onPressed: () {
              check!.value = true;
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(), // 加个这个扩大点击事件范围
              padding: const EdgeInsets.all(16),
              child: Text('同意',
                  style: TextUtil.base.bold.noLine
                      .sp(16)
                      .oldThirdAction(context)),
            ),
          ),
        ],
      );
    }
  }
}

class BoldText extends StatelessWidget {
  final String text;

  BoldText(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontWeight: FontWeight.bold));
}
