import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/view/schedule_page.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

/// 用这两个变量绘制点阵图（改的时候如果overflow了就改一下下方container的height）
const double cubeSideLength = 6;
const double spacingLength = 4;

class WeekSelectWidget extends StatelessWidget {
  final canvasWidth = cubeSideLength * 6 + spacingLength * 5;
  final canvasHeight = cubeSideLength * 5 + spacingLength * 4;

  @override
  Widget build(BuildContext context) {
    double offset = WePeiYangApp.screenWidth / 4 - canvasWidth - 25;
    if (offset < 0) offset = 0;
    return ValueListenableBuilder(
      valueListenable:
          context.findAncestorWidgetOfExactType<SchedulePage>().isShrink,
      builder: (_, isShrink, __) {
        return Consumer<ScheduleNotifier>(builder: (_, notifier, __) {
          int current =
              Provider.of<ScheduleNotifier>(context, listen: false).currentWeek;
          if (current == 1) current++;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isShrink ? 45 : 90,
            child: ListView.builder(
                itemCount: notifier.weekCount,
                scrollDirection: Axis.horizontal,
                controller: ScrollController(
                    initialScrollOffset:
                        (current - 2) * (canvasWidth + 25 + offset)),
                itemBuilder: (_, i) {
                  /// 为了让splash起到遮挡的效果,故而把InkWell放在Stack顶层
                  return Padding(
                    padding: EdgeInsets.only(left: offset),
                    child: Stack(
                      children: [
                        getContent(context, notifier, i, isShrink),

                        /// 波纹效果蒙版，加上material使inkwell能在list中显示出来
                        SizedBox(
                          height: isShrink ? 45 : canvasHeight + 25,
                          width: canvasWidth + 25,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              radius: 5000,
                              splashColor: Color.fromRGBO(255, 255, 255, 0.85),
                              highlightColor: Colors.transparent,
                              onTap: () =>
                                  notifier.selectedWeekWithNotify = i + 1,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          );
        });
      },
    );
  }

  Widget getContent(
      BuildContext context, ScheduleNotifier notifier, int i, bool isShrink) {
    if (isShrink) {
      return Container(
        height: 45,
        width: canvasWidth + 25,
        decoration: BoxDecoration(
            color: i + 1 == notifier.selectedWeekWithNotify
                ? Color.fromRGBO(245, 245, 245, 1)
                : null,
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text('WEEK ${i + 1}',
              style: FontManager.Aspira.copyWith(
                  color: (notifier.selectedWeekWithNotify == i + 1)
                      ? Colors.black
                      : Color.fromRGBO(200, 200, 200, 1),
                  fontSize: isShrink ? 12 : 11,
                  fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            height: canvasHeight + 20,
            width: canvasWidth + 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: i + 1 == notifier.selectedWeekWithNotify
                    ? Color.fromRGBO(245, 245, 245, 1)
                    : null,
                borderRadius: BorderRadius.circular(5)),
            child: CustomPaint(
              painter: _WeekSelectPainter(getBoolMatrix(i + 1,
                  notifier.weekCount, notifier.coursesWithNotify, false)),
              size: Size(canvasWidth, canvasHeight),
            ),
          ),
          SizedBox(height: 3),
          Text('WEEK ${i + 1}',
              style: FontManager.Aspira.copyWith(
                  color: (notifier.selectedWeekWithNotify == i + 1)
                      ? Colors.black
                      : Color.fromRGBO(200, 200, 200, 1),
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ],
      );
    }
  }
}

class _WeekSelectPainter extends CustomPainter {
  final List<List<bool>> list;

  _WeekSelectPainter(this.list);

  @override
  void paint(Canvas canvas, Size size) {
    for (var j = 0; j < list.length; j++) {
      for (var k = 0; k < list[j].length; k++) {
        var centerX = k * (cubeSideLength + spacingLength) + cubeSideLength / 2;
        var centerY = j * (cubeSideLength + spacingLength) + cubeSideLength / 2;
        Rect rect = Rect.fromCircle(
            center: Offset(centerX, centerY), radius: cubeSideLength / 2);
        RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(2));
        if (list[j][k]) {
          /// 深色cube，代表该点有课
          final Paint cubePaint = Paint()
            ..color = FavorColors.scheduleColor.first
            ..style = PaintingStyle.fill;
          canvas.drawRRect(rRect, cubePaint);
        } else {
          /// 浅色cube，代表该点没课
          final Paint spacePaint = Paint()
            ..color = Color.fromRGBO(230, 230, 230, 1)
            ..style = PaintingStyle.fill;
          canvas.drawRRect(rRect, spacePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
