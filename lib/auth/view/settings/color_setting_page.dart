import 'dart:math';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ColorSettingPage extends StatefulWidget {
  @override
  _ColorSettingPageState createState() => _ColorSettingPageState();
}

class _ColorSettingPageState extends State<ColorSettingPage> {
  /// 获取显示16位颜色值的文本
  /// @param [target] 此文本对应的gpa/schedule配色种类
  /// @param [index] index: 0 -> gpa, 1 -> schedule
  static Text getText(String text, Color color, String target, int index) {
    String suffix = "";
    if (index == 0 && FavorColors.gpaType.value == target) suffix = "(已选)";
    if (index == 1 && FavorColors.scheduleType.value == target) suffix = "(已选)";
    return Text(text + suffix,
        style: TextUtil.base.Swis.bold.sp(14).customColor(color));
  }

  ///判断活动皮肤用
  changeSkin() {
    if (CommonPreferences.isAprilFoolClass.value) {
      CommonPreferences.isAprilFoolClass.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var titleTextStyle =
        TextUtil.base.bold.sp(14).customColor(Color.fromRGBO(177, 180, 186, 1));
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(35, 20, 35, 0),
            child: Text(S.current.setting_color,
                style: TextUtil.base.bold
                    .sp(28)
                    .customColor(Color.fromRGBO(48, 60, 102, 1))),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(35, 20, 35, 20),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_color_hint,
                style: TextUtil.base.regular.greyA6.sp(11)),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            alignment: Alignment.centerLeft,
            child: Text('GPA', style: titleTextStyle),
          ),
          SizedBox(
            height: 75,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              elevation: 0,
              color: Color.fromRGBO(127, 139, 89, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
              child: InkWell(
                  onTap: () {
                    FavorColors.setGreenRelatedGPA();
                    setState(() {});
                  },
                  splashFactory: InkRipple.splashFactory,
                  borderRadius: BorderRadius.circular(9),
                  child: Center(
                      child: getText("#7f8b59", Colors.white, 'green', 0))),
            ),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: Color.fromRGBO(238, 237, 237, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setLightRelatedGPA();
                      changeSkin();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText("#9d7b83",
                            Color.fromRGBO(157, 123, 131, 1), 'light', 0)))),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: Color.fromRGBO(173, 141, 146, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setPinkRelatedGPA();
                      changeSkin();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText("#ad8d92",
                            Color.fromRGBO(247, 247, 248, 1), 'pink', 0)))),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: Color(0xFFA6CFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setBlueRelatedGPA();
                      changeSkin();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText("twt默认蓝", Colors.white, 'blue', 0)))),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            alignment: Alignment.centerLeft,
            child: Text(S.current.schedule, style: titleTextStyle),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: Color.fromRGBO(113, 118, 137, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setBlueRelatedSchedule();
                      changeSkin();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child:
                            getText("blue ashes", Colors.white, 'blue', 1)))),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: Color.fromRGBO(83, 89, 78, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setGreenRelatedSchedule();
                      changeSkin();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child:
                            getText("sap green", Colors.white, 'green', 1)))),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: Color.fromRGBO(196, 148, 125, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setBrownRelatedSchedule();
                      changeSkin();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText(
                            "earth yellow", Colors.white, 'brown', 1)))),
          ),
          SizedBox(
            height: 75,
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
                color: ColorUtil.aprilFoolColor[Random().nextInt(3)],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setAprilFoolSchedule();
                      CommonPreferences.isAprilFoolClass.value = true;
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText(
                            "AprilFool Color", Colors.white, 'april', 1)))),
          ),
          SizedBox(height: 40)
        ],
      ),
    );
  }
}
