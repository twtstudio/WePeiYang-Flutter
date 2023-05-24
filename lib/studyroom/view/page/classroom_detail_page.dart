import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/util/data_util.dart';
import 'package:we_pei_yang_flutter/studyroom/util/theme_util.dart';
import 'package:we_pei_yang_flutter/studyroom/util/time_util.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';

/// 自习室 某个教室详情页
class StyClassRoomDetailPage extends StatelessWidget {
  final Classroom room;

  const StyClassRoomDetailPage({Key? key, required this.room})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageTitle = Padding(
      padding: EdgeInsets.only(left: 21.w, right: 11.w),
      child: _PageTitleWidget(room),
    );

    final table = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.w),
      child: _ClassTableWidget(room),
    );

    return StudyroomBasePage(
        body: ListView(
      physics: const BouncingScrollPhysics(),
      children: [pageTitle, table],
    ));
  }
}

Widget _PageTitleWidget(Classroom room) {
  final title = Text(
    room.title,
    style: TextUtil.base.white.sp(20).Swis.w400,
  );

  final convertedWeek = Builder(builder: (context) {
    final dateTime = context.select(
      (StudyroomProvider config) => config.dateTime,
    );
    return Text(
      'WEEK ${dateTime.convertedWeek}',
      style: TextStyle(
        color: Theme.of(context).roomConvertWeek,
        fontSize: 14.sp,
      ),
    );
  });

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      title,
      Padding(
        padding: EdgeInsets.only(bottom: 3.w, left: 20.w),
        child: convertedWeek,
      ),
      const Spacer(),
      Padding(
        padding: EdgeInsets.only(right: 3.w),
        child: _FavorButton(room),
      ),
    ],
  );
}

class _FavorButton extends StatelessWidget {
  final Classroom room;

  _FavorButton(this.room, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.transparent,
        onSurface: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        minimumSize: Size(1, 1),
        padding: EdgeInsets.fromLTRB(12.w, 3.w, 12.w, 3.w),
      ),
      onPressed: () => context.read<StudyroomProvider>().changeRoomFavor(room),
      child: Builder(builder: (context) {
        final isFavor = context.select(
          (StudyroomProvider data) => data.favorRooms.containsKey(room.id),
        );

        return Text(isFavor ? '已收藏' : '+ 收藏',
            style: TextUtil.base.blue2C.w400.sp(14));
      }),
    );
  }
}

double get _cardStep => 6.w;

double get _schedulePadding => 11.67.w;

double get _dateTabHeight => 28.27.w;

/// 这个Widget包括日期栏和下方的具体课程
class _ClassTableWidget extends StatelessWidget {
  final Classroom room;

  const _ClassTableWidget(this.room, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wholeWidth = MediaQuery.of(context).size.width - _schedulePadding * 2;
    final dayCount = CommonPreferences.dayNumber.value;
    final cardWidth = (wholeWidth - dayCount * _cardStep) / dayCount;
    final tabHeight = cardWidth * 136 / 96;
    final wholeHeight = tabHeight * 12 + _cardStep * 12 + _dateTabHeight;

    final weekBar = Positioned(
      top: 0,
      left: _cardStep / 2,
      child: SizedBox(
        height: _dateTabHeight,
        width: cardWidth * dayCount + _cardStep * (dayCount - 1),
        child: _WeekDisplayWidget(cardWidth, dayCount),
      ),
    );

    final planGrid = Positioned(
      top: _cardStep + _dateTabHeight,
      left: _cardStep / 2,
      child: _CourseDisplayWidget(cardWidth, dayCount, room),
    );

    return SizedBox(
      height: wholeHeight,
      width: wholeWidth,
      child: Stack(
        children: [weekBar, planGrid],
      ),
    );
  }
}

class _WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final int dayCount;

  const _WeekDisplayWidget(
    this.cardWidth,
    this.dayCount, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateTime =
        context.select((StudyroomProvider config) => config.dateTime);

    return Row(
      children: dateTime.thisWeek.sublist(0, dayCount).map((date) {
        final backgroundColor = dateTime.isSameDay(date)
            ? Theme.of(context).coordinateChosenBackground
            : Theme.of(context).coordinateBackground;

        final textColor = dateTime.isSameDay(date)
            ? Theme.of(context).coordinateChosenText
            : Theme.of(context).coordinateText;

        return Container(
          height: _dateTabHeight,
          width: cardWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5.w),
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.month}/${date.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

class _CourseDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final int dayCount;
  final Classroom room;

  const _CourseDisplayWidget(
    this.cardWidth,
    this.dayCount,
    this.room, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var singleCourseHeight = cardWidth * 136 / 96;

    final statuses = room.statuses.map(
      (key, value) =>
          MapEntry(Time.week[key - 1], StudyRoomDataUtil.splitPlan(value)),
    );

    List<Widget> courses = _generatePositioned(
      context,
      singleCourseHeight,
      statuses,
      dayCount,
    );

    return SizedBox(
      height: singleCourseHeight * 12 + _cardStep * 11,
      width:
          MediaQuery.of(context).size.width - _schedulePadding * 2 - _cardStep,
      child: Stack(children: courses),
    );
  }

  List<Widget> _generatePositioned(
    BuildContext context,
    double courseHeight,
    Map<String, List<String>> plan,
    int dayCount,
  ) {
    List<Widget> list = [];
    var d = 1;
    var middleStep = 40.h;
    for (var wd in Time.week.getRange(0, dayCount)) {
      var index = 1;
      final dayPlan = plan[wd];
      if (dayPlan == null) {
        continue;
      }
      for (var c in dayPlan) {
        int day = d;
        int start = index;
        index = index + c.length;
        int end = index - 1;
        double top =
            (start == 1) ? 0 : (start - 1) * (courseHeight + _cardStep);
        if (start > 3) top += middleStep + _cardStep;
        double left = (day == 1) ? 0 : (day - 1) * (cardWidth + _cardStep);
        double height =
            (end - start + 1) * courseHeight + (end - start) * _cardStep;

        /// 判断周日的课是否需要显示在课表上
        if (day <= 7 && c.contains('1')) {
          Widget planItem = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.w),
              shape: BoxShape.rectangle,
              color: Colors.white.withOpacity(0.15),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Text(
              '课程占用',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).roomPlanItemText,
              ),
            ),
          );

          planItem = Positioned(
            top: top,
            left: left,
            height: height,
            width: cardWidth,
            child: planItem,
          );

          list.add(planItem);
        }
      }
      d++;
    }

    list.add(Positioned(
        left: 0,
        top: 4 * (courseHeight + _cardStep),
        height: middleStep,
        width: 1.sw - 30.w,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.symmetric(vertical: 5.h),
          child: list.isEmpty
              ? Text("全部空闲", style: TextUtil.base.w900.white.sp(16))
              : Text("LUNCH BREAK", style: TextUtil.base.w900.white.sp(10)),
        )));

    return list;
  }
}
