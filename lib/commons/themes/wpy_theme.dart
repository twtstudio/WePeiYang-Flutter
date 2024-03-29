import 'package:flutter/cupertino.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class WpyTheme extends InheritedWidget {
  final WpyThemeData themeData;

  WpyTheme({required super.child, required this.themeData});

  static WpyTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WpyTheme>();
  }

  static WpyTheme of(BuildContext context) {
    final WpyTheme? result = maybeOf(context);
    assert(result != null, 'No WpyTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant WpyTheme oldWidget) {
    return oldWidget.themeData.meta.themeId != themeData.meta.themeId;
  }

  Color? get primary => themeData.data.primaryColor;

  String get name => themeData.meta.name;

  String get darkThemeId => themeData.meta.darkThemeId;

  Color get(WpyColorKey key) {
    return themeData.data.get(key);
  }

  List<Color> getColorSet(WpyColorSetKey key) {
    return themeData.data.getColorSet(key) as List<Color>;
  }

  Gradient getGradient(WpyColorSetKey key) {
    return themeData.data.getColorSet(key) as Gradient;
  }

  Brightness get brightness => themeData.meta.brightness;

  static void init() {
    final themeId = CommonPreferences.appThemeId.value;
    final darkThemeId = CommonPreferences.appDarkThemeId.value;
    final brightness = CommonPreferences.usingDarkTheme.value;
    final theme = WpyThemeData.themeList.firstWhere((element) {
      return element.meta.themeId == (brightness == 0 ? themeId : darkThemeId);
    }, orElse: () => WpyThemeData.themeList[0]);
    globalTheme.value = theme;
  }
}

final globalTheme = ValueNotifier(WpyThemeData.themeList[0]);
