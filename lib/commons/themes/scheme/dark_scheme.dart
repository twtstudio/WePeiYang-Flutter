import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/official_meta_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class DarkScheme extends WpyThemeData {
  DarkScheme()
      : super(
          meta: BuiltInThemeMetaData(
            themeId: "builtin_dark",
            name: "Dark Theme",
            description: "Built-in Dark Theme",
            brightness: Brightness.dark,
          ),
          data: WpyThemeDetail(
            darkSchemeDetail,
            gradient: colorSetsList,
          ),
        );
}

final Map<WpyColorKey, Color> darkSchemeDetail = {
  WpyColorKey.defaultActionColor: Color.fromARGB(255, 143, 156, 206),
  WpyColorKey.primaryBackgroundColor: Color.fromARGB(255, 16, 16, 16),
  WpyColorKey.secondaryBackgroundColor: Color.fromARGB(255, 0, 0, 0),
  WpyColorKey.reverseBackgroundColor: Colors.black,

  WpyColorKey.reverseTextColor: Color.fromARGB(255, 66, 66, 66),
  WpyColorKey.brightTextColor: Color(0xFFCACACA),
  WpyColorKey.basicTextColor: Color.fromARGB(255, 202, 202, 202),
  WpyColorKey.secondaryTextColor: Color.fromARGB(255, 154, 154, 154),
  WpyColorKey.labelTextColor: Color(0xFFC1C1C1),
  WpyColorKey.unlabeledColor: Color(0xFFC5C5C5),
  WpyColorKey.cursorColor: Color.fromARGB(255, 85, 112, 188),
  WpyColorKey.infoTextColor: Color(0xFFAAAAAA),
  WpyColorKey.backgroundGradientEndColor: Colors.white54,
  WpyColorKey.secondaryInfoTextColor: Color(0xFF979797),

  WpyColorKey.primaryActionColor: Color(0xFF52729B),
  WpyColorKey.primaryLightActionColor: Color(0xFF12233B),
  WpyColorKey.primaryTextButtonColor: Color(0xFF4B77D5),

  // the Main Action on main page
  WpyColorKey.beanDarkColor: Color(0xFF3687E5),
  WpyColorKey.beanLightColor: Color(0xFF4B81C7),

// schedule page background color
  WpyColorKey.primaryLighterActionColor: Color(0xFF183C50),
  WpyColorKey.primaryLightestActionColor: Color(0x7B647BB6),

// --- The Color below shouldn't be customized ---
  WpyColorKey.linkBlue: Color(0xFF5A69D2),
  WpyColorKey.dangerousRed: Color(0xFF7E0303),
  WpyColorKey.warningColor: Color(0xFF9B7342),
  WpyColorKey.infoStatusColor: Color(0xffa37636),

// bind classes pages
  WpyColorKey.oldActionColor: Color.fromRGBO(155, 166, 212, 1.0),
  WpyColorKey.oldSecondaryActionColor: Color.fromRGBO(148, 167, 206, 1.0),
  WpyColorKey.oldThirdActionColor: Color.fromRGBO(163, 173, 207, 1.0),
  WpyColorKey.oldFurthActionColor: Color.fromRGBO(106, 120, 157, 1.0),
  WpyColorKey.oldActionRippleColor: Color.fromRGBO(144, 153, 208, 1.0),

/* ----- this colors for setting pages ----- */
  WpyColorKey.oldSwitchBarColor: Color.fromRGBO(48, 48, 48, 1.0),
  WpyColorKey.oldHintColor: Color.fromRGBO(194, 183, 183, 1.0),
  WpyColorKey.oldHintDarkerColor: Color.fromRGBO(224, 220, 220, 1.0),
  WpyColorKey.oldListGroupTitleColor: Color.fromRGBO(83, 76, 76, 1.0),
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

  WpyColorKey.examRemain: Colors.white38,
  WpyColorKey.courseGradientStartColor: Color.fromRGBO(0, 0, 0, 0.50),
  WpyColorKey.courseGradientStopColor: Color.fromRGBO(79, 79, 79, 0.30),
  WpyColorKey.tagLabelColor: Color.fromRGBO(66, 66, 66, 1.0),
  WpyColorKey.gpaHintColor: Color(0xffcdcdd3),
  WpyColorKey.favorRoomColor: Color(0xFFFFBC6B),
  WpyColorKey.lightBorderColor: Color(0xFF222222),
  WpyColorKey.roomFreeColor: Color(0xFF3A733A),
  WpyColorKey.roomOccupiedColor: Color(0xFF9C3D39),
  WpyColorKey.replySuffixColor: Color(0xFFAAAAAA),
  WpyColorKey.oldHintDarkestColor: Color(0xffb1b2be),

// 骨架屏幕渐变
  WpyColorKey.skeletonStartAColor: Color(0x12000000),
  WpyColorKey.skeletonStartBColor: Color(0x76191919),
  WpyColorKey.skeletonEndAColor: Color(0x32363636),
  WpyColorKey.skeletonEndBColor: Color(0x901B1B1B),

// 跳转BiliBili用的
  WpyColorKey.biliPink: Color(0xFFF97198),
  WpyColorKey.biliTextPink: Color(0xFFAE3B5E),

//三个加载的点点

  WpyColorKey.loadPointA: Color(0xFF214E84),
  WpyColorKey.loadPointB: Color(0xFF0D4280),
  WpyColorKey.loadPointC: Color(0xFF485F7A),

//Avatar chosen pink
  WpyColorKey.avatarChosenColor: Color(0xFFFFCCD1),

// 地图 校历 页面的蒙版
  WpyColorKey.beiyangCampusMaskColor: Color(0xFFFFF2F2),
  WpyColorKey.unSelectedIcon: Color.fromARGB(255, 144, 144, 144),
  WpyColorKey.backgroundMaskColor: Color(0xB3FFFFFF),
  WpyColorKey.liteBackgroundMaskColor: Color(0xC8C8C8),

  WpyColorKey.blue52hz: Color.fromRGBO(36, 43, 69, 1),

// 负数等级的color
  WpyColorKey.levelNegColor: Color.fromRGBO(85, 0, 9, 1.0),

// GPA 雷达图
  WpyColorKey.gpaRadiationColor: Color.fromRGBO(158, 158, 138, 0.45),
  WpyColorKey.gpaRadiationWaveColor: Color.fromRGBO(178, 178, 158, 0.2),
  WpyColorKey.gpaInsideMaskColor: Color.fromRGBO(230, 230, 230, 0.25),

// 考试页面的帖子们
  WpyColorKey.examAColor: Color.fromRGBO(114, 117, 136, 1),
  WpyColorKey.examBColor: Color.fromRGBO(143, 146, 165, 1),
  WpyColorKey.examCColor: Color.fromRGBO(122, 119, 138, 1),
  WpyColorKey.examDColor: Color.fromRGBO(142, 122, 150, 1),
  WpyColorKey.examEColor: Color.fromRGBO(130, 134, 161, 1),

// 精华帖子
  WpyColorKey.elegantPostTagColor: Color.fromRGBO(232, 178, 27, 1.0),
  WpyColorKey.elegantLongPostTagColor: Color.fromRGBO(236, 120, 57, 1.0),
  WpyColorKey.elegantPostTagBColor: Color.fromRGBO(190, 163, 91, 1.0),
  WpyColorKey.elegantPostTagCColor: Color.fromRGBO(157, 129, 113, 1.0),

// 活动帖子
  WpyColorKey.activityPostTagColor: Color.fromRGBO(66, 161, 225, 1.0),
  WpyColorKey.activityPostLongTagColor: Color.fromRGBO(57, 90, 236, 1.0),
  WpyColorKey.activityPostBColor: Color.fromRGBO(124, 179, 216, 1.0),
  WpyColorKey.activityPostTagCColor: Color.fromRGBO(72, 80, 117, 1.0),

// 置顶帖子
  WpyColorKey.pinedPostTagAColor: Color.fromRGBO(223, 108, 171, 1.0),
  WpyColorKey.pinedPostTagBColor: Color.fromRGBO(208, 104, 160, 1.0),
  WpyColorKey.pinedPostTagCColor: Color.fromRGBO(134, 103, 111, 1.0),
  WpyColorKey.pinedPostTagDColor: Color.fromRGBO(243, 16, 73, 1.0),

  WpyColorKey.deletePostAColor: Color.fromRGBO(43, 16, 16, 1.0),
  WpyColorKey.deletePostBColor: Color.fromRGBO(42, 28, 49, 1.0),

// this is for the schedule page
  WpyColorKey.errorActionColor: Color.fromRGBO(217, 83, 79, 1),
  WpyColorKey.scheduleOccupiedColor: Color.fromRGBO(255, 188, 107, 1),
};

