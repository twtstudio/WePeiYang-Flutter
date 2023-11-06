import 'package:flutter/material.dart';

class ColorUtil {
  ColorUtil._();

  static const mainColor = Color.fromARGB(255, 54, 60, 84);
  static const backgroundColor = Color.fromARGB(255, 248, 248, 248);
  static const searchBarBackgroundColor = Color.fromARGB(255, 236, 237, 239);
  static const boldTextColor = Color.fromARGB(255, 48, 60, 102);
  static const lightTextColor = Color.fromARGB(255, 145, 145, 145);
  static const whiteFFColor = Color.fromARGB(255, 255, 255, 255);
  static const white210 = Color.fromRGBO(210, 210, 210, 1);
  static const white212 = Color.fromRGBO(212, 214, 226, 1);
  static const white222 = Color(0xffdedede);
  static const white235 = Color.fromRGBO(235, 238, 243, 1);
  static const white237 = Color.fromRGBO(237, 240, 244, 1);
  static const white240 = Color.fromRGBO(240, 241, 242, 1);
  static const white250 = Color.fromRGBO(250, 250, 250, 1);
  static const white251 = Color.fromRGBO(251, 251, 251, 1);
  static const whiteEEColor = Color(0xFFEEEEEE);
  static const whiteF2Color = Color(0xfff2f2f2);
  static const black00Color = Color.fromARGB(255, 0, 0, 0);
  static const profileBackgroundColor = Color.fromARGB(255, 67, 70, 80);
  static const grey108 = Color.fromARGB(255, 108, 108, 108);
  static const bold42TextColor = Color.fromARGB(255, 42, 42, 42);
  static const boldTag54 = Color.fromARGB(255, 54, 60, 84);
  static const whiteFDFE = Color.fromARGB(255, 253, 253, 254);
  static const grey97Color = Color(0xFF979797);
  static const greyEAColor = Color(0xFFEAEAEA);
  static const green5CColor = Color(0xFF5CB85C);
  static const black2AColor = Color(0xFF2A2A2A);
  static const black25Color = Color(0XFF252525);
  static const whiteF8Color = Color(0xFFF7F7F8);
  static const greyCAColor = Color(0xFFCACACA);
  static const selectionButtonColor = Color(0xFF2D4E9A);
  static const blue2CColor = Color(0xFF2C7EDF);//44,126,223
  static const blue28Color = Color(0xFF2887FF);
  static const blue38Color = Color(0xFF3884DE);
  static const blue15Color = Color(0xFF156ACE);
  static const blue8DColor = Color(0xFF8DBBF1);
  static const blue80Color = Color(0xFF80B7F9);
  static const blueA6Color = Color(0xFFA6CFFF);
  static const blueBEColor = Color(0xFFBED1FF);
  static const blue3A3BColor = Color.fromRGBO(58, 59, 69, 1.0);
  static const biliPink = Color(0xFFF97198);
  static const begoniaPink = Color(0xFFFFCCD1);
  static const mapRed = Color(0xFFFFF2F2);
  static const warning = Color(0xFFFFBC6B);
  static const yellowF0 = Color(0xfff0ad4e);
  static const grey144 = Color.fromARGB(255, 144, 144, 144);
  static const white70 = Color(0xB3FFFFFF);
  static const blue52hz = Color.fromRGBO(36, 43, 69, 1);
  static const red = Colors.red;
  static const red85 = Color.fromRGBO(85, 0, 9, 1.0);
  static const black26 = Colors.black26;
  static const black12 = Colors.black12;
  static const black19 = Color(0x19000000);
  static const whiteOpacity01 = Color.fromRGBO(255, 255, 255, 0.1);
  static const whiteOpacity04 = Color.fromRGBO(255, 255, 255, 0.4);
  static const blackOpacity005 = Color.fromARGB(13, 00, 00, 00);
  static const grey177 = Color.fromRGBO(177, 180, 186, 1);
  static const grey172 = Color.fromRGBO(172, 174, 186, 1);
  static const grey = Colors.grey;
  static const blue98122 = Color.fromRGBO(98, 103, 122, 1.0);
  static const blue98 = Color.fromRGBO(98, 103, 124, 1.0);
  static const blue105 = Color.fromRGBO(105, 109, 127, 1);
  static const blue177 = Color.fromRGBO(177, 175, 227, 1.0);
  static const blue103 = Color.fromRGBO(103, 110, 150, 1.0);
  static const blue79 = Color.fromRGBO(79, 88, 107, 1);
  static const blue53 = Color.fromRGBO(53, 59, 84, 1);
  static const blue48 = Color.fromRGBO(48, 60, 102, 1);
  static const transparent = Colors.transparent;
  static const hintWhite201 = Color.fromRGBO(201, 204, 209, 1);
  static const hintWhite205 = Color.fromRGBO(205, 206, 212, 1);
  static final greyShade300 = Colors.grey[300];
  static final whiteb1b2Color = Color(0xffb1b2be);
  static final grey4146Color = Color(0xff414650);
  static final grey6267Color = Color(0xff62677b);
  static final greyShadow64 = Color.fromARGB(64, 236, 237, 239);
  static final amber = Colors.amber;

  static const gradientBlue = LinearGradient(
    colors: [
      Color(0xFF2C7EDF),
      Color(0xFFA6CFFF),
      // 用来挡下面圆角左右的空
      Colors.white
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // 在0.7停止同理
    stops: [0, 0.53, 0.7],
  );

  static const gradientBlueAllScreen = LinearGradient(
    colors: [
      Color(0xFF2C7EDF),
      Color(0xFFA6CFFF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientWhite =
      LinearGradient(colors: [Colors.white, Colors.white]);
  static const List<Color> aprilFoolColor = [
    Color(0xFFF1B53B),
    Color(0xF033BB8F),
    Color(0xF0E1403A),
    Color(0xFF5B96F2),
    Color(0xFF6A63E1)
  ];

  static const List<Color> gradientGrey=[
    Color(0x2262677b),
    Color(0x8862677b),
    Color(0xff62677b),
  ];


  static const List<Color> rainbowColors = [
    Color.fromRGBO(94, 192, 91, 1),
    Color.fromRGBO(91, 150, 222, 1),
    Color.fromRGBO(159, 105, 237, 1),
    Color.fromRGBO(255, 135, 178, 1),
    Color.fromRGBO(248, 190, 25, 1),
    Color.fromRGBO(32, 91, 78, 1),
    Color.fromRGBO(76, 77, 113, 1),
    Color.fromRGBO(54, 27, 107, 1),
    Color.fromRGBO(130, 20, 57, 1),
    Color.fromRGBO(247, 117, 17, 1),
  ];
}
