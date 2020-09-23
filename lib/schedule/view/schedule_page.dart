import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScheduleAppBar(),
      body: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: Container(
          color: Colors.white,
          //TODO 记得改回padding
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
            children: [TitleWidget(), IndicatorGridWidget()],
          ),
        ),
      ),
    );
  }
}

class ScheduleAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: GestureDetector(
            child: Icon(Icons.arrow_back,
                color: Color.fromRGBO(105, 109, 126, 1), size: 28),
            onTap: () => Navigator.pop(context)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.autorenew,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 25),
              onTap: () {
                //TODO refresh
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.add,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 30),
              onTap: () {
                // TODO 更多功能
              }),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(
        builder: (context, notifier, _) => Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Text('Schedule',
                      style: TextStyle(
                          color: Color.fromRGBO(105, 109, 126, 1),
                          fontSize: 35,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 12),
                    child: Text('WEEK ${notifier.selectedWeek}',
                        style: TextStyle(
                            color: Color.fromRGBO(220, 220, 220, 1),
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ));
  }
}

/// 用这两个变量绘制点阵图
const double cubeSideLength = 6;
const double spacingLength = 4;

class IndicatorGridWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var canvasWidth = cubeSideLength * 6 + spacingLength * 5;
    var canvasHeight = cubeSideLength * 5 + spacingLength * 4;
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      return Container(
        height: 90,
        child: ListView.builder(
            itemCount: notifier.weekCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 28, 0),
                /// 为了让splash起到遮挡的效果,故而把InkWell放在Stack顶层
                child: Stack(
                  children: [
                    Column(
                      children: [
                        CustomPaint(
                          painter: _IndicatorGridPainter(notifier.testList),
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

class _IndicatorGridPainter extends CustomPainter {
  final List<List<bool>> list;

  _IndicatorGridPainter(this.list);

  @override
  void paint(Canvas canvas, Size size) {
    /// 深色cube，代表该点有课
    final Paint cubePaint = Paint()
      ..color = Color.fromRGBO(105, 109, 126, 1)
      ..style = PaintingStyle.fill;
    /// 浅色cube，代表该点没课
    final Paint spacePaint = Paint()
      ..color = Color.fromRGBO(230, 230, 230, 1)
      ..style = PaintingStyle.fill;
    for (var j = 0; j < list.length; j++) {
      for (var k = 0; k < list[j].length; k++) {
        var centerX = k * (cubeSideLength + spacingLength) + cubeSideLength / 2;
        var centerY = j * (cubeSideLength + spacingLength) + cubeSideLength / 2;
        Rect rect = Rect.fromCircle(
            center: Offset(centerX, centerY), radius: cubeSideLength / 2);
        RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(2));
        if (list[j][k])
          canvas.drawRRect(rRect, cubePaint);
        else
          canvas.drawRRect(rRect, spacePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
