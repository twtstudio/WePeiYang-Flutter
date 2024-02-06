import 'dart:async' show Timer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/gpa/model/color.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_model.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/gpa/view/classes_need_vpn_dialog.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';

class GPAPage extends StatefulWidget {
  @override
  _GPAPageState createState() => _GPAPageState();
}

class _GPAPageState extends State<GPAPage> {
  late final List<Color> _gpaColors = GPAColor.blue(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CommonPreferences.firstClassesDialog.value) {
        CommonPreferences.firstClassesDialog.value = false;
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ClassesNeedVPNDialog());
      }

      // 绑定办公网判断
      if (!CommonPreferences.isBindTju.value) {
        Navigator.pushNamed(context, AuthRouter.tjuBind);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark
          .copyWith(systemNavigationBarColor: _gpaColors[0]),
      child: Scaffold(
        appBar: GPAAppBar(_gpaColors),
        backgroundColor: _gpaColors[0],
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0,
                  0.8
                ],
                colors: [
                  _gpaColors[0],
                  _gpaColors[2],
                ]),
          ),
          child: Theme(
            /// 修改scrollView滚动至头/尾时溢出的颜色
            data: Theme.of(context).copyWith(
                secondaryHeaderColor:
                    WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor)),
            child: ListView(
              children: [
                RadarChartWidget(_gpaColors),
                GPAStatsWidget(_gpaColors),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                context.watch<GPANotifier>().curveData.length >
                                        4
                                    ? 800.w
                                    : 1.sw),
                        child: GPACurve(_gpaColors, isPreview: false))),
                CourseListWidget(_gpaColors)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GPAAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Color> gpaColors;

  GPAAppBar(this.gpaColors);

  @override
  Widget build(BuildContext context) {
    var leading = Align(
      alignment: Alignment.centerRight,
      child: WButton(
        onPressed: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.fromLTRB(0, 8.h, 8.w, 8.h),
          child: SvgPicture.asset(
            "assets/svg_pics/lake_butt_icons/back.svg",
            width: 18.r,
            height: 18.r,
            color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          ),
        ),
      ),
    );

    return AppBar(
      backgroundColor: gpaColors[0],
      elevation: 0,
      leading: leading,
      leadingWidth: 40.w,
      title: Text(
          'HELLO${(CommonPreferences.lakeNickname.value == '') ? '' : ', ${CommonPreferences.lakeNickname.value}'}',
          style: TextUtil.base.reverse(context).w900.sp(18)),
      titleSpacing: 0,
      actions: [
        WButton(
          child: SvgPicture.asset(
            "assets/svg_pics/lake_butt_icons/refreash.svg",
            color: gpaColors[1],
            width: 28.w,
            height: 28.h,
          ),
          onPressed: () {
            if (CommonPreferences.tjuuname.value == '') {
              Navigator.pushNamed(context, AuthRouter.tjuBind);
            } else {
              context.read<GPANotifier>().refreshGPABackend(context);
            }
          },
        ),
        SizedBox(width: 18.w),
      ],
    );
  }

  /// 使用标准的appBar高度
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class RadarChartWidget extends StatefulWidget {
  final List<Color> gpaColors;

  RadarChartWidget(this.gpaColors);

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChartWidget> {
  /// isTaped为true时雷达图有透明度
  bool _isTaped = false;

  static Timer? _timer;

  @override
  Widget build(BuildContext context) {
    var _list = context.select<GPANotifier, List<GPACourse>>(
        (p) => p.courses.where((e) => e.score != 0.0).toList());
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isTaped = true;
          _list.shuffle();
        });

        /// 重复点击雷达图时，timer重新计时
        if (_timer != null && _timer!.isActive) _timer!.cancel();
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
        height: 350,
        padding: const EdgeInsets.symmetric(horizontal: 65),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 30),
              child:
                  Icon(Icons.assessment, size: 150, color: widget.gpaColors[2]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                  "Radar & Rose chart is not available with semesters of less than three courses.",
                  style: TextUtil.base.Swis
                      .sp(13)
                      .customColor(widget.gpaColors[2])),
            )
          ],
        ),
      );
    else
      return SizedBox(
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

  /// 用这个控制雷达图大小,不能低于2
  static const double radarChartRatio = 2.15;
  late double centerX;
  late double centerY;
  late double outer;
  late double inner;
  late double middle;
  late double slice;
  List<Offset> outerPoints = [];
  List<Offset> innerPoints = [];
  List<Offset> middlePoints = [];

  double _count(double x) => pow(pow(x, 2) / 100, 2) / 10000;

  final Paint _creditPaint = Paint()
    ..color = ColorUtil.grey178
    ..style = PaintingStyle.fill;

  _drawCredit(Canvas canvas, Size size) {
    double maxCredit = 0;
    courses.forEach((element) {
      if (element.credit > maxCredit) maxCredit = element.credit;
    });
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
    canvas.drawPath(creditPath, _creditPaint);
  }

  final Paint _fillPaint = Paint()
    ..color = ColorUtil.grey230
    ..style = PaintingStyle.fill;

  _drawScoreFill(Canvas canvas) {
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
    canvas.drawPath(fillPath, _fillPaint);
  }

  final Paint _linePaint = Paint()
    ..color = ColorUtil.yellow158
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  _drawLine(Canvas canvas) {
    final Path linePath = Path();
    for (var i = 0; i < courses.length; i++) {
      linePath
        ..moveTo(centerX, centerY)
        ..lineTo(innerPoints[i].dx, innerPoints[i].dy);
    }
    canvas.drawPath(linePath, _linePaint);
  }

  _drawScoreOutLine(Canvas canvas) {
    final Paint _outLinePaint = Paint()
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
    canvas.drawPath(outLinePath, _outLinePaint);
  }

  _drawText(Canvas canvas) {
    for (var i = 0; i < courses.length; i++) {
      var textPainter = TextPainter(
          text: TextSpan(
              text: _formatText(courses[i].name),
              style: TextUtil.base.w300.sp(9).customColor(gpaColors[1])),
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

class GPAStatsWidget extends StatelessWidget {
  final TextStyle _textStyle;
  final TextStyle _numStyle;

  GPAStatsWidget(List<Color> gpaColors)
      : _textStyle = TextUtil.base.Swis.bold.sp(13).customColor(gpaColors[2]),
        _numStyle = TextUtil.base.Swis.bold.sp(24).customColor(gpaColors[1]);

  @override
  Widget build(BuildContext context) {
    var statsData =
        context.select<GPANotifier, List<double>>((p) => p.statsData);
    var weighted = "不";
    var gpa = "知";
    var credits = "道";
    if (statsData.isNotEmpty) {
      weighted = statsData[0].toString();
      gpa = statsData[1].toString();
      credits = statsData[2].toString();
    }
    var quietPvd = context.read<GPANotifier>();
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /// "InkResponse provides splashes which can extend outside its bounds"
          InkResponse(
            onTap: () => quietPvd.type = 0,
            radius: 45,

            /// "defines a splash that spreads out more aggressively than the default"
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Weighted', style: _textStyle),
                SizedBox(height: 8),
                Text(weighted, style: _numStyle)
              ],
            ),
          ),

          /// 这里加个padding，让UI分布更均匀
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: InkResponse(
              onTap: () => quietPvd.type = 1,
              radius: 45,
              splashFactory: InkRipple.splashFactory,
              child: Column(
                children: <Widget>[
                  Text('GPA', style: _textStyle),
                  SizedBox(height: 8),
                  Text(gpa, style: _numStyle)
                ],
              ),
            ),
          ),
          InkResponse(
            onTap: () => quietPvd.type = 2,
            radius: 45,
            splashFactory: InkRipple.splashFactory,
            child: Column(
              children: <Widget>[
                Text('Credits', style: _textStyle),
                SizedBox(height: 8),
                Text(credits, style: _numStyle)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseListWidget extends StatelessWidget {
  final List<Color> _gpaColors;
  static const double _cardHeight = 82;

  CourseListWidget(this._gpaColors);

  @override
  Widget build(BuildContext context) {
    return Selector<GPANotifier, List<GPACourse>>(
      selector: (BuildContext, provider) => provider.courses,
      builder: (BuildContext context, courses, Widget? child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              child!,
              SizedBox(
                height: _cardHeight * courses.length,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, i) => Container(
                          height: _cardHeight,
                          padding: const EdgeInsets.fromLTRB(30, 2, 30, 2),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: 0.2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _gpaColors[3],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              Card(
                                color: ColorUtil.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {},
                                  splashFactory: InkRipple.splashFactory,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Icon(Icons.assignment_turned_in,
                                          color: _gpaColors[1], size: 25),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  _formatText(courses[i].name),
                                                  style: TextUtil.base.regular
                                                      .sp(14)
                                                      .customColor(
                                                          _gpaColors[1])),
                                            ),
                                            SizedBox(height: 2),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  "${courses[i].classType} / ${courses[i].credit} 学分",
                                                  style: TextUtil.base.w300
                                                      .sp(11)
                                                      .customColor(
                                                          _gpaColors[1])),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                          '${courses[i].score == 0.0 ? courses[i].rawScore : courses[i].score.round()}',
                                          style: TextUtil.base.Swis.bold
                                              .sp(26)
                                              .customColor(_gpaColors[1])),
                                      SizedBox(width: 18)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
              )
            ],
          ),
        );
      },
      child: WButton(
        onPressed: () => context.read<GPANotifier>().reSort(),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Builder(
              builder: (context) {
                var sortType = context
                    .select<GPANotifier, String>((p) => p.sortType)
                    .toUpperCase();
                return RichText(
                    text: TextSpan(
                        text: 'ORDERED\tBY\t',
                        style: TextUtil.base.Swis
                            .sp(14)
                            .customColor(_gpaColors[2])
                            .space(letterSpacing: 4),
                        children: <TextSpan>[
                      TextSpan(
                          text: sortType,
                          style: TextUtil.base.Swis.bold
                              .sp(14)
                              .customColor(_gpaColors[1])
                              .space(letterSpacing: 4))
                    ]));
              },
            )),
      ),
    );
  }

  String _formatText(String text) =>
      text.length >= 12 ? '${text.substring(0, 11)}...' : text;
}
