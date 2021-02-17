import 'dart:async' show Timer;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/gpa/view/gpa_curve_detail.dart' show GPACurve;
import '../model/gpa_model.dart';
import '../model/gpa_notifier.dart';

class GPAPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GPANotifier>(
        builder: (context, notifier, _) => Scaffold(
              appBar: GPAppBar(),
              backgroundColor: const Color.fromRGBO(127, 139, 89, 1.0),
              body: Theme(
                /// 修改scrollView滚动至头/尾时溢出的颜色
                data: ThemeData(accentColor: Colors.white),
                child: ListView(
                  children: [
                    RadarChartWidget(notifier),
                    GPAStatsWidget(notifier),
                    GPACurve(notifier, isPreview: false),
                    CourseListWidget(notifier)
                  ],
                ),
              ),
            ));
  }
}

class GPAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    // TODO 回头记得撤了假数据
    List<GPACourse> list1 = [];
    List<GPAStat> gpaList = [];
    list1.add(GPACourse("高等数学2A", "数学", 93, 6, 4));
    list1.add(GPACourse("C/C++程序设计（双语）", "计算机", 91, 3.5, 4));
    list1.add(GPACourse("线性代数及其应用", "数学", 94, 3.5, 4));
    list1.add(GPACourse("思想道德修养与法律基础哈哈哈", "思想政治理论", 55, 3, 0));
    list1.add(GPACourse("大学英语1", "外语", 97, 2, 4));
    list1.add(GPACourse("计算机导论", "计算机", 76, 1.5, 2.7));
    list1.add(GPACourse("大学生心理健康", "文化素质教育必修", 60, 1, 2));
    list1.add(GPACourse("体育A", "体育", 78, 1, 2.8));
    list1.add(GPACourse("健康教育", "健康教育", 86, 0.5, 3));
    list1.add(GPACourse("大学计算机基础1", "计算机", 100, 0, 4));
    List<GPACourse> list2 = [];
    list2.add(GPACourse("高等数学2A", "数学", 63, 6, 2.2));
    list2.add(GPACourse("C/C++程序设计（双语）", "计算机", 25, 3.5, 0));
    list2.add(GPACourse("线性代数及其应用", "数学", 85, 3.5, 2.9));
    list2.add(GPACourse("思想道德修养与法律基础哈哈哈", "思想政治理论", 15, 3, 0));
    list2.add(GPACourse("大学英语1", "外语", 57, 2, 0));
    list2.add(GPACourse("计算机导论", "计算机", 86, 1.5, 3));
    list2.add(GPACourse("大学生心理健康", "文化素质教育必修", 47, 1, 0));
    list2.add(GPACourse("体育A", "体育", 23, 1, 0));
    list2.add(GPACourse("健康教育", "健康教育", 47, 0.5, 0));
    list2.add(GPACourse("大学计算机基础1", "计算机", 11, 0, 0));
    gpaList.add(GPAStat(84.88, 3.484, 22.0, list1));
    gpaList.add(GPAStat(77.72, 3.060, 25.0, list2));
    gpaList.add(GPAStat(85.86, 3.466, 29.5, list1));
    gpaList.add(GPAStat(89.00, 3.700, 1.0, list1));
    return AppBar(
      backgroundColor: const Color.fromRGBO(127, 139, 89, 1.0),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: GestureDetector(
            child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onTap: () => Navigator.pop(context)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.error_outline, color: Colors.white, size: 25),
              onTap: () {
                //TODO popup info
                Provider.of<GPANotifier>(context, listen: false).gpaStatsWithNotify = gpaList;
                ToastProvider.running('显示假数据');
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.loop, color: Colors.white, size: 25),
              onTap: Provider.of<GPANotifier>(context, listen: false).refreshGPA()),
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

  RadarChartWidget(this.notifier);

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
                    size: 150, color: Color.fromRGBO(172, 179, 146, 1)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                    "Radar & rose chart is not available with semesters of less than three courses.",
                    style: TextStyle(
                        color: Color.fromRGBO(178, 184, 153, 1), fontSize: 13)),
              )
            ],
          ),
        ),
      );
    else
      return Container(
        height: 350,
        child: CustomPaint(
          painter: _RadarChartPainter(_list),
          size: Size(double.maxFinite, 160),
        ),
      );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<GPACourse> courses;

  _RadarChartPainter(this.courses);

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
      ..color = Color.fromRGBO(135, 147, 99, 1)
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
      ..color = Color.fromRGBO(165, 176, 133, 1)
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
      ..color = Color.fromRGBO(237, 243, 229, 1.0)
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
              style: TextStyle(fontSize: 10, color: Colors.white)),
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

  GPAStatsWidget(this.notifier);

  static const textStyle = TextStyle(
      color: Color.fromRGBO(169, 179, 144, 1.0),
      fontWeight: FontWeight.bold,
      fontSize: 13.0);

  static const numStyle = TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.0);

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

  CourseListWidget(this.notifier);

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
              child: Text(
                  'ORDERED\tBY\t${widget.notifier.sortType.toUpperCase()}',
                  style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 4,
                      color: Color.fromRGBO(178, 184, 153, 1),
                      fontWeight: FontWeight.bold))),
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
                  color: Color.fromRGBO(136, 148, 102, 1),
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
                              color: Color.fromRGBO(178, 184, 153, 1),
                              size: 25),
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
                                        color: Colors.white)),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "${courses[i].classType} / ${courses[i].credit} Credits",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(
                                            178, 184, 153, 1))),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 15),
                          child: Text('${courses[i].score.round()}',
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
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
