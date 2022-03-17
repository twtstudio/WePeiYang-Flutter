// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

/// 用这两个变量绘制点阵图（改的时候如果overflow了就改一下下方container的height）
const double _cubeSideLength = 6;
const double _spacingLength = 4;

/// 点阵图的宽高
const double _canvasWidth = _cubeSideLength * 6 + _spacingLength * 5;
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
                    _getContent(context, provider, i),

                    /// 波纹效果蒙版，加上material使inkwell能在list中显示出来
                    SizedBox(
                      height: _canvasHeight + 25,
                      width: _canvasWidth + 25,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          radius: 5000,
                          splashColor: Color.fromRGBO(255, 255, 255, 0.85),
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

  Widget _getContent(BuildContext context, CourseProvider provider, int i) {
    return Column(
      children: [
        Container(
          height: _canvasHeight + 20,
          width: _canvasWidth + 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: i + 1 == provider.selectedWeek
                ? Color.fromRGBO(245, 245, 245, 1)
                : null,
            borderRadius: BorderRadius.circular(5),
          ),
          child: CustomPaint(
            painter: _WeekSelectPainter(getBoolMatrix(
                i + 1, provider.weekCount, provider.courses)),
            size: const Size(_canvasWidth, _canvasHeight),
          ),
        ),
        SizedBox(height: 3),
        Text('WEEK ${i + 1}',
            style: FontManager.Aspira.copyWith(
                color: (provider.selectedWeek == i + 1)
                    ? Colors.black
                    : Color.fromRGBO(200, 200, 200, 1),
                fontSize: 11,
                fontWeight: FontWeight.bold))
      ],
    );
  }
}

class _WeekSelectPainter extends CustomPainter {
  final List<List<bool>> _list;

  _WeekSelectPainter(this._list);

  /// 深色cube，代表该点有课
  final Paint _cubePaint = Paint()
    ..color = FavorColors.scheduleColor.first
    ..style = PaintingStyle.fill;

  /// 浅色cube，代表该点没课
  final Paint _spacePaint = Paint()
    ..color = Color.fromRGBO(230, 230, 230, 1)
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
