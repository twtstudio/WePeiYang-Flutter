import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';

class FindPwDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    final _hintStyle =
        TextUtil.base.w600.noLine.sp(13).oldSecondaryAction(context);
    return Center(
      child: Container(
        height: 160,
        width: WePeiYangApp.screenWidth - 40,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text('您好！请联系辅导员进行密码重置！若有疑问，请加入天外天用户社区qq群：',
                      style: _hintStyle, textAlign: TextAlign.center),
                  Spacer(flex: 1),
                  Text('2群群号：738064793\n3群群号：337647539\n4群群号：758808130',
                      style: _hintStyle, textAlign: TextAlign.center),
                  Spacer(flex: 2),
                ],
              ),
            ),
            SizedBox(width: 5),
            WButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.fromLTRB(0, 15, 10, 0),
                child: Icon(Icons.close,
                    color:
                        WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                    size: 25),
              ),
            )
          ],
        ),
      ),
    );
  }
}
