import 'dart:math';

import 'package:flutter/material.dart';

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

class ThemeChangePage extends StatefulWidget {
  @override
  _ThemeChangePageState createState() => _ThemeChangePageState();
}

class _ThemeChangePageState extends State<ThemeChangePage> {
  var pref = CommonPreferences();

  Widget ThemeCard() {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.fromLTRB(14, 12, 14, 2),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset('assets/images/lake_butt_icons/haitang_banner.png',
                    fit: BoxFit.fitWidth),
                Positioned(bottom: 4, right: 8, child: TextPod('海棠节·活动')),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('主题皮肤',
                style: FontManager.YaHeiRegular.copyWith(
                    fontSize: 16,
                    color: Color.fromRGBO(36, 43, 69, 1),
                    fontWeight: FontWeight.bold)),
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
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return ThemeCard();
          },
        ));
  }
}
