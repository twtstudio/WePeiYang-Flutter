import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/home/model/home_model.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/extension/ui_extension.dart';

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
        children: _generateCards(
            cardWidth,
            getWeekDayString(
                notifier.termStart, notifier.selectedWeekWithNotify, dayCount)),
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
              style: FontManager.Aspira.copyWith(
                  color: Color.fromRGBO(200, 200, 200, 1),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      );
}

class CourseDisplayWidget extends StatefulWidget {
  final double cardWidth;
  final ScheduleNotifier notifier;
  final int dayCount;

  CourseDisplayWidget(this.cardWidth, this.notifier, this.dayCount);

  /// 每一节小课对应的高度（据此，每一节大课的高度应为其两倍再加上step）
  static const double singleCourseHeight = 65;

  @override
  _CourseDisplayWidgetState createState() => _CourseDisplayWidgetState();
}

class _CourseDisplayWidgetState extends State<CourseDisplayWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _animation = Tween(
      begin: 0.15,
      end: 1.0,
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifier.coursesWithNotify.length == 0) return Container();
    _controller.reset();
    _controller.forward();
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: CourseDisplayWidget.singleCourseHeight * 12 + cardStep * 11,
        child: Stack(
          children: _generatePositioned(context),
        ),
      ),
    );
  }

  List<Widget> _generatePositioned(BuildContext context) {
    int dayNumber = CommonPreferences().dayNumber.value;
    List<Positioned> list = [];
    List<List<List<ScheduleCourse>>> merged =
        getMergedCourses(widget.notifier, dayNumber);
    for (int i = 0; i < dayNumber; i++) {
      int day = i + 1;
      merged[i].forEach((courses) {
        int start = int.parse(courses[0].arrange.start);
        int end = int.parse(courses[0].arrange.end);
        double top = (start == 1)
            ? 0
            : (start - 1) * (CourseDisplayWidget.singleCourseHeight + cardStep);
        double left =
            (day == 1) ? 0 : (day - 1) * (widget.cardWidth + cardStep);
        double height =
            (end - start + 1) * CourseDisplayWidget.singleCourseHeight +
                (end - start) * cardStep;
        list.add(Positioned(
            top: top,
            left: left,
            height: height,
            width: widget.cardWidth,
            child: _judgeChild(context, height, courses)));
      });
    }
    return list;
  }

  Widget _judgeChild(
          BuildContext context, double height, List<ScheduleCourse> courses) =>
      judgeActiveInWeek(widget.notifier.selectedWeekWithNotify,
              widget.notifier.weekCount, courses[0])
          ? getActiveCourseCard(context, height, widget.cardWidth, courses)
          : getQuietCourseCard(height, widget.cardWidth, courses[0]);
}
