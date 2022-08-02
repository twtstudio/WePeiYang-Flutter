// @dart = 2.12
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

/// 用这两个变量绘制点阵图
const double _cubeSideLength = 6;
const double _spacingLength = 2;

/// 点阵图的宽高
double get _canvasWidth {
  var count = CommonPreferences.dayNumber.value;
  return _cubeSideLength * count + _spacingLength * (count - 1);
}

const double _canvasHeight = _cubeSideLength * 5 + _spacingLength * 4;

/// 星期切换栏
class WeekSelectWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var listView = Builder(
      builder: (context) {
        var provider = context.watch<CourseProvider>();
        var current = provider.currentWeek;
        if (current == 1) current++;

        double offset = WePeiYangApp.screenWidth / 4 - _canvasWidth - 25;
        if (offset < 0) offset = 0;
        return ListView.builder(
            itemCount: provider.weekCount,
            scrollDirection: Axis.horizontal,
            controller: ScrollController(
                initialScrollOffset:
                    (current - 2) * (_canvasWidth + 25 + offset)),
            itemBuilder: (context, i) {
              /// 为了让splash起到遮挡的效果,故而把InkWell放在Stack顶层
              return Padding(
                padding: EdgeInsets.only(left: offset),
                child: Stack(
                  children: [
                    _getContent(provider, i),

                    /// 波纹效果蒙版，加上material使inkwell能在list中显示出来
                    SizedBox(
                      height: _canvasHeight + 20,
                      width: _canvasWidth + 25,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          radius: 5000,
                          borderRadius: BorderRadius.circular(5),
                          splashColor: Color.fromRGBO(246, 246, 246, 0.5),
                          highlightColor: Colors.transparent,
                          onTap: () => provider.selectedWeek = i + 1,
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      },
    );

    return Theme(
      data: ThemeData(accentColor: Colors.white),
      child: Builder(
        builder: (context) {
          var shrink =
              context.select<CourseDisplayProvider, bool>((p) => p.shrink);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: shrink ? 0 : 90,
            child: shrink ? Container() : listView,
          );
        },
      ),
    );
  }

  Widget _getContent(CourseProvider provider, int i) {
    return Column(
      children: [
        Container(
          height: _canvasHeight + 20,
          width: _canvasWidth + 25,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: _WeekSelectPainter(
              getBoolMatrix(i + 1, provider.weekCount, provider.totalCourses),
              i + 1 == provider.selectedWeek,
            ),
            size: Size(_canvasWidth, _canvasHeight),
          ),
        ),
        SizedBox(height: 3),
        Text('WEEK ${i + 1}',
            style: FontManager.Aspira.copyWith(
                color: (provider.selectedWeek == i + 1)
                    ? Color.fromRGBO(255, 255, 255, 1)
                    : Color.fromRGBO(255, 255, 255, 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w900))
      ],
    );
  }
}

class _WeekSelectPainter extends CustomPainter {
  final List<List<bool>> _list;
  final bool _selected;

  _WeekSelectPainter(this._list, this._selected) {
    if (!_selected) {
      _cubePaint.color = _cubePaint.color.withOpacity(0.4);
      _spacePaint.color = _spacePaint.color.withOpacity(0.4);
    }
  }

  /// 深色cube，代表该点有课
  final Paint _cubePaint = Paint()
    ..color = Color.fromRGBO(255, 188, 107, 1)
    ..style = PaintingStyle.fill;

  /// 白色cube，代表该点没课
  final Paint _spacePaint = Paint()
    ..color = Color.fromRGBO(255, 255, 255, 1)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (var j = 0; j < _list.length; j++) {
      for (var k = 0; k < _list[j].length; k++) {
        var centerX =
            k * (_cubeSideLength + _spacingLength) + _cubeSideLength / 2;
        var centerY =
            j * (_cubeSideLength + _spacingLength) + _cubeSideLength / 2;
        Rect rect = Rect.fromCircle(
            center: Offset(centerX, centerY), radius: _cubeSideLength / 2);
        RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(2));

        if ((j == 0 && k == 0) ||
            (j == 1 && k == 0) ||
            (j == 1 && k == 1) ||
            (j == 2 && k == 2) ||
            (j == 3 && k == 2)) _list[j][k] = true;

        if (_list[j][k]) {
          canvas.drawRRect(rRect, _cubePaint);
        } else {
          canvas.drawRRect(rRect, _spacePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
