import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/extension/ui_extension.dart';

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
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
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
            color: deepColor ? titleColor : Color.fromRGBO(236, 238, 237, 1.0),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(date,
              style: FontManager.Aspira.copyWith(
                  color: deepColor
                      ? Colors.white
                      : Color.fromRGBO(200, 200, 200, 1),
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
  final double singleCourseHeight = 65;

  /// "午休"提示栏的高度
  final double middleStep = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: singleCourseHeight * 12 + cardStep * 11,
      child: Stack(
        children: [
          ..._generatePositioned(context),
          Positioned(
            left: 0,
            top: 4 * singleCourseHeight + 3 * cardStep,
            width: width,
            height: middleStep,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(child: Divider()),
              Text("午休",
                  style: FontManager.YaQiHei.copyWith(
                      color: titleColor.withAlpha(70), fontSize: 13)),
              Expanded(child: Divider()),
            ]),
          ),
        ],
      ),
    );
  }

  List<Widget> _generatePositioned(BuildContext context) {
    if (notifier.coursesWithNotify.length == 0) return List();
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
                ? getActiveCourseCard(context, height, cardWidth, courses)
                : getQuietCourseCard(height, cardWidth, courses[0])));
      });
    }
    return list;
  }
}
