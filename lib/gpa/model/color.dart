import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

import '../../commons/themes/wpy_theme.dart';

class GPAColor {
  static List<Color> blue(context) => [
        WpyTheme.of(context).get(WpyThemeKeys.primaryActionColor),
        WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        WpyTheme.of(context).get(WpyThemeKeys.primaryLightActionColor),
        WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
      ];
}
