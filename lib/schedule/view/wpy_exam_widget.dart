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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 0, 12),
              alignment: Alignment.centerLeft,
              child: Text('考表',
                  style: FontManager.YaQiHei.copyWith(
                      fontSize: 16,
                      color: Color.fromRGBO(100, 103, 122, 1),
                      fontWeight: FontWeight.bold)),
            ),
          ),
          _detail(notifier, context),
        ],
      );
    });
  }

  Widget _detail(ExamNotifier notifier, BuildContext context) {
    if (notifier.unscheduled.length == 0) {
      var msg = notifier.unfinished.length == 0 ? '目前没有考试哦' : '没有已安排时间的考试哦';
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
        child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 22),
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
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: notifier.unscheduled
              .map((e) => examCard(context, e, false, wpy: true))
              .toList(),
        ),
      );
    }
  }
}
