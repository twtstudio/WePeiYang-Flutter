import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/scheme/light_scheme.dart';

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

  WpyThemeMetaData({
    required this.themeId,
    required this.name,
    required this.description,
    required this.author,
    required this.publishedDate,
    required this.lastUpdatedDate,
    required this.version,
    required this.themeType,
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
    );
  }
}

extension ColorAlgorithm on Color {}

class WpyThemeData {
  final WpyThemeMetaData meta;
  final WpyThemeDetail data;

  WpyThemeData({
    required this.meta,
    required this.data,
  });

  factory WpyThemeData.light() => light_scheme();

  factory WpyThemeData.dark() => light_scheme();
}

class WpyThemeDetail {
  final Map<WpyThemeKeys, dynamic> details;
  static final Map<WpyThemeKeys, dynamic> _defaultScheme =
      light_scheme().data.details;

  // Use this to  calculate the icon's color
  Color? primaryColor;

  WpyThemeDetail(this.details, {this.primaryColor});

  Color shift(Color source, Color target) {
    final hsl = HSLColor.fromColor(source);
    final targetHsl = HSLColor.fromColor(target);

    return hsl
        .withHue(targetHsl.hue)
        .withSaturation((hsl.saturation - 0.05).clamp(0, 1))
        .toColor();
  }

  dynamic get(WpyThemeKeys key) {
    final value = this.details[key] ?? _defaultScheme[key];
    assert(value != null, 'Illegal Color key: $key');

    return value;
  }
}

enum WpyThemeKeys {
  defaultActionColor,
  primaryBackgroundColor,
  secondaryBackgroundColor,
  reverseBackgroundColor,
  reverseTextColor,
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

  // Level
  levelColors,
}
