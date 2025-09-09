import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class WatermarkBg extends StatelessWidget {
  final Widget child;
  final String text;
  WatermarkBg({Key? key, required this.child, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,                       // 你的正常页面
        RepaintBoundary(             // 避免重复刷新
          child: IgnorePointer(      // 不响应手势
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: _TextWatermarkPainter(text),
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
  _TextWatermarkPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.grey.withOpacity(0.05),
      fontSize: 18,
    );
    final paragraph = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: ui.TextAlign.left))
      ..pushStyle(ui.TextStyle(
          color: Colors.grey.withOpacity(0.15),
          fontSize: 18))
      ..addText(text);
    final p = paragraph.build()
      ..layout(ui.ParagraphConstraints(width: 200));

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
  bool shouldRepaint(_) => false;
}