import 'package:we_pei_yang_flutter/commons/themes/template/official_meta_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class LightScheme extends WpyThemeData {
  LightScheme()
      : super(
          meta: BuiltInThemeMetaData(
            themeId: "builtin_light",
            name: "Light Theme",
            description: "Built-in Light Theme",
          ),
          data: WpyThemeDetail({}),
        );
}
