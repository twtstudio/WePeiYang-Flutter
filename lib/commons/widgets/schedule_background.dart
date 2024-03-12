import 'package:flutter/cupertino.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';

class ScheduleBackground extends StatelessWidget {
  const ScheduleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: CustomPaint(
        painter: ScheduleBackgroundPrinter(
          primaryActionColor:
              WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          primaryLightActionColor:
              WpyTheme.of(context).get(WpyColorKey.primaryLightActionColor),
          primaryBackgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          primaryLighterActionColor:
              WpyTheme.of(context).get(WpyColorKey.primaryLighterActionColor),
          primaryLightestActionColor:
              WpyTheme.of(context).get(WpyColorKey.primaryLightestActionColor),
        ),
      ),
    );
  }
}

class ScheduleBackgroundPrinter extends CustomPainter {
  final Color primaryActionColor;
  final Color primaryLightActionColor;
  final Color primaryLighterActionColor;
  final Color primaryLightestActionColor;
  final Color primaryBackgroundColor;

  ScheduleBackgroundPrinter({
    required this.primaryActionColor,
    required this.primaryLightActionColor,
    required this.primaryLighterActionColor,
    required this.primaryLightestActionColor,
    required this.primaryBackgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Primary Background Gradient
    final Gradient gradient = LinearGradient(
      colors: [
        primaryActionColor,
        primaryLightActionColor,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    Rect primaryBackground = Rect.fromLTWH(0, 0, size.width, size.height);
    Paint gradientPaint = Paint()
      ..shader = gradient.createShader(primaryBackground);
    canvas.drawRect(primaryBackground, gradientPaint);

    // Secondary White Background with 30% opacity
    Paint background30Paint = Paint()
      ..color = primaryBackgroundColor.withOpacity(0.3);
    canvas.drawRect(primaryBackground, background30Paint);

    // Three Circle with Blur Effect
    Paint blurPaint = Paint()
      ..maskFilter = MaskFilter.blur(
          BlurStyle.normal, convertRadiusToSigma(size.width * 0.53));

    // circle left bottom
    blurPaint.color = primaryLightestActionColor;
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.24,
        size.height * 0.54,
        size.width * 1.11,
        size.width * 1.11,
      ),
      blurPaint,
    );

    // circle right bottom
    blurPaint.color = primaryLighterActionColor;
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.01,
        size.width,
        size.width * 1.15,
        size.width * 1.15,
      ),
      blurPaint,
    );

    blurPaint.color = primaryActionColor.withOpacity(0.5);
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.32,
        -size.height * 0.05,
        size.width * 1.32,
        size.width * 1.32,
      ),
      blurPaint,
    );

    blurPaint.color = primaryActionColor.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * -0.4,
        size.height * 0.6,
        size.width * 1.32,
        size.width * 1.32,
      ),
      blurPaint,
    );
  }

  double convertRadiusToSigma(double radius) => radius / 4;

  @override
  bool shouldRepaint(covariant ScheduleBackgroundPrinter oldDelegate) =>
      primaryActionColor != oldDelegate.primaryActionColor ||
      primaryLightActionColor != oldDelegate.primaryLightActionColor ||
      primaryLighterActionColor != oldDelegate.primaryLighterActionColor ||
      primaryLightestActionColor != oldDelegate.primaryLightestActionColor ||
      primaryBackgroundColor != oldDelegate.primaryBackgroundColor;
}
