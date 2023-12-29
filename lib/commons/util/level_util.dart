import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/feedback/util/splitscreen_util.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';

class LevelUtil extends StatelessWidget {
  final String level;
  final TextStyle style;
  final bool? big;

  LevelUtil({Key? key, required this.level, required this.style, this.big})
      : super(key: key);

  List<Color> colors(context) =>
      WpyTheme.of(context).getColorSet(WpyColorSetKey.levelColors);

  /*

  原来是这样 如果之后有问题可以参照修改
  double.parse(level) == 0
  ? [
      WpyTheme.of(context).get(WpyThemeKeys.dislikeSecondary),
      WpyTheme.of(context).get(WpyThemeKeys.dislikeSecondary)
    ]
  : [
      double.parse(level) >= 0
          ? colors[(double.parse(level) / 10).floor() % 10]
              .withAlpha(175 + (int.parse(level) % 10) * 8)
          : WpyTheme.of(context).get(WpyColorKey.levelNegColor),
      double.parse(level) >= 0
          ? double.parse(level) >= 50
              ? colors[(double.parse(level) / 10).floor() % 10]
                  .withAlpha(190)
              : colors[(double.parse(level) / 10).floor() % 10]
                  .withAlpha(175 + (int.parse(level) % 10) * 8)
          : WpyTheme.of(context).get(WpyThemeKeys.basicTextColor),
    ]
  * */

  List<Color> getColorBasedOnLevel(BuildContext context) {
    // Parse the level once at the beginning
    double parsedLevel = double.parse(level);
    int parsedLevelInt = parsedLevel.toInt();

    // Define colors for negative, default, and base text
    final Color negativeColor =
        WpyTheme.of(context).get(WpyColorKey.levelNegColor);
    final Color dislikeSecondaryColor =
        WpyTheme.of(context).get(WpyColorKey.dislikeSecondary);
    final Color basicTextColor =
        WpyTheme.of(context).get(WpyColorKey.basicTextColor);

    // Calculate alpha based on level
    int alphaValue = 175 + (parsedLevelInt % 10) * 8;
    alphaValue =
        parsedLevel >= 50 ? 190 : alphaValue; // Override alpha for levels >= 50

    // Determine the color based on the level
    Color color = parsedLevel >= 0
        ? colors(context)[(parsedLevelInt / 10).floor() % 10]
            .withAlpha(alphaValue)
        : negativeColor;

    // Set the color array
    List<Color> colorArray = parsedLevel == 0
        ? [dislikeSecondaryColor, dislikeSecondaryColor]
        : [color, parsedLevel >= 0 ? color : basicTextColor];

    return colorArray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SplitUtil.w * ((this.big ?? false) ? SplitUtil.w * 40 : SplitUtil.w * 26),
      height: SplitUtil.h * ((this.big ?? false) ? SplitUtil.w * 18 : SplitUtil.w * 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getColorBasedOnLevel(context),
            stops: [0.5, 0.8]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "LV" + level,
          style: style,
        ),
      ),
    );
  }
}

class LevelProgress extends StatelessWidget {
  final double value;

  LevelProgress({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 4.w,
      decoration: BoxDecoration(
        border: Border.all(
            width: 0.8,
            color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor)),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)
            ],
            stops: [
              value,
              value
            ]),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            color: WpyTheme.of(context)
                .get(WpyColorKey.basicTextColor)
                .withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}
