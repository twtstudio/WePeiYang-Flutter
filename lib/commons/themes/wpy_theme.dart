import 'package:flutter/cupertino.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class WpyTheme extends InheritedWidget {
  final WpyThemeData theme;

  WpyTheme(this.theme, {required super.child});

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
    return oldWidget.theme.meta.themeId != theme.meta.themeId;
  }
}
