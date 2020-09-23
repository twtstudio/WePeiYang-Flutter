import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/gpa/gpa_curve_detail.dart' show GPACurve;
import 'package:wei_pei_yang_demo/gpa/gpa_service.dart';
import 'gpa_model.dart';
import 'gpa_notifier.dart';

class GPAPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GPAppBar(),
      backgroundColor: Color.fromRGBO(127, 139, 89, 1.0),
      body: Theme(
        /// 修改scrollView滚动至头/尾时溢出的颜色
        data: ThemeData(accentColor: Colors.white),
        child: ListView(
          children: [
            RadarChartWidget(),
            GPAStatsWidget(),
            GPACurve(isPreview: false),
            CourseListWidget()
          ],
        ),
      ),
    );
  }
}

class GPAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    List<Course> list1 = [];
    List<GPAStat> gpaList = [];
    list1.add(Course("高等数学2A", "数学", 6, 93));
    list1.add(Course("C/C++程序设计（双语）", "计算机", 3.5, 91));
    list1.add(Course("线性代数及其应用", "数学", 3.5, 94));
    list1.add(Course("思想道德修养与法律基础哈哈哈", "思想政治理论", 3, 55));
    list1.add(Course("大学英语1", "外语", 2, 97));
    list1.add(Course("计算机导论", "计算机", 1.5, 76));
    list1.add(Course("大学生心理健康", "文化素质教育必修", 1, 60));
    list1.add(Course("体育A", "体育", 1, 78));
    list1.add(Course("健康教育", "健康教育", 0.5, 86));
    list1.add(Course("大学计算机基础1", "计算机", 0, 100));
    List<Course> list2 = [];
    list2.add(Course("高等数学2A", "数学", 6, 63));
    list2.add(Course("C/C++程序设计（双语）", "计算机", 3.5, 25));
    list2.add(Course("线性代数及其应用", "数学", 3.5, 85));
    list2.add(Course("思想道德修养与法律基础哈哈哈", "思想政治理论", 3, 15));
    list2.add(Course("大学英语1", "外语", 2, 57));
    list2.add(Course("计算机导论", "计算机", 1.5, 86));
    list2.add(Course("大学生心理健康", "文化素质教育必修", 1, 47));
    list2.add(Course("体育A", "体育", 1, 23));
    list2.add(Course("健康教育", "健康教育", 0.5, 47));
    list2.add(Course("大学计算机基础1", "计算机", 0, 11));
    gpaList.add(GPAStat(84.88, 3.484, 22.0, list1));
    gpaList.add(GPAStat(77.72, 3.060, 25.0, list2));
    gpaList.add(GPAStat(85.86, 3.466, 29.5, list1));
    gpaList.add(GPAStat(89.00, 3.700, 1.0, list1));
    return AppBar(
      backgroundColor: Color.fromRGBO(127, 139, 89, 1.0),
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
                Provider.of<GPANotifier>(context).listWithNotify = gpaList;
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.loop, color: Colors.white, size: 25),
              onTap: () {
                getGPABean(onSuccess: (list) {
                  Provider.of<GPANotifier>(context).listWithNotify = list;
                }, onFailure: (e) {
                  Fluttertoast.showToast(
                      msg: "刷新gpa数据失败",
                      textColor: Colors.white,
                      backgroundColor: Colors.red,
                      timeInSecForIosWeb: 1,
                      fontSize: 16);
                });
              }),
        ),
      ],
    );
  }

  /// 使用标准的appBar高度
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class RadarChartWidget extends StatefulWidget {
  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChartWidget> {
  List<Course> list = [];

  /// isTaped为true时雷达图有透明度
  bool isTaped = false;

  static Timer timer;

  @override
  Widget build(BuildContext context) {
    return Consumer<GPANotifier>(builder: (context, gpaNotifier, _) {
      list = gpaNotifier.coursesWithNotify;
      return GestureDetector(
        onTapDown: (TapDownDetails detail) {
          setState(() {
            isTaped = true;
            list.shuffle();
          });

          /// 重复点击雷达图时，timer重新计时
          if (timer != null && timer.isActive) timer.cancel();
          timer = Timer(Duration(milliseconds: 300), () {
            setState(() => isTaped = false);
          });
        },
        child: Opacity(
          opacity: isTaped ? 0.2 : 1,
          child: _judgeListLength(list),
        ),
      );
    });
  }

  Widget _judgeListLength(List<Course> list) {
    if (list.length < 3)
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
          painter: _RadarChartPainter(list),
          size: Size(double.maxFinite, 160),
        ),
      );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<Course> courses;

  _RadarChartPainter(this.courses);

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
    outer = size.height / 2;
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
  static const textStyle = TextStyle(
      color: Color.fromRGBO(169, 179, 144, 1.0),
      fontWeight: FontWeight.bold,
      fontSize: 13.0);

  static const numStyle = TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.0);

  @override
  Widget build(BuildContext context) {
    return Consumer<GPANotifier>(builder: (context, gpaNotifier, _) {
      var weighted = "不";
      var gpa = "知";
      var credits = "道";
      if (gpaNotifier.currentDataWithNotify != null) {
        weighted = gpaNotifier.currentDataWithNotify[0].toString();
        gpa = gpaNotifier.currentDataWithNotify[1].toString();
        credits = gpaNotifier.currentDataWithNotify[2].toString();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            /// InkResponse provides splashes which can extend outside its bounds
            InkResponse(
              onTap: () => gpaNotifier.typeWithNotify = 0,
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
            InkResponse(
              onTap: () => gpaNotifier.typeWithNotify = 1,
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
            InkResponse(
              onTap: () => gpaNotifier.typeWithNotify = 2,
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
    });
  }
}

class CourseListWidget extends StatefulWidget {
  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseListWidget> {
  static final double cardHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Consumer<GPANotifier>(builder: (context, gpaNotifier, _) {
      var courses = gpaNotifier.coursesWithNotify;
      return Column(
        children: [
          GestureDetector(
            onTap: () => gpaNotifier.reSort(),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'O R D E R E D    B Y    ${gpaNotifier.sortType.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 15,
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
                                      child: Text(courses[i].name,
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
                                padding: EdgeInsets.symmetric(horizontal: 15),
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
    });
  }
}
