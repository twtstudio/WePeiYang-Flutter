// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show WpyDioError;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

class ExamPage extends StatefulWidget {
  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  _ExamPageState() {
    WePeiYangApp.navigatorState.currentContext!
        .read<ExamProvider>()
        .refreshExam();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      leading: GestureDetector(
          child: Icon(Icons.arrow_back,
              color: FavorColors.scheduleTitleColor, size: 32),
          onTap: () => Navigator.pop(context)),
      actions: [
        IconButton(
          icon: Icon(Icons.autorenew,
              color: FavorColors.scheduleTitleColor, size: 28),
          onPressed: () {
            if (CommonPreferences.isBindTju.value) {
              context.read<ExamProvider>().refreshExam(
                  hint: true,
                  onFailure: (e) {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => TjuRebindDialog(
                            reason:
                                e is WpyDioError ? e.error.toString() : null));
                  });
            } else {
              ToastProvider.error("请绑定办公网");
              Navigator.pushNamed(context, AuthRouter.tjuBind);
            }
          },
        ),
        SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Consumer<ExamProvider>(
          builder: (context, provider, _) {
            List<Widget> unfinished = provider.unfinished.isEmpty
                ? [
                    Center(
                        child: Text('没有未完成的考试哦',
                            style: FontManager.YaHeiLight.copyWith(
                                color: Colors.grey[400], fontSize: 12)))
                  ]
                : provider.unfinished
                    .map((e) => examCard(context, e, false))
                    .toList();
            List<Widget> finished = provider.finished.isEmpty
                ? [
                    Center(
                        child: Text('没有已完成的考试哦',
                            style: FontManager.YaHeiLight.copyWith(
                                color: Colors.grey[400], fontSize: 12)))
                  ]
                : provider.finished
                    .map((e) => examCard(context, e, true))
                    .toList();
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(height: 10),
                Text('未完成',
                    style: FontManager.YaQiHei.copyWith(
                        fontSize: 16,
                        color: FavorColors.scheduleTitleColor,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                ...unfinished,
                SizedBox(height: 15),
                Text('已完成',
                    style: FontManager.YaQiHei.copyWith(
                        fontSize: 16,
                        color: FavorColors.scheduleTitleColor,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                ...finished,
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget examCard(BuildContext context, Exam exam, bool finished,
    {bool wpy = false}) {
  int code = exam.name.hashCode + DateTime.now().day;
  var unfinishedColor = wpy
      ? FavorColors.homeSchedule[code % FavorColors.homeSchedule.length]
      : FavorColors.scheduleColor[code % FavorColors.scheduleColor.length];
  var name = exam.name;
  if (name.length >= 10) name = name.substring(0, 10) + '...';
  String remain = '';
  if (finished) {
    remain = '';
  } else if (exam.date == '时间未安排') {
    remain = 'Unknown';
  } else {
    var now = DateTime.now();
    var realNow = DateTime(now.year, now.month, now.day);
    var target = DateTime.parse(exam.date);
    var diff = target.difference(realNow).inDays;
    remain = (diff == 0) ? 'today' : '${diff}days';
  }
  var seat = exam.seat;
  if (seat != '地点未安排') seat = '座位' + seat;
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: finished ? Color.fromRGBO(236, 238, 237, 1) : unfinishedColor,
      ),
      child: InkWell(
        onTap: () {
          if (wpy) Navigator.pushNamed(context, ScheduleRouter.exam);
        },
        borderRadius: BorderRadius.circular(10),
        splashFactory: InkRipple.splashFactory,
        child: Stack(
          children: [
            DefaultTextStyle(
              style: TextStyle(
                  color: finished
                      ? Color.fromRGBO(205, 206, 210, 1)
                      : Colors.white),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: FontManager.YaQiHei.copyWith(fontSize: 20)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Spacer(),
                        Text(exam.arrange,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 17,
                            color: finished
                                ? Color.fromRGBO(205, 206, 210, 1)
                                : Colors.white),
                        SizedBox(width: 3),
                        Text('${exam.location}-$seat',
                            style:
                                FontManager.YaHeiLight.copyWith(fontSize: 14)),
                        Spacer(),
                        Text(exam.date,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 1,
              child: Text(remain,
                  style: FontManager.Bauhaus.copyWith(
                      height: 0,
                      fontSize: 55,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.4))),
            ),
          ],
        ),
      ),
    ),
  );
}
