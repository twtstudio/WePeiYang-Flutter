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

/// 课程表每个item之间的间距
const double _cardStep = 6;

int get _dayCount => CommonPreferences.dayNumber.value;

double get _width => WePeiYangApp.screenWidth - 15 * 2;

double get _cardWidth => (_width - (_dayCount - 1) * _cardStep) / _dayCount;

/// 这个Widget包括日期栏和下方的具体课程
class CourseDetailWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      child: Column(
        children: [
          _WeekDisplayWidget(),
          SizedBox(height: _cardStep),
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
        CommonPreferences.termStart.value, selectedWeek, _dayCount);
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
      height: _singleCourseHeight * 12 + _cardStep * 11 + _middleStep,
      child: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.courses.length == 0) {
            return Stack(children: [child!]);
          }
          var merged = getMergedCourses(provider, _dayCount);
          return Stack(
            children: [
              child!,
              ..._generatePositioned(
                  context, merged, provider.selectedWeek, provider.weekCount),
            ],
          );
        },
        child: Positioned(
          left: 0,
          top: 4 * _singleCourseHeight + 3 * _cardStep,
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

  List<Widget> _generatePositioned(
      BuildContext context,
      List<List<List<Pair<Course, int>>>> merged,
      int selectedWeek,
      int weekCount) {
    List<Positioned> list = [];
    for (int i = 0; i < _dayCount; i++) {
      int day = i + 1;
      merged[i].forEach((pairs) {
        int start = pairs[0].arrange.unitList.first;
        int end = pairs[0].arrange.unitList.last;
        double top =
            (start == 1) ? 0 : (start - 1) * (_singleCourseHeight + _cardStep);
        double left = (day == 1) ? 0 : (day - 1) * (_cardWidth + _cardStep);
        double height =
            (end - start + 1) * _singleCourseHeight + (end - start) * _cardStep;

        /// 绕开"午休"栏
        if (start > 4) top += _middleStep;
        if (start <= 4 && end > 4) height += _middleStep;
        list.add(Positioned(
            top: top,
            left: left,
            height: height,
            width: _cardWidth,
            child: judgeActiveInWeek(selectedWeek, weekCount, pairs[0].arrange)
                ? AnimatedActiveCourse(pairs)
                : QuietCourse(pairs[0].first.name)));
      });
    }
    return list;
  }
}
