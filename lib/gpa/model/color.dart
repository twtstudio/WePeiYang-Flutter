import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

import '../../commons/themes/wpy_theme.dart';

class GPAColor {
  static List<Color> blue(context) => [
        WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
        WpyTheme.of(context).get(WpyColorKey.reverseTextColor),
        WpyTheme.of(context).get(WpyColorKey.primaryLightActionColor),
        WpyTheme.of(context).get(WpyColorKey.reverseTextColor),
      ];
}
