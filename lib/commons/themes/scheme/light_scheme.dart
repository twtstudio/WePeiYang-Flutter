import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/official_meta_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class lightScheme extends WpyThemeData {
  lightScheme()
      : super(
          meta: BuiltInThemeMetaData(
            themeId: "builtin_light",
            name: "Light Theme",
            description: "Built-in Light Theme",
          ),
          data: WpyThemeDetail(
            lightSchemeDetail,
            gradient: colorSetsList,
          ),
        );
}

final Map<WpyColorKey, Color> lightSchemeDetail = {
  WpyColorKey.defaultActionColor: Color.fromARGB(255, 54, 60, 84),
  WpyColorKey.primaryBackgroundColor: Colors.white,
  WpyColorKey.secondaryBackgroundColor: Color.fromARGB(255, 248, 248, 248),
  WpyColorKey.reverseBackgroundColor: Colors.black,

  WpyColorKey.reverseTextColor: Colors.white,
  WpyColorKey.basicTextColor: Colors.black,
  WpyColorKey.secondaryTextColor: Color.fromARGB(255, 145, 145, 145),
  WpyColorKey.labelTextColor: Color(0xFF2A2A2A),
  WpyColorKey.unlabeledColor: Color(0xFF979797),
  WpyColorKey.cursorColor: Color.fromARGB(255, 48, 60, 102),
  WpyColorKey.infoTextColor: Color(0xFF4E4E4E),
  WpyColorKey.backgroundGradientEndColor: Colors.white54,
  WpyColorKey.secondaryInfoTextColor: Color(0xFF979797),

  WpyColorKey.primaryActionColor: Color(0xFF2C7EDF),
  WpyColorKey.primaryLightActionColor: Color(0xFFA6CFFF),
  WpyColorKey.primaryTextButtonColor: Color(0xFF2D4E9A),

  // the Main Action on main page
  WpyColorKey.beanDarkColor: Color(0xFF80B7F9),
  WpyColorKey.beanLightColor: Color(0xFF2887FF),

// schedule page background color
  WpyColorKey.primaryLighterActionColor: Color(0xFF81BBFF),
  WpyColorKey.primaryLightestActionColor: Color(0xFFC7D5EB),

// --- The Color below shouldn't be customized ---
  WpyColorKey.linkBlue: Color(0xFF222F80),
  WpyColorKey.dangerousRed: Color(0xFFFF0000),
  WpyColorKey.warningColor: Color(0xFFFFBC6B),
  WpyColorKey.infoStatusColor: Color(0xfff0ad4e),

// bind classes pages
  WpyColorKey.oldActionColor: Color.fromRGBO(53, 59, 84, 1),
  WpyColorKey.oldSecondaryActionColor: Color.fromRGBO(79, 88, 107, 1),
  WpyColorKey.oldThirdActionColor: Color.fromRGBO(98, 103, 124, 1.0),
  WpyColorKey.oldFurthActionColor: Color.fromRGBO(48, 60, 102, 1),
  WpyColorKey.oldActionRippleColor: Color.fromRGBO(103, 110, 150, 1.0),

/* ----- this colors for setting pages ----- */
  WpyColorKey.oldSwitchBarColor: Color.fromRGBO(240, 241, 242, 1),
  WpyColorKey.oldHintColor: Color.fromRGBO(205, 206, 212, 1),
  WpyColorKey.oldHintDarkerColor: Color.fromRGBO(201, 204, 209, 1),
  WpyColorKey.oldListGroupTitleColor: Color.fromRGBO(177, 180, 186, 1),
  WpyColorKey.oldListActionColor: Colors.grey,

/* ----- icon widget colors ----- */
  WpyColorKey.iconAnimationStartColor: Colors.black12,

//Dislike
  WpyColorKey.dislikePrimary: Colors.blueGrey,
  WpyColorKey.dislikeSecondary: Colors.black26,

// Like
  WpyColorKey.likeColor: Colors.redAccent,
  WpyColorKey.likeBubbleColor: Colors.pinkAccent,

// Favor
  WpyColorKey.FavorColor: Colors.yellow,
  WpyColorKey.FavorBubbleStartColor: Colors.amber,
  WpyColorKey.FavorBubbleColor: Colors.amberAccent,

  WpyColorKey.profileBackgroundColor: Color.fromARGB(255, 67, 70, 80),
};

final colorSetsList = {
//level
  WpyColorSetKey.levelColors: [
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
  ],

// gradient

  WpyColorSetKey.primaryGradient: LinearGradient(
    colors: [
      lightSchemeDetail[WpyColorKey.primaryActionColor]!,
      lightSchemeDetail[WpyColorKey.primaryLightActionColor]!,
// 用来挡下面圆角左右的空
      lightSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
// 在0.7停止同理
    stops: [0, 0.53, 0.7],
  ),

  WpyColorSetKey.backgroundGradient: LinearGradient(
    colors: [
      lightSchemeDetail[WpyColorKey.primaryActionColor]!,
      lightSchemeDetail[WpyColorKey.primaryLightActionColor]!,
// 用来挡下面圆角左右的空
      lightSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
// 在0.7停止同理
    stops: [0, 0.23, 0.4],
  ),

  WpyColorSetKey.primaryGradientAllScreen: LinearGradient(
    colors: [
      lightSchemeDetail[WpyColorKey.primaryActionColor]!,
      lightSchemeDetail[WpyColorKey.primaryLightActionColor]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),

  WpyColorSetKey.gradientPrimaryBackground: LinearGradient(colors: [
    lightSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
    lightSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
  ]),

  WpyColorSetKey.progressBarGradientSet: [
    Color(0x2262677b),
    Color(0x8862677b),
    Color(0xff62677b),
  ]
};
