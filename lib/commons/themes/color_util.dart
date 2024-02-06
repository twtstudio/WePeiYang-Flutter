import 'package:flutter/material.dart';

class ColorUtil {
  ColorUtil._();

  // Theme color

  // static final defaultActionColor = Color.fromARGB(255, 54, 60, 84);
  static final primaryBackgroundColor = Colors.white;
  static final secondaryBackgroundColor = Color.fromARGB(255, 248, 248, 248);
  static final reverseBackgroundColor = Colors.black;
  static final reverseTextColor = Colors.white;
  static final basicTextColor = Colors.black;
  static final secondaryTextColor = Color.fromARGB(255, 145, 145, 145);
  static final labelTextColor = Color(0xFF2A2A2A);
  static final unlabeledColor = Color(0xFF979797);
  static final cursorColor = Color.fromARGB(255, 48, 60, 102);
  static final infoTextColor = Color(0xFF4E4E4E);
  static final backgroundGradientEndColor = Colors.white54;
  static final secondaryInfoTextColor = Color(0xFF979797);
  static final primaryActionColor = Color(0xFF2C7EDF);
  static final primaryLightActionColor = Color(0xFFA6CFFF);
  static final primaryTextButtonColor = Color(0xFF2D4E9A);
  static final beanDarkColor = Color(0xFF80B7F9);
  static final beanLightColor = Color(0xFF2887FF);

  // schedule page background color
  static final primaryLighterActionColor = Color(0xFF81BBFF);
  static final primaryLightestActionColor = Color(0xFFC7D5EB);

  // The Color below shouldn't be customized
  static final linkBlue = Color(0xFF222F80);
  static final dangerousRed = Color(0xFFFF0000);
  static final warning = Color(0xFFFFBC6B);
  static final info = Color(0xfff0ad4e);

  // bind classes pages
  static final oldActionColor = Color.fromRGBO(53, 59, 84, 1);
  static final oldSecondaryActionColor = Color.fromRGBO(79, 88, 107, 1);
  static final oldThirdActionColor = Color.fromRGBO(98, 103, 124, 1.0);
  static final oldFurthActionColor = Color.fromRGBO(48, 60, 102, 1);
  static final oldActionRippleColor = Color.fromRGBO(103, 110, 150, 1.0);

  /* ----- this colors for setting pages ----- */
  static final oldSwitchBarColor = Color.fromRGBO(240, 241, 242, 1);
  static final oldHintColor = Color.fromRGBO(205, 206, 212, 1);
  static final oldHintDarkerColor = Color.fromRGBO(201, 204, 209, 1);
  static final oldListGroupTitleColor = Color.fromRGBO(177, 180, 186, 1);
  static final oldListActionColor = Colors.grey;

  /* ----- icon widget colors ----- */
  static final iconAnimationStartColor = Colors.black12;

  //Dislike
  static final dislikePrimary = Colors.blueGrey;
  static final dislikeSecondary = Colors.black26;

  // Like
  static final likeColor = Colors.redAccent;
  static final likeBubbleColor = Colors.pinkAccent;

  // Favor
  static final FavorColor = Colors.yellow;
  static final FavorBubbleStartColor = Colors.amber;
  static final FavorBubbleColor = Colors.amberAccent;
  static final profileBackgroundColor = Color.fromARGB(255, 67, 70, 80);

  // 还没有放到theme里面的
  static final examRemain = Colors.white38;
  static final courseGradientStartColor = Color.fromRGBO(255, 255, 255, 0.5);
  static final courseGradientStopColor = Color.fromRGBO(255, 255, 255, 0.3);
  static final tagLabelColor = Color.fromRGBO(234, 234, 234, 1);
  static final gpaHintColor = Color(0xffcdcdd3);
  static final lightBorderColor = Color(0xFFEAEAEA);
  static final roomFreeColor = Color(0xFF5CB85C);

  // 骨架屏幕渐变
  static final skeletonStartAColor = Color(0x12FFFFFF);
  static final skeletonStartBColor = Color(0x76FFFFFF);
  static final skeletonEndAColor = Color(0x32FFFFFF);
  static final skeletonEndBColor = Color(0x90FFFFFF);

  // 跳转BiliBili用的
  static final biliPink = Color(0xFFF97198);
  static final biliTextPink = Color(0xFFAE3B5E);

  //三个加载的点点

  static final blue38Color = Color(0xFF3884DE);
  static final blue15Color = Color(0xFF156ACE);
  static final blue8DColor = Color(0xFF8DBBF1);

  //Avatar chosen pink
  static final avatarChosenColor = Color(0xFFFFCCD1);

  // 地图 校历 页面的蒙版
  static final beiyangCampusMaskColor = Color(0xFFFFF2F2);

  static final unSelectedIcon = Color.fromARGB(255, 144, 144, 144);

  static final backgroundMaskColor = Color(0xB3FFFFFF);
  static final liteBackgroundMaskColor = Colors.white10;

