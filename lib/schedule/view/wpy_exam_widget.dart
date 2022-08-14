// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/exam_page.dart';

class WpyExamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 5),
        child: Consumer<ExamProvider>(
          builder: (context, provider, child) {
            if (provider.hideExam) return Container();
            return _detail(provider, context);
          },
        ));
  }

  Widget _detail(ExamProvider provider, BuildContext context) {
    if (provider.unscheduled.length == 0) {
      var msg = CommonPreferences.isAprilFool.value
          ? '您最近有新的考试哦，打开考表查看详情'
          : provider.unfinished.length == 0
              ? '目前没有考试哦'
              : '没有已安排时间的考试哦';
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
        child: Container(
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(msg,
                  style: FontManager.YaHeiLight.copyWith(
                      color: Color.fromRGBO(207, 208, 212, 1),
                      fontSize: 14,
                      letterSpacing: 0.5)),
            )),
      );
    } else if (provider.unscheduled.length > 1) {
      return Container(
        constraints: BoxConstraints(maxHeight: 110),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: provider.unscheduled
              .map((e) => SizedBox(
                  width: 300, child: examCard(context, e, false, wpy: true)))
              .toList(),
        ),
      );
    } else
      return provider.unscheduled
            .map((e) => examCard(context, e, false, wpy: true)).first;
  }
}
