import 'package:flutter/cupertino.dart';
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

  Color? get getPrimary => themeData.data.primaryColor;

  Color get(WpyColorKey key) {
    return themeData.data.get(key) as Color;
  }

  List<Color> getColorSet(WpyColorKey key) {
    return themeData.data.get(key) as List<Color>;
  }

  Gradient getGradient(WpyColorSetKey key) {
    return themeData.data.getColorSet(key) as Gradient;
  }
}

final globalTheme = ValueNotifier(WpyThemeData.light());
