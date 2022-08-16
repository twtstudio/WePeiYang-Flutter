// @dart = 2.12
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_model.dart';

import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';

/// 构建wpy_page中的gpa部分
class GPAPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var hideGPA = context.select<GPANotifier, bool>((p) => p.hideGPA);
    if (hideGPA) return Container();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, GPARouter.gpa),
      behavior: HitTestBehavior.opaque,
      child: Column(children: <Widget>[
        //_CurveText(),
        SizedBox(
          height: 45.h,
        ),
        _GPAIntro(),
        GPACurve(FavorColors.gpaColor, isPreview: true),
      ]),
    );
  }
}

/// 曲线上面的文字，说明当前曲线的内容
/// 设计图上没有，先注释，确认没用再删
// class _CurveText extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, GPARouter.gpa),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(25, 25, 0, 20),
//         alignment: Alignment.centerLeft,
//         child: Builder(builder: (context) {
//           var typeName = context.select<GPANotifier, String>((p) => p.typeName);
//           return Text("$typeName${S.current.curve}",
//               style: FontManager.YaQiHei.copyWith(
//                   fontSize: 16,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold));
//         }),
//       ),
//     );
//   }
// }

/// wpy_page中显示数值信息
class _GPAIntro extends StatelessWidget {
  static final _textStyle =
      FontManager.YaHeiLight.copyWith(color: Color(0xffcdcdd3), fontSize: 14);

  static final _numStyle = FontManager.Montserrat.copyWith(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22);

