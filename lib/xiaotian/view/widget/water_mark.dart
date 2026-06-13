import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class WatermarkBg extends StatelessWidget {
  final Widget child;
  final String text;
  WatermarkBg({Key? key, required this.child, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = WpyTheme.of(context)
        .get(WpyColorKey.labelTextColor)
        .withValues(alpha: 0.02);
    return Stack(
      children: [
        child, // 你的正常页面
        RepaintBoundary(
          // 避免重复刷新
          child: IgnorePointer(
            // 不响应手势
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: _TextWatermarkPainter(text, color),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///绘制水印
class _TextWatermarkPainter extends CustomPainter {
  final String text;
  final Color color;
  _TextWatermarkPainter(this.text, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paragraph =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.left))
          ..pushStyle(ui.TextStyle(color: color, fontSize: 18))
          ..addText(text);
    final p = paragraph.build()..layout(ui.ParagraphConstraints(width: 200));

    const step = 120;
    for (int y = 0; y < size.height + step; y += step) {
      for (int x = 0; x < size.width + step; x += step) {
        canvas.save();
        canvas.translate(x.toDouble(), y.toDouble());
        canvas.rotate(-math.pi / 6);
        canvas.drawParagraph(p, Offset.zero);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TextWatermarkPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.color != color;
  }
}