final colorSetsList = {
//level
  WpyColorSetKey.levelColors: [
    Color.fromRGBO(61, 123, 59, 1.0),
    Color.fromRGBO(52, 86, 127, 1.0),
    Color.fromRGBO(92, 61, 135, 1.0),
    Color.fromRGBO(165, 88, 116, 1.0),
    Color.fromRGBO(143, 110, 15, 1.0),
    Color.fromRGBO(22, 60, 52, 1.0),
    Color.fromRGBO(60, 61, 89, 1.0),
    Color.fromRGBO(54, 27, 107, 1),
    Color.fromRGBO(92, 15, 41, 1.0),
    Color.fromRGBO(147, 70, 11, 1.0),
  ],

// gradient

  WpyColorSetKey.primaryGradient: LinearGradient(
    colors: [
      darkSchemeDetail[WpyColorKey.primaryActionColor]!,
      darkSchemeDetail[WpyColorKey.primaryLightActionColor]!,
// 用来挡下面圆角左右的空
      darkSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
// 在0.7停止同理
    stops: [0, 0.53, 0.7],
  ),

  WpyColorSetKey.backgroundGradient: LinearGradient(
    colors: [
      darkSchemeDetail[WpyColorKey.primaryActionColor]!,
      darkSchemeDetail[WpyColorKey.primaryLightActionColor]!,
// 用来挡下面圆角左右的空
      darkSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
// 在0.7停止同理
    stops: [0, 0.23, 0.4],
  ),

  WpyColorSetKey.primaryGradientAllScreen: LinearGradient(
    colors: [
      darkSchemeDetail[WpyColorKey.primaryActionColor]!,
      darkSchemeDetail[WpyColorKey.primaryLightActionColor]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),

  WpyColorSetKey.gradientPrimaryBackground: LinearGradient(colors: [
    darkSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
    darkSchemeDetail[WpyColorKey.primaryBackgroundColor]!,
  ]),

  WpyColorSetKey.progressBarGradientSet: [
    Color(0x2262677b),
    Color(0x8862677b),
    Color(0xff62677b),
  ]
};
