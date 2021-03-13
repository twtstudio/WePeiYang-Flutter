import 'dart:async' show Timer;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/gpa/view/gpa_curve_detail.dart' show GPACurve;
import '../../main.dart';
import '../model/gpa_model.dart';
import '../model/gpa_notifier.dart';
import 'package:flutter/services.dart';
import 'package:umeng_sdk/umeng_sdk.dart';

/// 这里讲一下gpa页面配色的颜色分配：（不包含首页的gpa曲线）
///
/// 首先，gpa配色[gpaColors]来自[FavorColors.gpaColor]，配色名则由[FavorColors.gpaType]保存
/// 每套配色均由四种颜色：[背景色]、[颜色一]、[颜色二]、[颜色三]组成（在List中顺序排列，具体名字我懒得取了）
/// * 背景色：页面背景颜色、曲线上被选中的点的内圆
///
/// * 颜色一：AppBar图标、雷达图上的课程名、雷达图成绩区域外沿、曲线上未选中的点、[CourseListWidget]中的
///          课程名、以及所有的数字（[CourseListWidget]中的[xx Credits]除外）
///
/// * 颜色二：[GPAStatsWidget]中的文字、'ORDERED BY'、[CourseListWidget]中的课程类别和小图标
///
/// * 颜色三：gpa曲线颜色、曲线上popup框颜色、[CourseListWidget]框颜色
///
/// * 注：雷达图的成绩区域填充色、放射线条、绩点区域颜色均固定，设计也没给55555

class GPAPage extends StatefulWidget {
  final List<Color> gpaColors = FavorColors.gpaColor;

  @override
  _GPAPageState createState() => _GPAPageState();
}

class _GPAPageState extends State<GPAPage> {
  /// 进入gpa页面后自动刷新数据
  _GPAPageState() {
    Provider.of<GPANotifier>(WeiPeiYangApp.navigatorState.currentContext)
        .refreshGPA(hint: false)
        .call();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    UmengSdk.onPageEnd('/gpa');
    super.dispose();
  }

  @override
  void initState() {
    UmengSdk.onPageStart('/gpa');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GPANotifier>(
        builder: (context, notifier, _) => Scaffold(
              appBar: GPAppBar(widget.gpaColors),
              backgroundColor: widget.gpaColors[0],
              body: Theme(
                /// 修改scrollView滚动至头/尾时溢出的颜色
                data: ThemeData(accentColor: Colors.white),
                child: ListView(
                  children: [
                    RadarChartWidget(notifier, widget.gpaColors),
                    GPAStatsWidget(notifier, widget.gpaColors),
                    GPACurve(notifier, widget.gpaColors, isPreview: false),
                    CourseListWidget(notifier, widget.gpaColors)
                  ],
                ),
              ),
            ));
  }
}

class GPAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Color> gpaColors;

  GPAppBar(this.gpaColors);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: gpaColors[0],
      elevation: 0,
      brightness: FavorColors.gpaType.value == 'light'
          ? Brightness.light
          : Brightness.dark,
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: GestureDetector(
            child: Icon(Icons.arrow_back, color: gpaColors[1], size: 28),
            onTap: () => Navigator.pop(context)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.loop, color: gpaColors[1], size: 25),
              onTap: Provider.of<GPANotifier>(context, listen: false)
                  .refreshGPA()),
        ),
      ],
    );
  }

  /// 使用标准的appBar高度
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class RadarChartWidget extends StatefulWidget {
  final GPANotifier notifier;
  final List<Color> gpaColors;

  RadarChartWidget(this.notifier, this.gpaColors);

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChartWidget> {
  List<GPACourse> _list = [];

  /// isTaped为true时雷达图有透明度
  bool _isTaped = false;

  static Timer _timer;

  @override
  Widget build(BuildContext context) {
    _list = widget.notifier.coursesWithNotify;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isTaped = true;
          _list.shuffle();
        });

        /// 重复点击雷达图时，timer重新计时
        if (_timer != null && _timer.isActive) _timer.cancel();
        _timer = Timer(Duration(milliseconds: 300), () {
          setState(() => _isTaped = false);
        });
      },
      child: Opacity(
        opacity: _isTaped ? 0.2 : 1,
        child: _judgeListLength(_list),
      ),
    );
  }

  Widget _judgeListLength(List<GPACourse> _list) {
    if (_list.length < 3)
      return Container(
        height: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
                child: Icon(Icons.assessment,
                    size: 150, color: widget.gpaColors[2]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                    "Radar & rose chart is not available with semesters of less than three courses.",
                    style: TextStyle(color: widget.gpaColors[2], fontSize: 13)),
              )
            ],
          ),
        ),
      );
    else
      return Container(
        height: 350,
        child: CustomPaint(
          painter: _RadarChartPainter(_list, widget.gpaColors),
          size: Size(double.maxFinite, 160),
        ),
      );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<GPACourse> courses;
  final List<Color> gpaColors;

  _RadarChartPainter(this.courses, this.gpaColors);

  double radarChartRatio = 2.15; // 用这个控制雷达图大小,不能低于2
  double centerX;
  double centerY;
  double outer;
  double inner;
  double middle;
  double slice;
  List<Offset> outerPoints = List();
  List<Offset> innerPoints = List();
  List<Offset> middlePoints = List();

  double _count(double x) => pow(pow(x, 2) / 100, 2) / 10000;

  _drawCredit(Canvas canvas, Size size) {
    double maxCredit = 0;
    courses.forEach((element) {
      if (element.credit > maxCredit) maxCredit = element.credit;
    });
    final Paint creditPaint = Paint()
      ..color = Color.fromRGBO(178, 178, 158, 0.2)
      ..style = PaintingStyle.fill;
    final Path creditPath = Path();
    for (var i = 0; i < courses.length; i++) {
      var ratio = courses[(i + 1) % courses.length].credit / maxCredit;
      var biasX = (outerPoints[i].dx - centerX) * ratio;
      var biasY = (outerPoints[i].dy - centerY) * ratio;
      creditPath
        ..moveTo(centerX, centerY)
        ..lineTo(centerX + biasX, centerY + biasY)
        ..arcTo(
            Rect.fromCircle(
                center: size.center(Offset.zero), radius: outer * ratio),
            slice * (i * 2 + 1),
            slice * 2,
            false)
        ..lineTo(centerX, centerY)
        ..close();
    }
    canvas.drawPath(creditPath, creditPaint);
  }

  _drawScoreFill(Canvas canvas) {
    final Paint fillPaint = Paint()
      ..color = Color.fromRGBO(230, 230, 230, 0.25)
      ..style = PaintingStyle.fill;
    final Path fillPath = Path()..moveTo(centerX, centerY);
    for (var x = 0; x <= courses.length; x++) {
      var i = x % courses.length;
      double ratio = _count(courses[i].score);
      var biasX = (innerPoints[i].dx - centerX) * ratio;
      var biasY = (innerPoints[i].dy - centerY) * ratio;
      if (x == 0)
        fillPath.moveTo(centerX + biasX, centerY + biasY);
      else
        fillPath.lineTo(centerX + biasX, centerY + biasY);
    }
    canvas.drawPath(fillPath, fillPaint);
  }

  _drawLine(Canvas canvas) {
    final Paint linePaint = Paint()
      ..color = Color.fromRGBO(158, 158, 138, 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Path linePath = Path();
    for (var i = 0; i < courses.length; i++) {
      linePath
        ..moveTo(centerX, centerY)
        ..lineTo(innerPoints[i].dx, innerPoints[i].dy);
    }
    canvas.drawPath(linePath, linePaint);
  }

  _drawScoreOutLine(Canvas canvas) {
    final Paint outLinePaint = Paint()
      ..color = gpaColors[1]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;
    final Path outLinePath = Path()..moveTo(centerX, centerY);
    for (var x = 0; x <= courses.length; x++) {
      var i = x % courses.length;
      double ratio = _count(courses[i].score);
      var biasX = (innerPoints[i].dx - centerX) * ratio;
      var biasY = (innerPoints[i].dy - centerY) * ratio;
      if (x == 0)
        outLinePath.moveTo(centerX + biasX, centerY + biasY);
      else
        outLinePath.lineTo(centerX + biasX, centerY + biasY);
    }
    canvas.drawPath(outLinePath, outLinePaint);
  }

  _drawText(Canvas canvas) {
    for (var i = 0; i < courses.length; i++) {
      var textPainter = TextPainter(
          text: TextSpan(
              text: _formatText(courses[i].name),
              style: TextStyle(fontSize: 10, color: gpaColors[1])),
          maxLines: 3,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 40, minWidth: 0);
      var position = Offset(middlePoints[i].dx - (textPainter.width) / 2,
          middlePoints[i].dy - (textPainter.height / 2));
      textPainter.paint(canvas, position);
    }
  }

  String _formatText(String text) {
    var len = text.length;
    if (len >= 5 && len <= 8) {
      int i = (len / 2).ceil();
      return text.substring(0, i) + "\n" + text.substring(i, len);
    } else if (len == 9 || len == 10) {
      return text.substring(0, 3) +
          "\n" +
          text.substring(3, len - 3) +
          "\n" +
          text.substring(len - 3, len);
    } else if (len > 12) {
      return text.substring(0, 11) + '...';
    } else
      return text;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _initPoints(size);
    _drawCredit(canvas, size);
    _drawScoreFill(canvas);
    _drawLine(canvas);
    _drawScoreOutLine(canvas);
    _drawText(canvas);
  }

  _initPoints(Size size) {
    centerX = size.center(Offset.zero).dx;
    centerY = size.center(Offset.zero).dy;
    outer = size.height / radarChartRatio;
    inner = outer * 2 / 3;
    middle = (outer + inner) / 2;

    ///若list长度为10,则分成20份
    slice = pi / courses.length;
    for (var i = 0; i < courses.length; i++)
      outerPoints.add(Offset(centerX + outer * cos(slice * (i * 2 + 1)),
          centerY + outer * sin(slice * (i * 2 + 1))));
    for (var i = 0; i < courses.length; i++)
      innerPoints.add(Offset(centerX + inner * cos(slice * i * 2),
          centerY + inner * sin(slice * i * 2)));
    for (var i = 0; i < courses.length; i++)
      middlePoints.add(Offset(centerX + middle * cos(slice * i * 2),
          centerY + middle * sin(slice * i * 2)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;
}

/// 其实代码很像gpa_curve_detail.dart中的GPAIntro,只不过没法复用555
class GPAStatsWidget extends StatelessWidget {
  final GPANotifier notifier;
  final List<Color> gpaColors;

  GPAStatsWidget(this.notifier, this.gpaColors) {
    textStyle = TextStyle(
        color: gpaColors[2], fontWeight: FontWeight.bold, fontSize: 13.0);
    numStyle = TextStyle(
        color: gpaColors[1], fontWeight: FontWeight.bold, fontSize: 22.0);
  }

  static var textStyle;
  static var numStyle;

  @override
  Widget build(BuildContext context) {
    var weighted = "不";
    var gpa = "知";
    var credits = "道";
    if (notifier.currentDataWithNotify != null) {
      weighted = notifier.currentDataWithNotify[0].toString();
      gpa = notifier.currentDataWithNotify[1].toString();
      credits = notifier.currentDataWithNotify[2].toString();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /// InkResponse provides splashes which can extend outside its bounds
          InkResponse(
            onTap: () => notifier.typeWithNotify = 0,
            radius: 45,

            /// defines a splash that spreads out more aggressively than the default
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Weighted', style: textStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(weighted, style: numStyle),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6), // 加点padding让gpa尽量居中
            child: InkResponse(
              onTap: () => notifier.typeWithNotify = 1,
              radius: 45,
              splashFactory: InkRipple.splashFactory,
              child: Column(
                children: <Widget>[
                  Text('GPA', style: textStyle),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(gpa, style: numStyle),
                  )
                ],
              ),
            ),
          ),
          InkResponse(
            onTap: () => notifier.typeWithNotify = 2,
            radius: 45,
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Credits', style: textStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(credits, style: numStyle),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseListWidget extends StatefulWidget {
  final GPANotifier notifier;
  final List<Color> gpaColors;

  CourseListWidget(this.notifier, this.gpaColors);

  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseListWidget> {
  static final double cardHeight = 82;

  @override
  Widget build(BuildContext context) {
    var courses = widget.notifier.coursesWithNotify;
    return Column(
      children: [
        GestureDetector(
          onTap: () => widget.notifier.reSort(),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: RichText(
                  text: TextSpan(
                      text: 'ORDERED\tBY\t',
                      style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 4,
                          color: widget.gpaColors[2]),
                      children: <TextSpan>[
                    TextSpan(
                        text: widget.notifier.sortType.toUpperCase(),
                        style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 4,
                            color: widget.gpaColors[1],
                            fontWeight: FontWeight.bold))
                  ]))),
        ),
        Container(
          height: cardHeight * courses.length,
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, i) => Container(
                    height: cardHeight,
                    padding: EdgeInsets.fromLTRB(30, 2, 30, 2),
                    child: Card(
                      color: widget.gpaColors[3],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        splashFactory: InkRipple.splashFactory,
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                              child: Icon(Icons.assignment_turned_in,
                                  color: widget.gpaColors[2], size: 25),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(_formatText(courses[i].name),
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: widget.gpaColors[1])),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "${courses[i].classType} / ${courses[i].credit} Credits",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: widget.gpaColors[2])),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 15),
                              child: Text('${courses[i].score.round()}',
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: widget.gpaColors[1],
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
        )
      ],
    );
  }

  String _formatText(String text) {
    if (text.length >= 12)
      return text.substring(0, 11) + "...";
    else
      return text;
  }
}
