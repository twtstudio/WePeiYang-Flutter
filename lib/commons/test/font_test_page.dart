// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';

class FontTestPage extends StatelessWidget {
  const FontTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  WbyFontLoader.initFonts();
                },
                child: Text("点击下载字体")),
            ...fontTests,
          ],
        ),
      ),
    );
  }
  static const type1 = 'PingFangSC';
  static const type2 = 'NotoSansSC';

  List<Widget> get fontTests {
    return [
      Text(
        "个人信息更改w100",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w100,
        ),
      ),
      Text(
        "个人信息更改w200",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w200,
        ),
      ),
      Text(
        "个人信息更改w300",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w300,
        ),
      ),
      Text(
        "个人信息更改w400",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w400,
        ),
      ),
      Text(
        "个人信息更改w500",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        "个人信息更改w600",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        "个人信息更改w700",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        "个人信息更改w800",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        "个人信息更改w900",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        "个人信息更改w900",
        style: TextStyle(
          fontFamily: type1,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        "ABCDEFGabcdefg-w500-normal",
        style: TextStyle(
          fontFamily: type2,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
        ),
      ),
      Text(
        "ABCDEFGabcdefg-w500-italic",
        style: TextStyle(
          fontFamily: type2,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
      ),
      Text(
        "ABCDEFGabcdefg-w900-normal",
        style: TextStyle(
          fontFamily: type2,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.normal,
        ),
      ),
      Text(
        "ABCDEFGabcdefg-w900-italic",
        style: TextStyle(
          fontFamily: type2,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }
}
