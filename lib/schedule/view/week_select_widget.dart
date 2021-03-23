import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/main.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';

/// 用这两个变量绘制点阵图（改的时候如果overflow了就改一下下方container的height）
const double cubeSideLength = 6;
const double spacingLength = 4;

class WeekSelectWidget extends StatefulWidget {
  @override
  _WeekSelectWidgetState createState() => _WeekSelectWidgetState();
}

class _WeekSelectWidgetState extends State<WeekSelectWidget> {
  @override
  Widget build(BuildContext context) {
    var canvasWidth = cubeSideLength * 6 + spacingLength * 5;
    var canvasHeight = cubeSideLength * 5 + spacingLength * 4;
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      int current = Provider.of<ScheduleNotifier>(context, listen: false)
          .currentWeek;
      if (current == 1) current++;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 85,
        child: ListView.builder(
            itemCount: notifier.weekCount,
            scrollDirection: Axis.horizontal,
            controller: ScrollController(
                initialScrollOffset: (current - 2) * (canvasWidth + 30)),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 30, 0),

                /// 为了让splash起到遮挡的效果,故而把InkWell放在Stack顶层
                child: Stack(
                  children: [
                    Column(
                      children: [
                        CustomPaint(
                          painter: _WeekSelectPainter(getBoolMatrix(
                              i + 1,
                              notifier.weekCount,
                              notifier.coursesWithNotify,
                              false)),
                          size: Size(canvasWidth, canvasHeight),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('WEEK ${i + 1}',
                              style: TextStyle(
                                  color:
                                      (notifier.selectedWeekWithNotify == i + 1)
                                          ? Colors.black
                                          : Color.fromRGBO(200, 200, 200, 1),
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
                            notifier.selectedWeekWithNotify = i + 1;
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

  /// 每次退出课程表页面，重新设置选中星期为当前星期
  @override
  void dispose() {
    Provider.of<ScheduleNotifier>(WeiPeiYangApp.navigatorState.currentContext,
            listen: false)
        .quietResetWeek();
    super.dispose();
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
