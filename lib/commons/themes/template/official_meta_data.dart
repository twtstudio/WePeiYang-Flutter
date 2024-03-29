import 'dart:ui';

import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class BuiltInThemeMetaData extends WpyThemeMetaData {
  BuiltInThemeMetaData({
    required super.themeId,
    required super.name,
    required super.description,
    required Brightness brightness,
    required super.representativeColor,
    super.darkThemeId,
    super.hintTextColor,
  }) : super(
          author: "TWT Studio",
          version: "Built-in Theme",
          publishedDate: DateTime.parse("2000-06-08"),
          lastUpdatedDate: DateTime.parse("2000-06-08"),
          themeType: WpyThemeType.Official,
          brightness: brightness,
        );
}
