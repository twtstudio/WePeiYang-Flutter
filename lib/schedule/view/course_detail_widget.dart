// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_dialog.dart';

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

  /// 每个Positioned的缩放、透明度动画的时长
  static const int _animLen = 375;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _singleCourseHeight * 12 + _cardStep * 11 + _middleStep,
      child: Consumer<CourseProvider>(
        builder: (context, provider, outerChild) {
          if (provider.courses.length == 0) {
            return Stack(children: [outerChild!]);
          }
          var merged = getMergedCourses(provider, _dayCount);
          var maxDelay = _getMaxDelay(merged);
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: _animLen + maxDelay),
            tween: Tween<double>(begin: .0, end: _animLen + maxDelay + .0),
            curve: Curves.ease,
            builder: (context, value, innerChild) {
              return Stack(
                children: [
                  innerChild!,
                  ..._generatePositioned(context, merged, provider.selectedWeek,
                      provider.weekCount, value),
                ],
              );
            },
            child: outerChild,
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
      int weekCount,
      double value) {
    List<Positioned> list = [];
    for (int i = 0; i < _dayCount; i++) {
      int day = i + 1;
      merged[i].forEach((pairs) {
        int start = pairs[0].arrange.unitList.first;
        int end = pairs[0].arrange.unitList.first;
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
                ? _activeCourse(context, pairs, _width, height, value)
                : _quietCourse(height, _cardWidth, pairs[0].first.name)));
      });
    }
    return list;
  }

  final _activeNameStyle = FontManager.YaQiHei.copyWith(
      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold);
  final _activeTeacherStyle =
      FontManager.YaHeiLight.copyWith(color: Colors.white, fontSize: 8);
  final _activeClassroomStyle =
      FontManager.Texta.copyWith(color: Colors.white, fontSize: 11);

  static const _quietBackColor = Color.fromRGBO(236, 238, 237, 1);
  static const _quiteFrontColor = Color.fromRGBO(205, 206, 210, 1);

  final _quietNameStyle = FontManager.YaQiHei.copyWith(
      color: _quiteFrontColor, fontSize: 10, fontWeight: FontWeight.bold);
  final _quietHintStyle =
      FontManager.YaHeiRegular.copyWith(color: _quiteFrontColor, fontSize: 9);

  Widget _activeCourse(BuildContext context, List<Pair<Course, int>> pairs,
      double width, double height, double value) {
    var start = pairs[0].arrange.unitList.first;
    var day = pairs[0].arrange.weekday;
    var delay = _getDelay(start, day);

    if (value <= delay) return Container();

    var teacher = '';
    pairs[0].arrange.teacherList.forEach((str) {
      if (teacher != '') teacher += ', ';
      teacher += removeParentheses(str);
    });

    var detail = SizedBox(
      height: height,
      width: width,
      child: Material(
        color: generateColor(pairs[0].first.name),
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: () => showCourseDialog(context, pairs),
          borderRadius: BorderRadius.circular(5),
          splashFactory: InkRipple.splashFactory,
          splashColor: Color.fromRGBO(179, 182, 191, 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Spacer(),
                Text(formatText(pairs[0].first.name),
                    style: _activeNameStyle, textAlign: TextAlign.center),
                SizedBox(height: 2),
                Text(teacher,
                    style: _activeTeacherStyle, textAlign: TextAlign.center),
                if (pairs[0].arrange.location == "")
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(replaceBuildingWord(pairs[0].arrange.location),
                        style: _activeClassroomStyle,
                        textAlign: TextAlign.center),
                  ),
                if (pairs.length == 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Image.asset('assets/images/schedule_warn.png',
                        width: 20, height: 20),
                  ),
                Spacer()
              ],
            ),
          ),
        ),
      ),
    );

    /// scale: 等待[delay]毫秒后，在[_animLen]毫秒内从 0.5 ease上升至 1.0
    /// opacity: 等待[delay]毫秒后，在[_animLen]毫秒内从 0.0 ease上升至 1.0
    double scale = 0.5 + (value - delay) / _animLen / 2;
    if (scale > 1) scale = 1;
    double opacity = (value - delay) / _animLen;
    if (opacity > 1) opacity = 1;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: detail,
      ),
    );
  }

  Widget _quietCourse(double height, double width, String courseName) {
    if (!CommonPreferences.otherWeekSchedule.value) return Container();
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: _quietBackColor),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Spacer(),
          Icon(Icons.lock, color: _quiteFrontColor, size: 15),
          SizedBox(height: 2),
          Text(formatText(courseName),
              style: _quietNameStyle, textAlign: TextAlign.center),
          SizedBox(height: 2),
          Text(S.current.not_this_week,
              style: _quietHintStyle, textAlign: TextAlign.center),
          Spacer()
        ],
      ),
    );
  }

  int _getMaxDelay(List<List<List<Pair<Course, int>>>> merged) {
    int maxValue = 0;
    for (int i = 0; i < _dayCount; i++) {
      int day = i + 1;
      merged[i].forEach((pairs) {
        int start = pairs[0].arrange.unitList.first;
        var delay = _getDelay(start, day);
        if (delay > maxValue) maxValue = delay;
      });
    }
    return maxValue;
  }

  int _getDelay(int start, int day) =>
      ((start - 1) * 3 + (day - 1) * 2) * _animLen ~/ 18;
}
