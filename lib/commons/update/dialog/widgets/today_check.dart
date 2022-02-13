// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

class TodayShowAgainCheck extends StatefulWidget {
  const TodayShowAgainCheck({Key? key}) : super(key: key);

  @override
  _TodayShowAgainCheckState createState() => _TodayShowAgainCheckState();
}

class _TodayShowAgainCheckState extends State<TodayShowAgainCheck> {
  bool todayNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final size = DialogSize.getSize(context);
    final checkboxLeftPadding = size.horizontalPadding;
    const checkboxElsePadding = 10.0;
    final checkboxHeight = size.dialogWidth * 0.053;

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
            setState(() {
              todayNotShowAgain = !todayNotShowAgain;
              if(todayNotShowAgain){
                CommonPreferences().todayShowUpdateAgain.value = DateTime.now().toString();
              }else {
                CommonPreferences().todayShowUpdateAgain.value = '';
              }
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              left: checkboxLeftPadding,
              top: checkboxElsePadding,
              bottom: checkboxElsePadding * 2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                todayNotShowAgain
                    ? Icon(
                  Icons.check_circle,
                  size: checkboxHeight,
                  color: Colors.black,
                )
                    : Icon(
                  Icons.panorama_fish_eye,
                  size: checkboxHeight,
                  color: const Color(0xffdedede),
                ),
                const SizedBox(width: checkboxElsePadding - 4),
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
