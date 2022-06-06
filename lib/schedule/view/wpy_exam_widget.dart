import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/view/exam_page.dart';

class WpyExamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Consumer<ExamNotifier>(builder: (context, notifier, _) {
          if (notifier.hideExam) return Container();
          return Column(
            children: [
              SizedBox(height: 7),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text('考表',
                          style: FontManager.YaQiHei.copyWith(
                              fontSize: 16,
                              color: Color.fromRGBO(100, 103, 122, 1),
                              fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.keyboard_arrow_right,
                          color: ColorUtil.lightTextColor),
                      SizedBox(width: 5)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              _detail(notifier, context),
            ],
          );
        }));
  }

  Widget _detail(ExamNotifier notifier, BuildContext context) {
    if (notifier.unscheduled.length == 0) {
      var msg = CommonPreferences().isAprilFool.value
          ? '您最近有新的考试哦，打开考表查看详情'
          : notifier.unfinished.length == 0
              ? '目前没有考试哦'
              : '没有已安排时间的考试哦';
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
    } else if (notifier.unscheduled.length > 1) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: 110,
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: notifier.unscheduled
              .map((e) => SizedBox(
                  width: 300,
                  child: examCard(context, e, false, wpy: true)))
              .toList(),
        ),
      );
    } else
      return notifier.unscheduled
            .map((e) => examCard(context, e, false, wpy: true)).first;
  }
}
