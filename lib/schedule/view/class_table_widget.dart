import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/extension/ui_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';

/// 课程表每个item之间的间距
const double cardStep = 6;

/// 这个Widget包括日期栏和下方的具体课程
class ClassTableWidget extends StatelessWidget {
  final Color titleColor;

  ClassTableWidget(this.titleColor);

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      var width = WePeiYangApp.screenWidth - 15 * 2;
      var dayCount = CommonPreferences().dayNumber.value;
      var cardWidth = (width - (dayCount - 1) * cardStep) / dayCount;
      return Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
        child: Column(
          children: [
            WeekDisplayWidget(cardWidth, notifier, dayCount, titleColor),
            SizedBox(height: cardStep),
            CourseDisplayWidget(
                width, cardWidth, notifier, dayCount, titleColor)
          ],
        ),
      );
    });
  }
}

class WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int dayCount;
  final Color titleColor;

  WeekDisplayWidget(
      this.cardWidth, this.notifier, this.dayCount, this.titleColor);

  @override
  Widget build(BuildContext context) {
    List<String> dates = getWeekDayString(
        notifier.termStart, notifier.selectedWeekWithNotify, dayCount);
    var now = DateTime.now();
    var month = now.month.toString();
    var day = now.day.toString();
    var nowDate =
        "${month.length < 2 ? '0' + month : month}/${day.length < 2 ? '0' + day : day}";
    return Row(
      children: dates
          .map((date) => _getCard(cardWidth, date, nowDate == date))
          .toList(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  /// 因为card组件宽度会比width小一些，不好对齐，因此用container替代
  Widget _getCard(double width, String date, bool deepColor) => Container(
        height: 28,
        width: width,
        decoration: BoxDecoration(
            color: deepColor
                ? CommonPreferences().isAprilFoolClass.value
                    ? ColorUtil.aprilFoolColor[Random().nextInt(4)]
                    // : titleColor
                    : Color.fromRGBO(255, 255, 255, 1)
                : Color.fromRGBO(246, 246, 246, 0.2),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(date,
              style: FontManager.Aspira.copyWith(
                  color: deepColor
                      ? Color.fromRGBO(44, 126, 223, 1)
                      : Color.fromRGBO(202, 202, 202, 1),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      );
}

class CourseDisplayWidget extends StatelessWidget {
  final double width;
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int dayCount;
  final Color titleColor;

  CourseDisplayWidget(this.width, this.cardWidth, this.notifier, this.dayCount,
      this.titleColor);

  /// 每一节小课对应的高度（据此，每一节大课的高度应为其两倍再加上step）
  static const double singleCourseHeight = 65;

  /// "午休"提示栏的高度
  static const double middleStep = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: singleCourseHeight * 12 + cardStep * 11 + middleStep,
      child: Stack(
        children: [
          Container(
            width: 360,
            height: 30,
            margin: EdgeInsetsDirectional.only(
                start: 10, top: 4 * singleCourseHeight + 3 * cardStep),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          Positioned(
            left: 10,
            top: 4 * singleCourseHeight + 3 * cardStep,
            width: 360,
            height: 30,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Expanded(child: Divider()),
              Text("LUNCH BREAK",
                  style: FontManager.YaQiHei.copyWith(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  )),
              // Expanded(child: Divider()),
            ]),
          ),
          ..._generatePositioned(context),
        ],
      ),
    );
  }

  List<Widget> _generatePositioned(BuildContext context) {
    if (notifier.coursesWithNotify.length == 0) return [];
    int dayNumber = CommonPreferences().dayNumber.value;
    List<Positioned> list = [];
    List<List<List<ScheduleCourse>>> merged =
        getMergedCourses(notifier, dayNumber);
    for (int i = 0; i < dayNumber; i++) {
      int day = i + 1;
      merged[i].forEach((courses) {
        int start = int.parse(courses[0].arrange.start);
        int end = int.parse(courses[0].arrange.end);
        double top =
            (start == 1) ? 0 : (start - 1) * (singleCourseHeight + cardStep);
        double left = (day == 1) ? 0 : (day - 1) * (cardWidth + cardStep);
        double height =
            (end - start + 1) * singleCourseHeight + (end - start) * cardStep;

        /// 绕开"午休"栏
        if (start > 4) top += middleStep;
        if (start <= 4 && end > 4) height += middleStep;
        list.add(Positioned(
            top: top,
            left: left,
            height: height,
            width: cardWidth,
            child: judgeActiveInWeek(notifier.selectedWeekWithNotify,
                    notifier.weekCount, courses[0])
                ? AnimatedActiveCourse(courses, width, height)
                : getQuietCourse(height, cardWidth, courses[0])));
      });
    }
    return list;
  }
}
