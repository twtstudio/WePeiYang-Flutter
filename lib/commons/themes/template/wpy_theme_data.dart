import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/scheme/orange_scheme.dart';
import 'package:we_pei_yang_flutter/commons/themes/scheme/purple_scheme.dart';

import '../scheme/dark_scheme.dart';
import '../scheme/green_scheme.dart';
import '../scheme/light_scheme.dart';
import '../scheme/red_scheme.dart';

class WpyThemeData {
  final WpyThemeMetaData meta;
  final WpyThemeDetail data;

  WpyThemeData({
    required this.meta,
    required this.data,
  });

  static final List<WpyThemeData> brightThemeList = [
    LightScheme(),
    // DarkScheme(),
    RedScheme(),
    PurpleScheme(),
    OrangeScheme(),
    GreenScheme(),
  ];

  static final List<WpyThemeData> themeList = [
    LightScheme(),
    DarkScheme(),
    RedScheme(),
    PurpleScheme(),
    OrangeScheme(),
    GreenScheme(),
  ];

  factory WpyThemeData.light() => LightScheme();

  factory WpyThemeData.dark() => DarkScheme();
}

enum WpyThemeType {
  Official,
  Festival,
  ThirdParty;

  factory WpyThemeType.fromJson(String type) {
    switch (type) {
      case 'official':
        return WpyThemeType.Official;
      case 'festival':
        return WpyThemeType.Festival;
      case 'thirdParty':
        return WpyThemeType.ThirdParty;
      default:
        return WpyThemeType.Official;
    }
  }
}

class WpyThemeMetaData {
  final String themeId;
  final String name;
  final String description;
  final String author;
  final DateTime publishedDate;
  final DateTime lastUpdatedDate;
  final String version;
  final WpyThemeType themeType;
  final Brightness brightness;
  final String darkThemeId;
  final Color representativeColor;
  final Color hintTextColor;

  WpyThemeMetaData({
    required this.themeId,
    required this.name,
    required this.description,
    required this.author,
    required this.publishedDate,
    required this.lastUpdatedDate,
    required this.version,
    required this.themeType,
    required this.brightness,
    required this.representativeColor,
    this.darkThemeId = "builtin_dark",
    this.hintTextColor = const Color(0xFFeff4fa),
  });

  factory WpyThemeMetaData.fromJson(Map<String, dynamic> json) {
    return WpyThemeMetaData(
      themeId: json['themeId'],
      name: json['name'],
      description: json['description'],
      author: json['author'],
      publishedDate: DateTime.parse(json['publishedDate']),
      lastUpdatedDate: DateTime.parse(json['lastUpdatedDate']),
      version: json['version'],
      themeType: WpyThemeType.fromJson(json['themeType']),
      brightness:
          json['brightness'] == "light" ? Brightness.light : Brightness.dark,
      darkThemeId: json['darkThemeId'] ?? "builtin_dark",
      representativeColor: Color(int.parse(json['representativeColor'])),
    );
  }
}

typedef ColorMapper = Color Function(Color);

class WpyThemeDetail {
  final Map<WpyColorKey, dynamic> colors;
  final Map<WpyColorSetKey, dynamic> gradients;

  static final _defaultScheme = LightScheme().data;

  // Use this to  calculate the icon's color
  Color? primaryColor;

  WpyThemeDetail(
    this.colors, {
    this.primaryColor,
    Map<WpyColorSetKey, dynamic>? gradient,
  }) : this.gradients = gradient ?? {};

  Color shift(Color source, Color target) {
    final hsl = HSLColor.fromColor(source);
    final targetHsl = HSLColor.fromColor(target);

    return hsl
        .withHue(targetHsl.hue)
        .withSaturation((hsl.saturation - 0.05).clamp(0, 1))
        .toColor();
  }

  Color get(WpyColorKey key) {
    final value = this.colors[key] ?? _defaultScheme.colors[key];
    assert(value != null, 'Illegal Color key: $key');

    if (value is ColorMapper) return value(_defaultScheme.colors[key]!);

    return value!;
  }

  dynamic getColorSet(WpyColorSetKey key) {
    final value = this.gradients[key] ?? _defaultScheme.gradients[key];
    assert(value != null, 'Illegal Color key: $key');

    return value;
  }
}

enum WpyColorKey {
  defaultActionColor,
  primaryBackgroundColor,
  secondaryBackgroundColor,
  reverseBackgroundColor,
  reverseTextColor,
  brightTextColor,
  basicTextColor,
  secondaryTextColor,
  labelTextColor,
  unlabeledColor,
  cursorColor,
  infoTextColor,
  backgroundGradientEndColor,
  secondaryInfoTextColor,
  primaryActionColor,
  primaryLightActionColor,
  primaryTextButtonColor,
  beanDarkColor,
  beanLightColor,

// schedule page background color
  primaryLighterActionColor,
  primaryLightestActionColor,

// The Color below shouldn't be customized
  linkBlue,
  dangerousRed,
  warningColor,
  infoStatusColor,

// bind classes pages
  oldActionColor,
  oldSecondaryActionColor,
  oldThirdActionColor,
  oldFurthActionColor,
  oldActionRippleColor,

/* ----- this colors for setting pages ----- */
  oldSwitchBarColor,
  oldHintColor,
  oldHintDarkerColor,
  oldListGroupTitleColor,
  oldListActionColor,

/* ----- icon widget colors ----- */
  iconAnimationStartColor,

//Dislike
  dislikePrimary,
  dislikeSecondary,

// Like
  likeColor,
  likeBubbleColor,

// Favor
  FavorColor,
  FavorBubbleStartColor,
  FavorBubbleColor,
  profileBackgroundColor,
  examRemain,
  courseGradientStartColor,
  courseGradientStopColor,
  tagLabelColor,
  gpaHintColor,
  favorRoomColor,
  lightBorderColor,
  roomFreeColor,
  roomOccupiedColor,
  replySuffixColor,
  oldHintDarkestColor,

// 骨架屏幕渐变
  skeletonStartAColor,
  skeletonStartBColor,
  skeletonEndAColor,
  skeletonEndBColor,

// 跳转BiliBili用的
  biliPink,
  biliTextPink,

//三个加载的点点

  loadPointA,
  loadPointB,
  loadPointC,

//Avatar chosen pink
  avatarChosenColor,

// 地图 校历 页面的蒙版
  beiyangCampusMaskColor,
  unSelectedIcon,
  backgroundMaskColor,
  liteBackgroundMaskColor,
  blue52hz,

// 负数等级的color
  levelNegColor,

// GPA 雷达图
  gpaRadiationColor,
  gpaRadiationWaveColor,
  gpaInsideMaskColor,

// 考试页面的帖子们
  examAColor,
  examBColor,
  examCColor,
  examDColor,
  examEColor,

// 精华帖子
  elegantPostTagColor,
  elegantLongPostTagColor,
  elegantPostTagBColor,
  elegantPostTagCColor,

// 活动帖子
  activityPostTagColor,
  activityPostLongTagColor,
  activityPostBColor,
  activityPostTagCColor,

// 置顶帖子
  pinedPostTagAColor,
  pinedPostTagBColor,
  pinedPostTagCColor,
  pinedPostTagDColor,
  deletePostAColor,
  deletePostBColor,

// this is for the schedule page
  errorActionColor,
  scheduleOccupiedColor,
}

enum WpyColorSetKey {
  //level
  levelColors,

  //gradients
  primaryGradient,
  backgroundGradient,
  primaryGradientAllScreen,
  gradientPrimaryBackground,
  progressBarGradientSet,
}
