import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

/// 用这两个变量绘制点阵图（改的时候如果overflow了就改一下下方container的height）
const double cubeSideLength = 6;
const double spacingLength = 4;

class WeekSelectWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var canvasWidth = cubeSideLength * 6 + spacingLength * 5;
    var canvasHeight = cubeSideLength * 5 + spacingLength * 4;
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      return Container(
        height: 85,
        child: ListView.builder(
            itemCount: notifier.weekCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 30, 0),

                // TODO 此处有个小bug，刷新数据后并不重绘
                /// 为了让splash起到遮挡的效果,故而把InkWell放在Stack顶层
                child: Stack(
                  children: [
                    Column(
                      children: [
                        CustomPaint(
                          painter: _WeekSelectPainter(
                              getBoolMatrix(i + 1, notifier.weekCount,
                                  notifier.coursesWithNotify, false),
                              notifier.selectedWeek == i + 1),
                          size: Size(canvasWidth, canvasHeight),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('WEEK ${i + 1}',
                              style: TextStyle(
                                  color: Color.fromRGBO(200, 200, 200, 1),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    Container(
                      height: 75,
                      width: canvasWidth,

                      /// 加上material使inkwell能在list中显示出来
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          radius: 5000,
                          splashColor: Color.fromRGBO(255, 255, 255, 0.85),
                          highlightColor: Colors.transparent,
                          onTap: () {
                            notifier.selectedWeek = i + 1;
                          },
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
      );
    });
  }
}

class _WeekSelectPainter extends CustomPainter {
  final List<List<bool>> list;
  final bool isSelected;

  _WeekSelectPainter(this.list, this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    for (var j = 0; j < list.length; j++) {
      for (var k = 0; k < list[j].length; k++) {
        var centerX = k * (cubeSideLength + spacingLength) + cubeSideLength / 2;
        var centerY = j * (cubeSideLength + spacingLength) + cubeSideLength / 2;
        Rect rect = Rect.fromCircle(
            center: Offset(centerX, centerY), radius: cubeSideLength / 2);
        RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(2));
        if (isSelected && list[j][k]) {
          /// 亮色cube，代表本周被选中
          final Paint selectedPaint = Paint()
            ..color = Color.fromRGBO(158, 119, 138, 1)
            ..style = PaintingStyle.fill;
          canvas.drawRRect(rRect, selectedPaint);
        } else if (list[j][k]) {
          /// 深色cube，代表该点有课
          final Paint cubePaint = Paint()
            ..color = Color.fromRGBO(105, 109, 126, 1)
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
