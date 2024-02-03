import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_service.dart';
import 'package:we_pei_yang_flutter/studyroom/util/theme_util.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';

import '../../../commons/themes/color_util.dart';

/// 自习室 某个教室详情页
class StyClassRoomDetailPage extends StatelessWidget {
  final Room room;
  final String areaName;

  const StyClassRoomDetailPage(
      {Key? key, required this.room, required this.areaName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageTitle = Padding(
      padding: EdgeInsets.only(left: 21.w, right: 11.w),
      child: _PageTitleWidget(room, areaName),
    );

    final table = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.w),
      child: _ClassTableWidget(room),
    );

    return StudyroomBasePage(
      showTimeButton: false,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [pageTitle, table],
      ),
    );
  }
}

Widget _PageTitleWidget(Room room, String areaName) {
  final title = Text(
    room.name,
    style: TextUtil.base.white.sp(20).Swis.w400,
  );

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      title,
      Padding(
        padding: EdgeInsets.only(bottom: 3.w, left: 20.w),
        child: Text(
          areaName,
          style: TextStyle(
            color: ColorUtil.greyCAColor,
            fontSize: 14.sp,
          ),
        ),
      ),
      const Spacer(),
      // TODO: 依然 收藏暂时被砍掉了
      // Padding(
      //   padding: EdgeInsets.only(right: 3.w),
      //   child: _FavorButton(room),
      // ),
    ],
  );
}

double get _cardStep => 6.w;

double get _schedulePadding => 11.67.w;

double get _dateTabHeight => 28.27.w;

/// 这个Widget包括日期栏和下方的具体课程
class _ClassTableWidget extends StatelessWidget {
  final Room room;

  const _ClassTableWidget(this.room, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wholeWidth = MediaQuery.of(context).size.width - _schedulePadding * 2;
    final cardWidth = (wholeWidth - 7 * _cardStep) / 7;
    final tabHeight = cardWidth * 136 / 96;
    final wholeHeight = tabHeight * 14 + _cardStep * 12 + _dateTabHeight;

    final weekBar = Positioned(
      top: 0,
      left: _cardStep / 2,
      child: SizedBox(
        height: _dateTabHeight,
        width: cardWidth * 7 + _cardStep * 6,
        child: _WeekDisplayWidget(cardWidth),
      ),
    );

    final planGrid = Positioned(
      top: _cardStep + _dateTabHeight,
      left: _cardStep / 2,
      child: _CourseDisplayWidget(cardWidth, room),
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

  const _WeekDisplayWidget(
    this.cardWidth, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextSevenDays = List.generate(7, (index) {
      return DateTime.now().add(Duration(days: index));
    });

    return Row(
      children: nextSevenDays.map((date) {
        final backgroundColor = now.isSameDay(date)
            ? Theme.of(context).coordinateChosenBackground
            : Theme.of(context).coordinateBackground;

        final textColor = now.isSameDay(date)
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

class ScheduleLoader extends ChangeNotifier {
  final Map<DateTime, List<int>> schedule = {};

  void initSchedule(int roomId) async {
    final List<Occupy> _raw_schedule =
        await StudyroomService.getSchedule(roomId);
    for (var e in _raw_schedule) {
      if (schedule.containsKey(e.date)) {
        schedule[e.date]!.add(e.sessionIndex);
      } else {
        schedule[e.date] = [e.sessionIndex];
      }
    }
    notifyListeners();
  }
}

class _CourseDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final Room room;

  _CourseDisplayWidget(
    this.cardWidth,
    this.room, {
    Key? key,
  }) : super(key: key);

  final loader = ScheduleLoader();

  @override
  Widget build(BuildContext context) {
    loader.initSchedule(room.id);
    var singleCourseHeight = cardWidth * 136 / 96;

    // final statuses = room.statuses.map(
    //   (key, value) =>
    //       MapEntry(Time.week[key - 1], StudyRoomDataUtil.splitPlan(value)),
    // );

    return SizedBox(
      height: singleCourseHeight * 14 + _cardStep * 14,
      width:
          MediaQuery.of(context).size.width - _schedulePadding * 2 - _cardStep,
      child: ListenableBuilder(
        listenable: loader,
        builder: (context, __) {
          return Stack(
            children: _generatePositioned(
              context,
              singleCourseHeight,
              loader.schedule,
              7,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _generatePositioned(
    BuildContext context,
    double courseHeight,
    Map<DateTime, List<int>> plan,
    int dayCount,
  ) {
    List<Widget> list = [];
    var d = 1;
    var middleStep = 40.h;
    var now = DateTime.now();
    bool showNightBreak = false;
    for (var date = DateTime(now.year, now.month, now.day), i = 1;
        i <= 7;
        i++, date = date.add(Duration(days: 1))) {
      var index = 1;

      final dayPlan = plan[date];
      print(date.toString());
      if (dayPlan == null) continue;
      // dayPlan.removeAt(4);
      // dayPlan.removeAt(6);

      for (int i = 1; i <= 12; i++) {
        int day = d;
        int start = index;
        index = index + 1;
        int end = index - 1;
        double top =
            (start == 1) ? 0 : (start - 1) * (courseHeight + _cardStep);
        if (start > 4) top += middleStep + _cardStep;
        if (start > 8) {
          top += middleStep + _cardStep;
        }
        double left = (day == 1) ? 0 : (day - 1) * (cardWidth + _cardStep);
        double height =
            (end - start + 1) * courseHeight + (end - start) * _cardStep;

        if (dayPlan.contains(i)) {
          if (i > 8) showNightBreak = true;
          Widget planItem = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.w),
              shape: BoxShape.rectangle,
              color: Colors.white.withOpacity(0.15),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Text(
              '占用',
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

    if (showNightBreak) {
      // 还需要讨论使用那种方式
    }

    if (list.isNotEmpty) {
      list.add(Positioned(
          left: 0,
          top: 8 * (courseHeight + _cardStep) + _cardStep + middleStep,
          height: middleStep,
          width: 1.sw - 30.w,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            margin: EdgeInsets.symmetric(vertical: 5.h),
            child: Text("NIGHT BREAK", style: TextUtil.base.w900.white.sp(10)),
          )));
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
