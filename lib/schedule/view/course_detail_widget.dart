// @dart = 2.12
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/extension/ui_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

/// 课程表每个item之间的垂直、水平间距
const double verStep = 6;
const double horStep = 6;

int get _dayNumber => CommonPreferences.dayNumber.value;

double get _width => WePeiYangApp.screenWidth - 15 * 2;

double get _cardWidth => (_width - (_dayNumber - 1) * horStep) / _dayNumber;

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
            color: deep
                ? CommonPreferences.isAprilFoolClass.value
                    ? ColorUtil.aprilFoolColor[Random().nextInt(4)]
                    : Color.fromRGBO(255, 255, 255, 1)
                : Color.fromRGBO(246, 246, 246, 0.2),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(date,
              style: FontManager.Aspira.copyWith(
                  color: deep
                      ? Color.fromRGBO(44, 126, 223, 1)
                      : Color.fromRGBO(202, 202, 202, 1),
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
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        var verNum = 8; // 显示每天第1-verNum节课，verNum取值范围为[8, 12]
        if (provider.totalCourses.length == 0) {
          return SizedBox(
            height: (_singleCourseHeight + verStep) * verNum + _middleStep,
            child: Stack(children: [child!]),
          );
        }
        var positionedList = <Widget>[];

        // var inactiveList = getMergedInactiveCourses(provider, _dayNumber);
        // // 先添加非本周课程
        // inactiveList.forEach((pair) {
        //   int start = pair.arrange.unitList.first;
        //   int end = pair.arrange.unitList.last;
        //   int day = pair.arrange.weekday;
        //   double top = (start - 1) * (_singleCourseHeight + verStep);
        //   double left = (day - 1) * (_cardWidth + horStep);
        //   double height = (end - start + 1) * _singleCourseHeight +
        //       (end - start) * verStep;
        //   // 绕开"午休"栏
        //   if (start > 4) top += _middleStep;
        //   if (start <= 4 && end > 4) height += _middleStep;
        //   positionedList.add(Positioned(
        //     top: top - verStep / 2,
        //     left: left - horStep / 2,
        //     height: height + verStep,
        //     width: _cardWidth + horStep,
        //     child: QuietCourse(pair.first.name),
        //   ));
        // });

        var activeList = getMergedActiveCourses(provider, _dayNumber);
        var tempList = <Widget>[];
        // 添加本周课程
        for (int i = 0; i < activeList.length; i++) {
          // 更新verNum
          activeList.forEach((pairs) {
            pairs.forEach((pair) {
              verNum = max(verNum, pair.arrange.unitList.last);
            });
          });
          int start = activeList[i][0].arrange.unitList.first;
          int end = activeList[i][0].arrange.unitList.last;
          int day = activeList[i][0].arrange.weekday;
          double top = (start - 1) * (_singleCourseHeight + verStep);
          double left = (day - 1) * (_cardWidth + horStep);
          double height = (end - start + 1) * _singleCourseHeight +
              (end - start) * verStep;
          // 绕开"午休"栏
          if (start > 4) top += _middleStep;
          if (start <= 4 && end > 4) height += _middleStep;
          // 是否需要“漂浮”显示
          if (activeList[i][0].arrange.showMode == 1) top += 6;
          // 是否不显示内容
          var hide = (activeList[i][0].arrange.showMode == 2);

          var warning = activeList[i][0].arrange.showMode == 1;
          if (activeList[i].length > 1) {
            List<Pair<Course, int>> copy = []..addAll(activeList[i]);
            // 按照短课程优先、时间晚优先、高学分优先来排序
            copy.sort((a, b) {
              // 短课程优先
              var aFirst = a.arrange.unitList.first;
              var aLast = a.arrange.unitList.last;
              var bFirst = b.arrange.unitList.first;
              var bLast = b.arrange.unitList.last;
              var aLen = aLast - aFirst;
              var bLen = bLast - bFirst;
              if (aLen != bLen) return aLen.compareTo(bLen);

              // 时间晚优先
              return bFirst.compareTo(aFirst);
            });
            if (activeList[i][0].first.name == copy[0].first.name) {
              warning = true;
            }
          }

          tempList.add(Positioned(
            top: top - verStep / 2,
            left: left - verStep / 2,
            height: height + verStep,
            width: _cardWidth + horStep,
            child: AnimatedActiveCourse(activeList[i], hide, warning),
          ));
        }
        // 靠后的课需要先加入到stack中，所以需要reverse
        positionedList.addAll(tempList.reversed);

        return SizedBox(
          height: (_singleCourseHeight + verStep) * verNum + _middleStep,
          child: Stack(
            children: [
              child!,
              ...positionedList,
            ],
          ),
        );
      },
      child: Positioned(
        left: 0,
        top: 4 * (_singleCourseHeight + verStep),
        height: _middleStep,
        width: WePeiYangApp.screenWidth - 30,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Text("LUNCH BREAK",
              style: FontManager.YaQiHei.copyWith(
                color: Color.fromRGBO(255, 255, 255, 1),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              )),
        ),
      ),
    );
  }
}