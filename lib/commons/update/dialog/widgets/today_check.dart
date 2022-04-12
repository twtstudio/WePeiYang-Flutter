// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

class TodayShowAgainCheck extends StatefulWidget {
  final VoidCallback tap;

  const TodayShowAgainCheck({required this.tap, Key? key}) : super(key: key);

  @override
  _TodayShowAgainCheckState createState() => _TodayShowAgainCheckState();
}

class _TodayShowAgainCheckState extends State<TodayShowAgainCheck> {
  @override
  Widget build(BuildContext context) {
    final size = DialogSize.getSize(context);
    final checkboxLeftPadding = size.horizontalPadding;
    const checkboxElsePadding = 10.0;

    const checkboxTextWidget = Padding(
      padding: EdgeInsets.only(top: 0),
      child: Text(
        '今日不再弹出',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xffdedede),
        ),
      ),
    );

    final checkbox = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            CommonPreferences().todayShowUpdateAgain.value =
                DateTime.now().toString();
            widget.tap();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              left: checkboxLeftPadding,
              top: checkboxElsePadding + 4,
              bottom: checkboxElsePadding * 2 - 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: checkboxElsePadding + 10),
                checkboxTextWidget,
              ],
            ),
          ),
        ),
      ],
    );

    return checkbox;
  }
}
