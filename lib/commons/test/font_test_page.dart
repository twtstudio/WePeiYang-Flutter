// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';

class FontTestPage extends StatelessWidget {
  const FontTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("字体测试页面"),
      ),
      body: ListView(
        children: [
          TextButton(
              onPressed: () {
                WbyFontLoader.initFonts();
              },
              child: Text("点击下载字体")),
          fontTest(),
        ],
      ),
    );
  }

  Column fontTest() {
    return Column(
      children: [
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w100,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w200,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          "个人信息更改",
          style: TextStyle(
            fontFamily: WbyFontLoader.NotoSerifSC,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
