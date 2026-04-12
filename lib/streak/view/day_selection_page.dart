import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/streak/streak_router.dart';
import 'dart:math';

class DaySelectionPage extends StatefulWidget {
  const DaySelectionPage({Key? key}) : super(key: key);

  @override
  State<DaySelectionPage> createState() => _DaySelectionPageState();
}

class _DaySelectionPageState extends State<DaySelectionPage> with TickerProviderStateMixin {
  late AnimationController _textFadeController;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_textFadeController);
    _textFadeController.forward();


  }

  @override
  void dispose() {
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Gradient primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
        WpyTheme.of(context)
            .get(WpyColorKey.primaryActionColor)
            .withOpacity(0.6),
      ],
    );

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4],
              colors: [
                WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                Colors.white,
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Column(
              children: [
                const Spacer(flex: 1),
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        '选择你的打卡天数',
                        style: TextUtil.base.regular.sp(28).w600.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        '7天或21天',
                        style: TextUtil.base.regular.sp(16).w400.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(300.w, 300.h),
                        painter: _CircularProgressPainter(
                          gradient: primaryGradient,
                          progress: 1.0,
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 1.w,
                          height: 120.h,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      Center(
                        child: Transform.translate(
                          offset: Offset(-55.w, 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                StreakRouter.taskSelectionPage,
                                arguments: 21,
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => primaryGradient.createShader(bounds),
                                    child: Text(
                                      '21',
                                      style: TextUtil.base.regular.sp(48).copyWith(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  ShaderMask(
                                    shaderCallback: (bounds) => primaryGradient.createShader(bounds),
                                    child: Text(
                                      'Days',
                                      style: TextUtil.base.regular.sp(16).copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Transform.translate(
                          offset: Offset(55.w, 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                StreakRouter.taskSelectionPage,
                                arguments: 7,
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => primaryGradient.createShader(bounds),
                                    child: Text(
                                      '7',
                                      style: TextUtil.base.regular.sp(48).copyWith(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  ShaderMask(
                                    shaderCallback: (bounds) => primaryGradient.createShader(bounds),
                                    child: Text(
                                      'Days',
                                      style: TextUtil.base.regular.sp(16).copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),),
                const Spacer(flex: 3),
                Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: WButton(
                      onPressed: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left, color: Colors.grey, size: 20.r),
                          Text(
                            '返回上级',
                            style: TextUtil.base.regular.sp(14).copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final Gradient gradient;
  final double progress;

  _CircularProgressPainter({
    required this.gradient,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 8.0;
    const double handleRadius = 6.0;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = (min(size.width, size.height) - 2 * handleRadius) / 2;

    final rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);

    final outerConcentricCirclePaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / 5.0;
    canvas.drawCircle(Offset(centerX, centerY), radius + 15.0, outerConcentricCirclePaint);

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(centerX, centerY), radius, backgroundPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, progressPaint);

    final handleAngle = -pi / 2 + (2 * pi * progress);
    final handleCenter = Offset(
      centerX + radius * cos(handleAngle),
      centerY + radius * sin(handleAngle),
    );

    final handlePaint = Paint()
      ..color = gradient.colors.first
      ..style = PaintingStyle.fill;

    canvas.drawCircle(handleCenter, handleRadius, handlePaint);

    canvas.drawCircle(
        handleCenter,
        handleRadius,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
