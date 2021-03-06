import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/extension/ui_extension.dart';

/// 课程表每个item之间的间距
const double cardStep = 6;

/// 这个Widget包括日期栏和下方的具体课程
class ClassTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      var width = GlobalModel().screenWidth - 15 * 2;
      var dayCount = CommonPreferences().dayNumber.value;
      var cardWidth = (width - (dayCount - 1) * cardStep) / dayCount;
      return Column(
        children: [
          WeekDisplayWidget(cardWidth, notifier, dayCount),
          Padding(
            padding: const EdgeInsets.only(top: cardStep),
            child: CourseDisplayWidget(cardWidth, notifier, dayCount),
          )
        ],
      );
    });
  }
}

class WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int dayCount;

  WeekDisplayWidget(this.cardWidth, this.notifier, this.dayCount);

  @override
  Widget build(BuildContext context) => Row(
        children: _generateCards(cardWidth,
            getWeekDayString(notifier.termStart, notifier.selectedWeekWithNotify, dayCount)),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      );

  List<Widget> _generateCards(double width, List<String> dates) {
    List<Widget> list = [];
    dates.forEach((element) {
      list.add(_getCard(width, element));
    });
    return list;
  }

  /// 因为card组件宽度会比width小一些，不好对齐，因此用container替代
  Widget _getCard(double width, String date) => Container(
        height: 28,
        width: width,
        decoration: BoxDecoration(
            color: Color.fromRGBO(236, 238, 237, 1),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(date,
              style: TextStyle(
                  color: Color.fromRGBO(200, 200, 200, 1),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      );
}

class CourseDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int dayCount;

  CourseDisplayWidget(this.cardWidth, this.notifier, this.dayCount);

  /// 每一节小课对应的高度（据此，每一节大课的高度应为其两倍再加上step）
  static const double singleCourseHeight = 65;

  @override
  Widget build(BuildContext context) {
    if (notifier.coursesWithNotify.length == 0) return Container();
    return Container(
      height: singleCourseHeight * 12 + cardStep * 11,
      child: Stack(
        children: _generatePositioned(context),
      ),
    );
  }

  List<Widget> _generatePositioned(BuildContext context) {
    int dayNumber = CommonPreferences().dayNumber.value;
    List<Positioned> list = [];
    notifier.coursesWithNotify.forEach((course) {
      int day = int.parse(course.arrange.day);
      int start = int.parse(course.arrange.start);
      int end = int.parse(course.arrange.end);
      double top =
          (start == 1) ? 0 : (start - 1) * (singleCourseHeight + cardStep);
      double left = (day == 1) ? 0 : (day - 1) * (cardWidth + cardStep);
      double height =
          (end - start + 1) * singleCourseHeight + (end - start) * cardStep;

      /// 判断周日的课是否需要显示在课表上
      if (day <= dayNumber)
        list.add(Positioned(
            top: top,
            left: left,
            height: height,
            width: cardWidth,
            child: _judgeChild(context, height, course)));
    });
    return list;
  }

  Widget _judgeChild(BuildContext context, double height, ScheduleCourse course) =>
      judgeActiveInWeek(notifier.selectedWeekWithNotify, notifier.weekCount, course)
          ? getActiveCourseCard(context, height, cardWidth, course)
          : getQuietCourseCard(height, cardWidth, course);
}