  @override
  Widget build(BuildContext context) {
    var total = context.select<GPANotifier, Total?>((p) => p.total);
    var weighted = "不";
    var grade = "知";
    var credit = "道";
    if (total != null) {
      if (CommonPreferences.isAprilFoolGPA.value) {
        weighted = 100.toString();
        grade = 4.0.toString();
        credit = 114514.toString();
      } else {
        weighted = total.weighted.toString();
        grade = total.gpa.toString();
        credit = total.credits.toString();
      }
    }
    var quietPvd = context.read<GPANotifier>();
    return Container(
      decoration: CommonPreferences.isSkinUsed.value
          ? BoxDecoration(color: Colors.white10)
          : BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkResponse(
            onTap: () => quietPvd.type = 0,
            radius: 45,
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Total Weighted', style: _textStyle),
                SizedBox(height: 8),
                Text(weighted, style: _numStyle)
              ],
            ),
          ),
          InkResponse(
            onTap: () => quietPvd.type = 1,
            radius: 45,
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Total GPA', style: _textStyle),
                SizedBox(height: 8),
                Text(grade, style: _numStyle)
              ],
            ),
          ),
          InkResponse(
            onTap: () => quietPvd.type = 2,
            radius: 45,
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Credits Earned', style: _textStyle),
                SizedBox(height: 8),
                Text(credit, style: _numStyle)
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// GPA曲线的总体由[Stack]构成
/// Stack的底层为静态的[_GPACurvePainter],由cubic曲线和黑点构成
/// Stack的顶层为动态的[_GPAPopupPainter],用补间动画控制移动
class GPACurve extends StatefulWidget {
  final List<Color> _gpaColors;

  /// 是否在wpy_page中显示（false的话就是在gpa_page中呗）
  final bool isPreview;

  GPACurve(this._gpaColors, {required this.isPreview});

  @override
  _GPACurveState createState() => _GPACurveState();
}

class _GPACurveState extends State<GPACurve>
    with SingleTickerProviderStateMixin {
  static const Color _popupCardPreview = Colors.white;
  static const Color _popupTextPreview = Color.fromRGBO(53, 59, 84, 1.0);
  static late Color _popupCardColor;
  static late Color _popupTextColor;
  static const double _canvasHeight = 120; // 用于控制曲线canvas的高度

  /// 上次 / 本次选中的点
  int _lastTaped = 1;
  int _newTaped = 1;

  @override
  void initState() {
    super.initState();
    _popupCardColor = widget._gpaColors[3];
    _popupTextColor = widget._gpaColors[0];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var notifier = context.watch<GPANotifier>();
      if (notifier.statsData.isEmpty) return SizedBox(height: 10);
      if (_lastTaped == _newTaped) {
        _lastTaped = notifier.index + 1;
        _newTaped = _lastTaped;
      }
      List<Point<double>> points = [];
      List<double> curveData = notifier.curveData;
      _initPoints(points, curveData, constraints.maxWidth);
      return GestureDetector(

          /// 点击监听
          onTapDown: (TapDownDetails detail) {
            var renderBox = context.findRenderObject() as RenderBox;
            var localOffset = renderBox.globalToLocal(detail.globalPosition);
            var result = _judgeTaped(localOffset, points, r: 50);
            if (result != 0) {
              setState(() => _newTaped = result);
              notifier.index = result - 1;
            }
          },
          child: Column(
            children: [
              Container(
                decoration:
                    (widget.isPreview && CommonPreferences.isSkinUsed.value)
                        ? BoxDecoration(color: Colors.white10)
                        : BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Stack(
                    children: <Widget>[
                      /// Stack底层
                      CustomPaint(
                        painter: _GPACurvePainter(widget._gpaColors,
                            isPreview: widget.isPreview,
                            points: points,
                            taped: _newTaped),
                        size: Size(double.maxFinite, _canvasHeight),
                      ),

                      /// Stack顶层
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween(
                            begin: 0.0,
                            end: (_lastTaped == _newTaped) ? 0.0 : 1.0),
                        onEnd: () => setState(() => _lastTaped = _newTaped),
                        curve: Curves.easeInOutSine,
                        builder: (BuildContext context, value, _) {
                          var lT = points[_lastTaped], nT = points[_newTaped];
                          return Transform.translate(
                            /// 计算两次点击之间的偏移量Offset
                            /// 40.0和60.0用来对准黑白圆点的圆心(与下方container大小有关)
                            offset: Offset(lT.x - 40 + (nT.x - lT.x) * value,
                                lT.y - 60 + (nT.y - lT.y) * value),
                            child: SizedBox(
                              width: 80,
                              height: 75,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    width: 80,
                                    height: 45,
                                    child: Card(
                                      color: widget.isPreview
                                          ? _popupCardPreview
                                          : _popupCardColor,
                                      elevation: widget.isPreview ? 1 : 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Center(
                                        child: Text(
                                            '${curveData[_newTaped - 1]}',
                                            style:
                                                FontManager.Montserrat.copyWith(
                                                    fontSize: 16,
                                                    color: widget.isPreview
                                                        ? _popupTextPreview
                                                        : _popupTextColor)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        CommonPreferences.isSkinUsed.value
                                            ? BoxDecoration(
                                                image: widget.isPreview
                                                    ? DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/begonia/flower_grey.png'),
                                                        fit: BoxFit.contain,
                                                      )
                                                    : DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/lake_butt_icons/flower.png'),
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                              )
                                            : BoxDecoration(),
                                    child: CustomPaint(
                                      painter: _GPAPopupPainter(
                                          widget._gpaColors,
                                          isPreview: widget.isPreview),
                                      size: const Size(80, 30),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 20, top: 80),
                child: Container(
                  height: 40.h,
                  width: 300.w,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 27.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: notifier.index == index
                                    ? Color(0xFF2C7EDF)
                                    : Colors.white),
                            child: Center(
                              child: Text(
                                index.toString() + "H20",
                                style: notifier.index == index
                                    ? TextUtil.base.white.bold.w700.sp(11)
                                    : TextUtil.base.greyA6.bold.w700.sp(11),
                              ),
                            ),
                          ),
                          if (index < 3)
                            SizedBox(
                              width:
                                  points[index + 1].x - points[index].x - 48.w,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ));
    });
  }

  /// Canvas上下各留高度为20的空白区域，并在中间进行绘制
  _initPoints(List<Point<double>> points, List<double> list, double maxWidth) {
    var width = maxWidth;
    var step = width / (list.length + 1);
    var h1 = _canvasHeight - 20; // canvas除去上面的空白
    var h2 = _canvasHeight - 40; // canvas中间区域大小

    /// 求gpa最小值（算上起止）与最值差，使曲线高度符合比例
    var minStat = list.reduce(min);
    var maxStat = list.reduce(max);
    var gap = maxStat - minStat;

    /// gap为0.0的时候令所有点均处于canvas的正中间（研究生gpa均为0所以会出现这种情况）
    if ((1 / gap) == double.infinity) {
      gap = 1.0; // 随便设个值，只要不是0.0就行
      h1 -= h2 / 2;
    }
    points.add(Point(0, h1 - (list.first - minStat) / gap * h2));
    for (var i = 0; i < list.length; i++) {
      points.add(Point((i + 1) * step, h1 - (list[i] - minStat) / gap * h2));
    }
    points.add(Point(width, h1 - (list.last - minStat) / gap * h2));
  }

  /// 判断触碰位置是否在任意圆内, 此处的r大于点的默认半径radius,使圆点易触
  int _judgeTaped(Offset touchOffset, List<Point<double>> points,
      {double r = 15.0}) {
    var sx = touchOffset.dx;
    var sy = touchOffset.dy;
    for (var i = 1; i < points.length - 1; i++) {
      var x = points[i].x;
      var y = points[i].y;
      if (!((sx - x) * (sx - x) + (sy - y) * (sy - y) > r * r)) return i;
    }
    return 0;
  }
}

/// 绘制GPACurve栈上层的可移动点
class _GPAPopupPainter extends CustomPainter {
  /// 是否在wpy中显示
  final bool isPreview;

  /// 在wpy_page显示的颜色
  static const Color _outerPreview = Colors.white10;
  static const Color _innerPreview = Color(0xFF2C7EDF);

  static const _outerWidth = 4.0;
  static const _innerRadius = 5.0;
  static const _outerRadius = 7.0;

  final Paint _innerPaint;
  final Paint _outerPaint;

  _GPAPopupPainter(List<Color> gpaColors, {required this.isPreview})
      : _innerPaint = Paint()
          ..color = isPreview ? _innerPreview : gpaColors[0]
          ..style = PaintingStyle.fill,
        _outerPaint = Paint()
          ..color = isPreview ? _outerPreview : gpaColors[1]
          ..style = PaintingStyle.stroke
          ..strokeWidth = _outerWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(size.center(Offset.zero), _innerRadius, _innerPaint);
    canvas.drawCircle(size.center(Offset.zero), _outerRadius, _outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

/// 绘制GPACurve栈底层的曲线、黑点
class _GPACurvePainter extends CustomPainter {
  /// 是否在wpy中显示
  final bool isPreview;
  final List<Point<double>> points;
  final int taped;

  /// 在wpy_page显示的颜色
  static const Color _linePreview = Color(0xFF2C7EDF);
  static const Color _pointPreview = Colors.white;

  final Paint _linePaint;
  final Paint _pointPaint;
  final Paint _downPaint;

  _GPACurvePainter(List<Color> gpaColors,
      {required this.isPreview, required this.points, required this.taped})
      : _linePaint = Paint()
          ..color = isPreview ? _linePreview : gpaColors[3]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0,
        _pointPaint = Paint()
          ..color = isPreview ? _pointPreview : gpaColors[1]
          ..style = PaintingStyle.fill,
        _downPaint = Paint()
          ..color = isPreview ? _linePreview : gpaColors[3]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

  _drawLine(Canvas canvas, List<Point<double>> points) {
    var path = Path()
      ..moveTo(0, points[0].y)
      ..cubicThrough(points);
    var shadowPath = Path()
      ..moveTo(0, points[0].y)
      ..shadowThrough(points);
    canvas.drawPath(path, _linePaint);
    canvas.drawShadow(shadowPath, Colors.blueAccent, 40, true);
  }

  /// 默认黑点半径为6.0，选中后为8.0
  _drawPoint(Canvas canvas, List<Point<double>> points, int selected,
      {double radius = 6.0}) {
    for (var i = 1; i < points.length - 1; i++) {
      if (i == selected) {
        canvas.drawCircle(
            Offset(points[i].x, points[i].y), radius + 2.0, _pointPaint);
        canvas.drawLine(Offset(points[i].x, points[i].y),
            Offset(points[i].x, 230), _downPaint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas, points);
    _drawPoint(canvas, points, taped);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

/// 利用点坐标数组绘制三阶贝塞尔曲线
/// cp1和cp2为辅助点
extension Cubic on Path {
  cubicThrough(List<Point<double>> list) {
    for (var i = 0; i < list.length - 1; i++) {
      var point1 = list[i];
      var point2 = list[i + 1];

      ///调整bias可以控制曲线起伏程度
      var biasX = (point2.x - point1.x) * 0.3;
      var biasY = (point1.y == point2.y) ? 2 : 0;
      var cp1 = Point(point1.x + biasX, point1.y - biasY);
      var cp2 = Point(point2.x - biasX, point2.y + biasY);
      cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, point2.x, point2.y);
    }
  }

  shadowThrough(List<Point<double>> list) {
    ///绘制阴影用曲线
    for (var i = 0; i < list.length - 1; i++) {
      var point1 = list[i];
      var point2 = list[i + 1];

      var biasX = (point2.x - point1.x) * 0.3;
      var biasY = (point1.y == point2.y) ? 2 : 0;
      var cp1 = Point(point1.x + biasX, point1.y + biasY);
      var cp2 = Point(point2.x - biasX, point2.y + biasY);
      cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, point2.x, point2.y);
    }
  }
}
