// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/extension/ui_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

/// 课程表每个item之间的垂直、水平间距
const double _verStep = 12;
const double _horStep = 6;

int get _dayNumber => CommonPreferences.dayNumber.value;

double get _width => WePeiYangApp.screenWidth - 15 * 2;

double get _cardWidth => (_width - (_dayNumber - 1) * _horStep) / _dayNumber;

/// 这个Widget包括日期栏和下方的具体课程
class CourseDetailWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      child: Column(
        children: [
          _WeekDisplayWidget(),
          SizedBox(height: 6),
          _CourseDisplayWidget(),
        ],
      ),
    );
  }
}

class _WeekDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var selectedWeek =
        context.select<CourseProvider, int>((p) => p.selectedWeek);
    List<String> dates = getWeekDayString(
        CommonPreferences.termStart.value, selectedWeek, _dayNumber);
    var now = DateTime.now();
    var month = now.month.toString();
    var day = now.day.toString();
    var nowDate =
        "${month.length < 2 ? '0' + month : month}/${day.length < 2 ? '0' + day : day}";
    return Row(
      children: dates
          .map((date) =>
              _getCard(date, nowDate == date, FavorColors.scheduleTitleColor))
          .toList(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  /// 因为card组件宽度会比width小一些，不好对齐，因此用container替代
  Widget _getCard(String date, bool deep, Color titleColor) => Container(
        height: 28,
        width: _cardWidth,
        decoration: BoxDecoration(
            color: deep ? titleColor : Color.fromRGBO(236, 238, 237, 1),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(date,
              style: FontManager.Aspira.copyWith(
                  color: deep ? Colors.white : Color.fromRGBO(200, 200, 200, 1),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      );
}

class _CourseDisplayWidget extends StatelessWidget {
  /// 每一节小课对应的高度（据此，每一节大课的高度应为其两倍再加上step）
  static const double _singleCourseHeight = 65;

  /// "午休"提示栏的高度
  static const double _middleStep = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _singleCourseHeight * 12 + _verStep * 11 + _middleStep,
      child: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.totalCourses.length == 0) {
            return Stack(children: [child!]);
          }
          var positionedList = <Widget>[];

          var inactiveList = getMergedInactiveCourses(provider, _dayNumber);
          // 先添加非本周课程
          inactiveList.forEach((pair) {
            int start = pair.arrange.unitList.first;
            int end = pair.arrange.unitList.last;
            int day = pair.arrange.weekday;
            double top = (start - 1) * (_singleCourseHeight + _verStep);
            double left = (day - 1) * (_cardWidth + _horStep);
            double height = (end - start + 1) * _singleCourseHeight +
                (end - start) * _verStep;
            // 绕开"午休"栏
            if (start > 4) top += _middleStep;
            if (start <= 4 && end > 4) height += _middleStep;
            positionedList.add(Positioned(
              top: top,
              left: left,
              height: height,
              width: _cardWidth,
              child: QuietCourse(pair.first.name),
            ));
          });

          var activeList = getMergedActiveCourses(provider, _dayNumber);
          var tempList = <Widget>[];
          // 添加本周课程
          for (int i = 0; i < activeList.length; i++) {
            int start = activeList[i][0].arrange.unitList.first;
            int end = activeList[i][0].arrange.unitList.last;
            int day = activeList[i][0].arrange.weekday;
            double top = (start - 1) * (_singleCourseHeight + _verStep);
            double left = (day - 1) * (_cardWidth + _horStep);
            double height = (end - start + 1) * _singleCourseHeight +
                (end - start) * _verStep;
            // 绕开"午休"栏
            if (start > 4) top += _middleStep;
            if (start <= 4 && end > 4) height += _middleStep;
            // 是否需要“漂浮”显示
            if (true == activeList[i][0].arrange.needFloat) top += 6;

            tempList.add(Positioned(
              top: top,
              left: left,
              height: height,
              width: _cardWidth,
              child: AnimatedActiveCourse(activeList[i]),
            ));
          }
          // 靠后的课需要先加入到stack中，所以需要reverse
          positionedList.addAll(tempList.reversed);

          return Stack(
            children: [
              child!,
              ...positionedList,
            ],
          );
        },
        child: Positioned(
          left: 0,
          top: 4 * _singleCourseHeight + 3 * _verStep,
          width: _width,
          height: _middleStep,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider()),
              Text("午休",
                  style: FontManager.YaQiHei.copyWith(
                      color: FavorColors.scheduleTitleColor.withAlpha(70),
                      fontSize: 13)),
              Expanded(child: Divider()),
            ],
          ),
        ),
      ),
    );
  }
}
