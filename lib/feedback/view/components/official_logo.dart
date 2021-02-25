import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';

class OfficialLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        '官方',
        style: TextStyle(
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
