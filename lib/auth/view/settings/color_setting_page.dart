import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
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
        style: FontManager.Aspira.copyWith(
            color: color, fontSize: 14, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    var titleTextStyle = FontManager.YaHeiBold.copyWith(
        fontSize: 14,
        color: Color.fromRGBO(177, 180, 186, 1),
        fontWeight: FontWeight.bold);
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
                style: FontManager.YaQiHei.copyWith(
                    color: Color.fromRGBO(48, 60, 102, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 28)),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(35, 20, 35, 20),
            alignment: Alignment.centerLeft,
            child: Text(S.current.setting_color_hint,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Colors.grey, fontSize: 11)),
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
                color: Color.fromRGBO(71, 83, 95, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                child: InkWell(
                    onTap: () {
                      FavorColors.setBlueRelatedGPA();
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText("#47535f",
                            Color.fromRGBO(206, 198, 185, 1), 'blue', 0)))),
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
                      setState(() {});
                    },
                    splashFactory: InkRipple.splashFactory,
                    borderRadius: BorderRadius.circular(9),
                    child: Center(
                        child: getText(
                            "earth yellow", Colors.white, 'brown', 1)))),
          ),
          SizedBox(height: 40)
        ],
      ),
    );
  }
}