  static final blue52hz = Color.fromRGBO(36, 43, 69, 1);

  // 负数等级的color
  static final levelNegColor = Color.fromRGBO(85, 0, 9, 1.0);

  // GPA 雷达图
  static final gpaRadiationColor = Color.fromRGBO(158, 158, 138, 0.45);
  static final gpaRadiationWaveColor = Color.fromRGBO(178, 178, 158, 0.2);
  static final gpaInsideMaskColor = Color.fromRGBO(230, 230, 230, 0.25);

  static final examAColor = Color.fromRGBO(114, 117, 136, 1);
  static final examBColor = Color.fromRGBO(143, 146, 165, 1);
  static final examCColor = Color.fromRGBO(122, 119, 138, 1);
  static final examDColor = Color.fromRGBO(142, 122, 150, 1);
  static final examEColor = Color.fromRGBO(130, 134, 161, 1);

  // 精华帖子
  static final elegantPostTagColor = Color.fromRGBO(232, 178, 27, 1.0);
  static final elegantLongPostTagColor = Color.fromRGBO(236, 120, 57, 1.0);
  static final elegantPostTagBColor = Color.fromRGBO(190, 163, 91, 1.0);
  static final elegantPostTagCColor = Color.fromRGBO(157, 129, 113, 1.0);

  // 活动帖子
  static final activityPostTagColor = Color.fromRGBO(66, 161, 225, 1.0);
  static final activityPostLongTagColor = Color.fromRGBO(57, 90, 236, 1.0);
  static final activityPostBColor = Color.fromRGBO(124, 179, 216, 1.0);
  static final activityPostTagCColor = Color.fromRGBO(72, 80, 117, 1.0);

  // 置顶帖子
  static final pinedPostTagAColor = Color.fromRGBO(223, 108, 171, 1.0);
  static final pinedPostTagBColor = Color.fromRGBO(208, 104, 160, 1.0);
  static final pinedPostTagCColor = Color.fromRGBO(134, 103, 111, 1.0);
  static final pinedPostTagDColor = Color.fromRGBO(243, 16, 73, 1.0);

  static final deletePostAColor = Color.fromRGBO(43, 16, 16, 1.0);
  static final deletePostBColor = Color.fromRGBO(42, 28, 49, 1.0);

  // this is for the schedule page
  static final errorActionColor = Color.fromRGBO(217, 83, 79, 1);
  static final scheduleOccupiedColor = Color.fromRGBO(255, 188, 107, 1);

  //
  //
  // -----还没有处理的

  //
  // ------- divider --------
  //
  static final greyShade300 = Colors.grey[300];
  static final blackOpacity01 = Colors.black.withOpacity(0.1);
  static final blackOpacity006 = Colors.black.withOpacity(0.06);
  static final blackOpacity008 = Colors.black.withOpacity(0.08);
  static final whiteb1b2Color = Color(0xffb1b2be);
  static final grey4146Color = Color(0xff414650);
  static final grey6267Color = Color(0xff62677b);
  static final greyShadow64 = Color.fromARGB(64, 236, 237, 239);
  static final greyAA = Color(0xFFAAAAAA);
  static final greyA8 = Color(0xFFA8A8A8);
  static final greyA6 = Color(0xFFA6A6A6);
  static final grey126 = Color.fromARGB(255, 126, 126, 126);
  static final greyC8 = Color(0xFFC8C8C8);
  static final blue303C = Color(0xFF303C66);
  static final blue363C = Color(0xFF363C54);
  static final black4E = Color(0xFF4E4E4E);
  static final redD9 = Color(0xFFD9534F);
  static final orange6B = Color(0xFFFFBC6B);
  static final greyB4AFColor = Color(0xFFB4AFAF);
  static final greyF7F8Color = Color(0xFFF7F7F8);

  static final primaryGradient = LinearGradient(
    colors: [
      ColorUtil.primaryActionColor,
      Color(0xFFA6CFFF),
      // 用来挡下面圆角左右的空
      ColorUtil.primaryBackgroundColor
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // 在0.7停止同理
    stops: [0, 0.53, 0.7],
  );

  static final backgroundGradient = LinearGradient(
      colors: [
        ColorUtil.primaryActionColor,
        ColorUtil.primaryLightActionColor,
        // 用来挡下面圆角左右的空
        ColorUtil.primaryBackgroundColor
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      // 在0.7停止同理
      stops: [0, 0.23, 0.4]);

  static final primaryGradientAllScreen = LinearGradient(
    colors: [
      ColorUtil.primaryActionColor,
      ColorUtil.primaryLightActionColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final gradientPrimaryBackground = LinearGradient(colors: [
    ColorUtil.primaryBackgroundColor,
    ColorUtil.primaryBackgroundColor,
  ]);

  static final List<Color> gradientGrey = [
    Color(0x2262677b),
    Color(0x8862677b),
    Color(0xff62677b),
  ];

  static final List<Color> levelColors = [
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
