import 'dart:ui';

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

abstract class WpyColorAbstract {}

class WpyColor extends WpyColorAbstract {
  final Color value;

  WpyColor(this.value);
}

class WpyGradient extends WpyColorAbstract {
  final List<Color> value;

  WpyGradient(this.value);
}

class WpyThemeDetail {
  final Map<String, WpyColorAbstract> _details;
  static final Map<String, WpyColorAbstract> _defaultScheme =
      LightScheme().data.details;

  WpyThemeDetail(this._details);

  get details => _details;

  WpyColorAbstract get(String key) {
    final value = this._details[key] ?? _defaultScheme[key];
    assert(value != null, 'Illegal Color key: $key');
    return value!;
  }
}

class WpyThemeData {
  final WpyThemeMetaData meta;
  final WpyThemeDetail data;

  WpyThemeData({
    required this.meta,
    required this.data,
  });
}
