import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/official_meta_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class LightScheme extends WpyThemeData {
  LightScheme()
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

  WpyColorKey.examRemain: Colors.white38,
  WpyColorKey.courseGradientStartColor: Color.fromRGBO(255, 255, 255, 0.5),
  WpyColorKey.courseGradientStopColor: Color.fromRGBO(255, 255, 255, 0.3),
  WpyColorKey.tagLabelColor: Color.fromRGBO(234, 234, 234, 1),
  WpyColorKey.gpaHintColor: Color(0xffcdcdd3),
  WpyColorKey.favorRoomColor: Color(0xFFFFBC6B),
  WpyColorKey.lightBorderColor: Color(0xFFEAEAEA),
  WpyColorKey.roomFreeColor: Color(0xFF5CB85C),
  WpyColorKey.roomOccupiedColor: Color(0xFFD9534F),
  WpyColorKey.replySuffixColor: Color(0xFFAAAAAA),
  WpyColorKey.oldHintDarkestColor: Color(0xffb1b2be),

// 骨架屏幕渐变
  WpyColorKey.skeletonStartAColor: Color(0x12FFFFFF),
  WpyColorKey.skeletonStartBColor: Color(0x76FFFFFF),
  WpyColorKey.skeletonEndAColor: Color(0x32FFFFFF),
  WpyColorKey.skeletonEndBColor: Color(0x90FFFFFF),

// 跳转BiliBili用的
  WpyColorKey.biliPink: Color(0xFFF97198),
  WpyColorKey.biliTextPink: Color(0xFFAE3B5E),

//三个加载的点点

  WpyColorKey.loadPointA: Color(0xFF3884DE),
  WpyColorKey.loadPointB: Color(0xFF156ACE),
  WpyColorKey.loadPointC: Color(0xFF8DBBF1),

//Avatar chosen pink
  WpyColorKey.avatarChosenColor: Color(0xFFFFCCD1),

// 地图 校历 页面的蒙版
  WpyColorKey.beiyangCampusMaskColor: Color(0xFFFFF2F2),
  WpyColorKey.unSelectedIcon: Color.fromARGB(255, 144, 144, 144),
  WpyColorKey.backgroundMaskColor: Color(0xB3FFFFFF),
  WpyColorKey.liteBackgroundMaskColor: Colors.white10,

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
