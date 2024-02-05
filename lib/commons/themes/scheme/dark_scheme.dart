import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/official_meta_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class DarkScheme extends WpyThemeData {
  DarkScheme()
      : super(
          meta: BuiltInThemeMetaData(
            themeId: "builtin_light",
            name: "Light Theme",
            description: "Built-in Light Theme",
          ),
          data: WpyThemeDetail(darkSchemeDetail),
        );
}

const darkSchemeDetail = <WpyThemeKeys, dynamic>{
  WpyThemeKeys.defaultActionColor: Color.fromARGB(255, 54, 60, 84),
  WpyThemeKeys.primaryBackgroundColor: Colors.white,
  WpyThemeKeys.secondaryBackgroundColor: Color.fromARGB(255, 248, 248, 248),
  WpyThemeKeys.reverseBackgroundColor: Colors.black,

  WpyThemeKeys.reverseTextColor: Colors.white,
  WpyThemeKeys.basicTextColor: Colors.black,
  WpyThemeKeys.secondaryTextColor: Color.fromARGB(255, 145, 145, 145),
  WpyThemeKeys.labelTextColor: Color(0xFF2A2A2A),
  WpyThemeKeys.unlabeledColor: Color(0xFF979797),
  WpyThemeKeys.cursorColor: Color.fromARGB(255, 48, 60, 102),
  WpyThemeKeys.infoTextColor: Color(0xFF4E4E4E),
  WpyThemeKeys.backgroundGradientEndColor: Colors.white54,
  WpyThemeKeys.secondaryInfoTextColor: Color(0xFF979797),

  WpyThemeKeys.primaryActionColor: Color(0xFF2C7EDF),
  WpyThemeKeys.primaryLightActionColor: Color(0xFFA6CFFF),
  WpyThemeKeys.primaryTextButtonColor: Color(0xFF2D4E9A),
  WpyThemeKeys.beanDarkColor: Color(0xFF80B7F9),
  WpyThemeKeys.beanLightColor: Color(0xFF2887FF),

// schedule page background color
  WpyThemeKeys.primaryLighterActionColor: Color(0xFF81BBFF),
  WpyThemeKeys.primaryLightestActionColor: Color(0xFFC7D5EB),

// The Color below shouldn't be customized
  WpyThemeKeys.linkBlue: Color(0xFF222F80),
  WpyThemeKeys.dangerousRed: Color(0xFFFF0000),
  WpyThemeKeys.warningColor: Color(0xFFFFBC6B),
  WpyThemeKeys.infoStatusColor: Color(0xfff0ad4e),

// bind classes pages
  WpyThemeKeys.oldActionColor: Color.fromRGBO(53, 59, 84, 1),
  WpyThemeKeys.oldSecondaryActionColor: Color.fromRGBO(79, 88, 107, 1),
  WpyThemeKeys.oldThirdActionColor: Color.fromRGBO(98, 103, 124, 1.0),
  WpyThemeKeys.oldFurthActionColor: Color.fromRGBO(48, 60, 102, 1),
  WpyThemeKeys.oldActionRippleColor: Color.fromRGBO(103, 110, 150, 1.0),

/* ----- this colors for setting pages ----- */
  WpyThemeKeys.oldSwitchBarColor: Color.fromRGBO(240, 241, 242, 1),
  WpyThemeKeys.oldHintColor: Color.fromRGBO(205, 206, 212, 1),
  WpyThemeKeys.oldHintDarkerColor: Color.fromRGBO(201, 204, 209, 1),
  WpyThemeKeys.oldListGroupTitleColor: Color.fromRGBO(177, 180, 186, 1),
  WpyThemeKeys.oldListActionColor: Colors.grey,

/* ----- icon widget colors ----- */
  WpyThemeKeys.iconAnimationStartColor: Colors.black12,

//Dislike
  WpyThemeKeys.dislikePrimary: Colors.blueGrey,
  WpyThemeKeys.dislikeSecondary: Colors.black26,

// Like
  WpyThemeKeys.likeColor: Colors.redAccent,
  WpyThemeKeys.likeBubbleColor: Colors.pinkAccent,

// Favor
  WpyThemeKeys.FavorColor: Colors.yellow,
  WpyThemeKeys.FavorBubbleStartColor: Colors.amber,
  WpyThemeKeys.FavorBubbleColor: Colors.amberAccent,
};
