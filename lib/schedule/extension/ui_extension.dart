import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/extension/animation_executor.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_detail_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_dialog.dart';

import '../../commons/preferences/common_prefs.dart';

class AnimatedActiveCourse extends StatelessWidget {
  static const _duration = const Duration(milliseconds: 375);
  final List<Pair<Course, int>> _pairs;
  final bool _hide;
  final bool _warning;

  AnimatedActiveCourse(this._pairs, this._hide, this._warning);

  _activeNameStyle(context) => TextUtil.base.bright(context).bold.sp(11);

  _activeTeacherStyle(context) => TextUtil.base.bright(context).sp(8);

  _activeClassroomStyle(context) => TextUtil.base.bright(context).sp(11);

  @override
  Widget build(BuildContext context) {
    // _warning = true;
    var start = _pairs[0].arrange.unitList.first;
    var day = _pairs[0].arrange.weekday;

    var teacher = '';
    _pairs[0].arrange.teacherList.forEach((str) {
      if (teacher != '') teacher += ', ';
      teacher += removeParentheses(str);
    });

    var detail = Container(
      margin:
          EdgeInsets.symmetric(horizontal: horStep / 2, vertical: verStep / 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            WpyTheme.of(context).get(WpyColorKey.courseGradientStartColor),
            WpyTheme.of(context).get(WpyColorKey.courseGradientStopColor),
          ],
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 15,
            color: WpyTheme.of(context)
                .get(WpyColorKey.basicTextColor)
                .withOpacity(0.08),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        // color: generateColor(_pairs[0].first.name),
        child: InkWell(
          onTap: () => showCourseDialog(context, _pairs),
          borderRadius: BorderRadius.circular(5),
          splashFactory: InkRipple.splashFactory,
          splashColor: WpyTheme.of(context)
              .get(WpyColorKey.brightTextColor)
              .withOpacity(0.3),
          child: _hide
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                          formatText(
                            !(_pairs[0].arrange.isExperiment& CommonPreferences.isShowExperiment.value)
                                ? _pairs[0].first.name
                                : _pairs[0].arrange.name!,
                          ),
                          style: _activeNameStyle(context),
                          textAlign: TextAlign.center),
                      SizedBox(height: 2),
                      Text(teacher,
                          style: _activeTeacherStyle(context),
                          textAlign: TextAlign.center),
                      if (_pairs[0].arrange.location != "")
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                              replaceBuildingWord(_pairs[0].arrange.location),
                              style: _activeClassroomStyle(context),
                              textAlign: TextAlign.center),
                        ),
                      SizedBox(height: 2),
                      if (_warning)
                        Image.asset(
                          'assets/images/schedule/warning.png',
                          width: 20,
                          height: 20,
                        ),
                      Spacer()
                    ],
                  ),
                ),
        ),
      ),
    );

    return AnimationExecutor(
      duration: _duration,
      delay: _stagger(start, day),
      builder: (BuildContext context, Animation<double> animation) {
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        );

        return Transform.scale(
          scale: Tween<double>(begin: 0.5, end: 1.0)
              .animate(curvedAnimation)
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 0.8)
                .animate(curvedAnimation)
                .value,
            child: detail,
          ),
        );
      },
    );
  }

  Duration _stagger(int start, int day) => Duration(
      milliseconds: (start * 3 + day * 2) * _duration.inMilliseconds ~/ 18);
}
