import 'package:flutter/material.dart';
import 'dart:math';

import '../home_model.dart';
import 'package:wei_pei_yang_demo/commons/color.dart';

///构建wpy_page中的gpa曲线部分
class GPACurve extends StatefulWidget {
  final GPABean gpaBean;
  final double width;

  const GPACurve({@required this.gpaBean, @required this.width});

  @override
  _GPACurveState createState() => _GPACurveState();
}

class _GPACurveState extends State<GPACurve>
    with SingleTickerProviderStateMixin {
  List<Point<double>> _points = [];
  int selected = 0; //触碰到的点，等于0代表未触碰任意一点
  int _lastTaped = 1; //上次选中的点
  int _newTaped = 1; //本次选中的点

  @override
  void initState() {
    _initPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gpaBean.gpaList == null) {
      //TODO 提示内容完善
      return Text('没有gpa数据呢亲');
    }

    return Column(
      children: <Widget>[
        GestureDetector(
          //TODO 不知道为啥不起作用
            onHorizontalDragCancel: () => setState(() => selected = 0),
            onTapCancel: () => setState(() => selected = 0),
            //点击监听
            onTapDown: (TapDownDetails detail) {
              RenderBox renderBox = context.findRenderObject();
              var localOffset = renderBox.globalToLocal(detail.globalPosition);
              setState(() {
                selected = judgeSelected(localOffset);
                if (selected != 0) _newTaped = selected;
              });
            },
            //滑动监听
            onHorizontalDragUpdate: (DragUpdateDetails detail) {
              RenderBox renderBox = context.findRenderObject();
              var localOffset = renderBox.globalToLocal(detail.globalPosition);
              setState(() {
                selected = judgeSelected(localOffset);
              });
            },
            child: Container(
              height: 160.0,
              width: widget.width,
              child: Stack(
                children: <Widget>[
                  CustomPaint(
                    painter:
                    _GPACurvePainter(points: _points, selected: selected),
                    size: Size(widget.width, 160.0),
                  ),
                  TweenAnimationBuilder(
                    duration: Duration(milliseconds: 500),
                    tween: Tween(
                        begin: 0.0, end: (_lastTaped == _newTaped) ? 0.0 : 1.0),
                    onEnd: () {
                      setState(() {
                        _lastTaped = _newTaped;
                      });
                    },
                    builder: (BuildContext context, value, Widget child) {
                      var lT = _points[_lastTaped], nT = _points[_newTaped];
                      return Transform.translate(
                        //40.0和60.0用来对准黑白圆点的圆心
                        offset: Offset(lT.x - 50.0 + (nT.x - lT.x) * value,
                            lT.y - 55.0 + (nT.y - lT.y) * value),
                        child: Container(
                          width: 100.0,
                          height: 70.0,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 40.0,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Center(
                                    child: Text(
                                        '${widget.gpaBean.gpaList[_newTaped - 1]}',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: MyColors.deepBlue,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ),
                              CustomPaint(
                                painter: _GPAPopupPainter(),
                                size: Size(100.0, 30.0),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text('Total Weighted',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${widget.gpaBean.weighted}',
                      style: TextStyle(
                          color: MyColors.deepBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0)),
                )
              ],
            ),
            Column(
              children: <Widget>[
                Text('Total Grade',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${widget.gpaBean.grade}',
                      style: TextStyle(
                          color: MyColors.deepBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0)),
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  _initPoints() {
    var list = widget.gpaBean.gpaList;
    final double widthStep = widget.width / (list.length + 1);
    //对起止gpa曲线的预测值（使曲线总体呈上升状态）
    final double startGPA = (list[0] <= 5.0) ? 15 : list[0] - 5;
    final double endGPA = (list.last >= 95.0) ? 95 : list.last + 5;
    //求gpa最小值（算上起止）与最值差，使曲线高度符合比例
    final double minGPA = min(list.reduce(min), startGPA); //单独写出来是因为后面会用到
    final double gap = max(list.reduce(max), endGPA) - minGPA;
    _points.add(Point(0, 140 - (startGPA - minGPA) / gap * 120));
    for (var i = 1; i <= list.length; i++) {
      _points
          .add(Point(i * widthStep, 140 - (list[i - 1] - minGPA) / gap * 120));
    }
    _points.add(Point(widget.width, 140 - (endGPA - minGPA) / gap * 120));
  }

  //判断触碰位置是否在任意圆内, r应大于点的默认半径radius,使圆点易触
  int judgeSelected(Offset touchOffset, {double r = 15.0}) {
    var sx = touchOffset.dx;
    var sy = touchOffset.dy;
    for (var i = 1; i < _points.length - 1; i++) {
      var x = _points[i].x;
      var y = _points[i].y;
      if (!((sx - x) * (sx - x) + (sy - y) * (sy - y) > r * r)) return i;
    }
    return 0;
  }
}

///绘制GPACurve栈上层的可移动点
class _GPAPopupPainter extends CustomPainter {
  static const outerWidth = 4.0;
  static const innerRadius = 5.0;
  static const outerRadius = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint outerPaint = Paint()
      ..color = MyColors.deepBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerWidth;
    canvas.drawCircle(size.center(Offset.zero), innerRadius, innerPaint);
    canvas.drawCircle(size.center(Offset.zero), outerRadius, outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

///绘制GPACurve栈底层的曲线、黑点
class _GPACurvePainter extends CustomPainter {
  final List<Point<double>> points;
  final int selected;

  const _GPACurvePainter({@required this.points, @required this.selected});

  _drawLine(Canvas canvas, List<Point<double>> points) {
    final Paint paint = Paint()
      ..color = MyColors.dust
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final Path path = Path()
      ..moveTo(0, points[0].y)
      ..cubicThrough(points);
    canvas.drawPath(path, paint);
  }

  ///默认黑点半径为6.0，选中后为9.0
  _drawPoint(Canvas canvas, List<Point<double>> points, int selected,
      {double radius = 6.0}) {
    final Paint paint = Paint()
      ..color = MyColors.darkGrey2
      ..style = PaintingStyle.fill;
    for (var i = 1; i < points.length - 1; i++) {
      if (i == selected)
        canvas.drawCircle(
            Offset(points[i].x, points[i].y), radius + 3.0, paint);
      else
        canvas.drawCircle(Offset(points[i].x, points[i].y), radius, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas, points);
    _drawPoint(canvas, points, selected);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

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
      var bias = (point2.x - point1.x) * 0.5;
      var cp1 = Point(point1.x + bias, point1.y);
      var cp2 = Point(point2.x - bias, point2.y);
      cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, point2.x, point2.y);
    }
  }
}
