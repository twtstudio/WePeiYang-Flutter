import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/view/exam_page.dart';

class WpyExamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExamNotifier>(builder: (context, notifier, _) {
      if (notifier.hideExam) return Container();
      return Column(
        children: [
          SizedBox(height: 7),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text('考表',
                  style: FontManager.YaQiHei.copyWith(
                      fontSize: 16,
                      color: Color.fromRGBO(100, 103, 122, 1),
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 5),
          _detail(notifier, context),
        ],
      );
    });
  }

  Widget _detail(ExamNotifier notifier, BuildContext context) {
    if (notifier.afterNowReal.length == 0) {
      var msg = notifier.afterNow.length == 0 ? '目前没有考试哦' : '没有已安排时间的考试哦';
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
        child: Container(
            height: 60,
            decoration: BoxDecoration(
                color: Color.fromRGBO(236, 238, 237, 1),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(msg,
                  style: FontManager.YaHeiLight.copyWith(
                      color: Color.fromRGBO(207, 208, 212, 1),
                      fontSize: 14,
                      letterSpacing: 0.5)),
            )),
      );
    } else if (notifier.afterNowReal.length > 1) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: 160,
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: notifier.afterNowReal
              .map((e) => examCard(context, e, true, wpy: true))
              .toList(),
        ),
      );
    } else return Column(
      children: notifier.afterNowReal
          .map((e) => examCard(context, e, true, wpy: true))
          .toList(),
    );
  }
}
