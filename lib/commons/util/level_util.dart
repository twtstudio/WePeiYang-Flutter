import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';

class LevelUtil extends StatelessWidget {
  final String level;
  final TextStyle style;
  final double width;
  final double height;

  LevelUtil(
      {Key? key,
      required this.level,
      required this.width,
      required this.height,
      required this.style})
      : super(key: key);

  static const List<Color> colors = ColorUtil.rainbowColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: double.parse(level) == 0
                ? [ColorUtil.dislikeSecondary, ColorUtil.dislikeSecondary]
                : [
                    double.parse(level) >= 0
                        ? colors[(double.parse(level) / 10).floor() % 10]
                            .withAlpha(175 + (int.parse(level) % 10) * 8)
                        : ColorUtil.red85,
                    double.parse(level) >= 0
                        ? double.parse(level) >= 50
                            ? colors[(double.parse(level) / 10).floor() % 10]
                                .withAlpha(190)
                            : colors[(double.parse(level) / 10).floor() % 10]
                                .withAlpha(175 + (int.parse(level) % 10) * 8)
                        : ColorUtil.black00Color,
                  ],
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
        border: Border.all(width: 0.8, color: ColorUtil.greyEAColor),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorUtil.primaryActionColor, ColorUtil.primaryBackgroundColor],
            stops: [value, value]),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            color: ColorUtil.blackOpacity005,
          ),
        ],
      ),
    );
  }
}
