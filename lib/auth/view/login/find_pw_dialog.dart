import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class FindPwDialog extends Dialog {
  static final _hintStyle = TextUtil.base.w600.noLine.sp(13).blue79;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 160,
        width: WePeiYangApp.screenWidth - 40,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: ColorUtil.white237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text(S.current.has_not_bind_hint1,
                      style: _hintStyle, textAlign: TextAlign.center),
                  Spacer(flex: 1),
                  Text(S.current.has_not_bind_hint2,
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
                child: Icon(Icons.close, color: ColorUtil.white210, size: 25),
              ),
            )
          ],
        ),
      ),
    );
  }
}
