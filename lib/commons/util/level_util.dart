import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

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

  static const List<Color> colors = [
    Color.fromRGBO(94, 192, 91, 1),
    Color.fromRGBO(91, 150, 222, 1),
    Color.fromRGBO(159, 105, 237, 1),
    Color.fromRGBO(255, 135, 178, 1),
    Color.fromRGBO(248, 190, 25, 1),
    Color.fromRGBO(32, 91, 78, 1),
    Color.fromRGBO(76, 77, 113, 1),
    Color.fromRGBO(54, 27, 107, 1),
    Color.fromRGBO(130, 20, 57, 1),
    Color.fromRGBO(247, 117, 17, 1),
  ];

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
                ? [Colors.black26, Colors.black26]
                : [
                    double.parse(level) >= 0
                        ? colors[(double.parse(level) / 10).floor() % 10]
                            .withAlpha(175 + (int.parse(level) % 10) * 8)
                        : Color.fromRGBO(85, 0, 9, 1.0),
                    double.parse(level) >= 0
                        ? double.parse(level) >= 50
                            ? colors[(double.parse(level) / 10).floor() % 10]
                                .withAlpha(190)
                            : colors[(double.parse(level) / 10).floor() % 10]
                                .withAlpha(175 + (int.parse(level) % 10) * 8)
                        : Color.fromRGBO(0, 0, 0, 1.0),
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
            colors: [ColorUtil.blue2CColor, Colors.white],
            stops: [value, value]),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}
