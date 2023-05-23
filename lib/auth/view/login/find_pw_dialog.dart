// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class FindPwDialog extends Dialog {
  static final _hintStyle = TextUtil.base.w600.noLine.sp(13).customColor(
      Color.fromRGBO(79, 88, 107, 1));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 160,
        width: WePeiYangApp.screenWidth - 40,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
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
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.fromLTRB(0, 15, 10, 0),
                child: Icon(Icons.close,
                    color: Color.fromRGBO(210, 210, 210, 1), size: 25),
              ),
            )
          ],
        ),
      ),
    );
  }
}
