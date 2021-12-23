import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/provider_widget.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_notifier.dart';

class ExamPage extends StatefulWidget {
  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  _ExamPageState() {
    Provider.of<ExamNotifier>(WePeiYangApp.navigatorState.currentContext,
            listen: false)
        .refreshExam()
        .call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamNotifier>(builder: (context, notifier, _) {
      List<Widget> after = notifier.afterNow.isEmpty
          ? [
              Center(
                  child: Text('没有未完成的考试哦',
                      style: FontManager.YaHeiLight.copyWith(
                          color: Colors.grey[400], fontSize: 12)))
            ]
          : notifier.afterNow.map((e) => examCard(context, e, true)).toList();
      List<Widget> before = notifier.beforeNow.isEmpty
          ? [
              Center(
                  child: Text('没有已完成的考试哦',
                      style: FontManager.YaHeiLight.copyWith(
                          color: Colors.grey[400], fontSize: 12)))
            ]
          : notifier.beforeNow.map((e) => examCard(context, e, false)).toList();
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          elevation: 0,
          leading: GestureDetector(
              child: Icon(Icons.arrow_back,
                  color: FavorColors.scheduleTitleColor(), size: 32),
              onTap: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: Icon(Icons.autorenew,
                  color: FavorColors.scheduleTitleColor(), size: 28),
              onPressed: () {
                if (CommonPreferences().isBindTju.value) {
                  Provider.of<ExamNotifier>(context, listen: false)
                      .refreshExam(
                          hint: true,
                          onFailure: (e) {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) =>
                                    TjuRebindDialog(
                                        reason: e is WpyDioError
                                            ? e.error.toString()
                                            : null));
                          })
                      .call();
                } else {
                  ToastProvider.error("请绑定办公网");
                  Navigator.pushNamed(context, AuthRouter.tjuBind);
                }
              },
            ),
            SizedBox(width: 10),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(height: 10),
              Text('未完成',
                  style: FontManager.YaQiHei.copyWith(
                      fontSize: 16,
                      color: FavorColors.scheduleTitleColor(),
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              ...after,
              SizedBox(height: 15),
              Text('已完成',
                  style: FontManager.YaQiHei.copyWith(
                      fontSize: 16,
                      color: FavorColors.scheduleTitleColor(),
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              ...before,
            ],
          ),
        ),
      );
    });
  }
}

Widget examCard(BuildContext context, Exam exam, bool afterNow,
    {bool wpy = false}) {
  int code = exam.name.hashCode + DateTime.now().day;
  var colorList = wpy ? FavorColors.homeSchedule : FavorColors.scheduleColor;
  var name = exam.name;
  if (name.length >= 10) name = name.substring(0, 10) + '...';
  String remain = '';
  if (!afterNow) {
    remain = '';
  } else if (exam.date == '时间未安排') {
    remain = 'Unknown';
  } else {
    var now = DateTime.now();
    var target = DateTime.parse(exam.date);
    remain = '${target.difference(now).inDays}days';
  }
  var seat = exam.seat;
  if (seat != '地点未安排') seat = '座位' + seat;
  return Padding(
       padding: const EdgeInsets.symmetric(vertical: 5),
    child: Material(
      borderRadius: BorderRadius.circular(15),
      color: afterNow
          ? colorList[code % FavorColors.scheduleColor.length]
          : Color.fromRGBO(236, 238, 237, 1),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (wpy) {
            Navigator.pushNamed(context, ScheduleRouter.exam);
          }
        },
        borderRadius: BorderRadius.circular(10),
        splashFactory: InkRipple.splashFactory,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                  color: afterNow
                      ? Colors.white
                      : Color.fromRGBO(205, 206, 210, 1)),
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(14, 13, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: FontManager.YaQiHei.copyWith(fontSize: 18)),
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
                            color: afterNow
                                ? Colors.white
                                : Color.fromRGBO(205, 206, 210, 1)),
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
                      color: Colors.white30)),
            ),
          ],
        ),
      ),
    ),
  );
}
