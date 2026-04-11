import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/streak/streak_router.dart';
import 'package:we_pei_yang_flutter/streak/view/day_selection_page.dart';
import 'dart:math';

class StreakPage extends StatefulWidget {
  const StreakPage({Key? key}) : super(key: key);

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with TickerProviderStateMixin {
  late AnimationController _textFadeController;
  late Animation<double> _textFadeAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

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

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);
    _progressAnimation.addListener(() {
      setState(() {});
    });
    _progressAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushNamed(context, StreakRouter.daySelectionPage);
      }
    });
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    _progressController.dispose();
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
            leading: Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: WButton(
                  child: Icon(Icons.arrow_back,
                      color:
                      WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                      size: 32.r),
                  onPressed: () => Navigator.pop(context)),
            ),
            title: Text('北洋圆',
                style: TextUtil.base.bold.sp(16).oldActionColor(context)),
            centerTitle: true,
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
                        '欢迎使用北洋圆',
                        style: TextUtil.base.regular.sp(28).w600.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        '开启你的习惯养成之旅',
                        style: TextUtil.base.regular.sp(16).w400.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                WButton(
                  onPressed: () {
                    if (_progressController.isAnimating) return;
                    _progressController.reset();
                    _progressController.forward();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(300.w, 300.h),
                        painter: _CircularProgressPainter(
                          gradient: primaryGradient,
                          progress: _progressAnimation.value,
                        ),
                      ),
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return primaryGradient.createShader(bounds);
                              },
                              child: Text(
                                '点击继续',
                                style: TextUtil.base.bold.sp(34).copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'CONTINUE',
                              style: TextUtil.base.bold.sp(15).copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        Text('北洋圆',
                            style: TextUtil.base.medium.sp(16).copyWith(
                              color: Colors.grey,
                            )),
                        SizedBox(height: 2.h),
                        Text('TJU ORBIT ECOSYSTEM',
                            style: TextUtil.base.regular.sp(10).copyWith(
                              color: Colors.grey,
                            )),
                      ],
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
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);

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