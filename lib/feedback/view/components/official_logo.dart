import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';

class OfficialLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        S.current.feedback_official,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 12,
          color: Colors.white,
          height: 1,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1080),
        color: ColorUtil.mainColor,
      ),
    );
  }
}
