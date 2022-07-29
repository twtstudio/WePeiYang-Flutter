// @dart = 2.12

import 'package:flutter/material.dart';

// https://blog.csdn.net/shving/article/details/111146673
class GradientLinearProgressBar extends StatelessWidget {
  ///画笔的宽度，其实是进度条的高度
  final double strokeWidth;
  ///是否需要圆角
  final bool strokeCapRound;
  ///进度值
  final double value;
  ///进度条背景色
  final Color backgroundColor;
  ///渐变的颜色列表
  final List<Color> colors;

  GradientLinearProgressBar({
    this.strokeWidth = 2.0,
    required this.colors,
    required this.value,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.strokeCapRound = false
  });

  @override
  Widget build(BuildContext context) {
    // very very very very very important : [RepaintBoundary]
    // to avoid repaint and confused bugs
    return RepaintBoundary(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _GradientLinearProgressPainter(
            strokeWidth: strokeWidth,
            strokeCapRound: strokeCapRound,
            backgroundColor: backgroundColor,
            value: value,
            colors: colors),
      ),
    );
  }
}

class _GradientLinearProgressPainter extends CustomPainter{

  final double strokeWidth;
  final bool strokeCapRound;
  final double value;
  final Color backgroundColor;
  final List<Color> colors;
  final List<double>? stops;
  final p = Paint();

  _GradientLinearProgressPainter({
    this.strokeWidth = 2.0,
    required this.colors,
    this.value = 0.0,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.strokeCapRound = false,
    this.stops
  });

  @override
  void paint(Canvas canvas, Size size) {
    p.strokeCap = strokeCapRound ? StrokeCap.round : StrokeCap.butt;
    p.style = PaintingStyle.fill;
    p.isAntiAlias = true;
    p.strokeWidth = strokeWidth;

    //留一定的偏移量
    double _offset = strokeWidth / 2;
    //画笔起点坐标
    var start = Offset(_offset, _offset);
    //画笔终点坐标
    var end = Offset(size.width, _offset);

    if (backgroundColor != Colors.transparent) {
      p.color = backgroundColor;
      canvas.drawLine(start, end, p);
    }

    if (value > 0) {
      var valueEnd = Offset(value * size.width + _offset, _offset); //计算进度的长度
      Rect rect = Rect.fromPoints(start, valueEnd);
      p.shader =
          LinearGradient(colors: colors, stops: stops).createShader(rect);
      p.color = Colors.amber;
      canvas.drawLine(start, valueEnd, p);
      debugPrint("$start,$valueEnd");
      debugPrint("$size");
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}