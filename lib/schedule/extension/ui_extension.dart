import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/extension/animation_executor.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_dialog.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_detail_widget.dart';

class AnimatedActiveCourse extends StatelessWidget {
  static const _duration = const Duration(milliseconds: 375);
  final List<Pair<Course, int>> _pairs;
  final bool _hide;
  final bool _warning;

  AnimatedActiveCourse(this._pairs, this._hide, this._warning);

  final _activeNameStyle = TextUtil.base.white.bold.sp(11);
  final _activeTeacherStyle = TextUtil.base.white.sp(8);
  final _activeClassroomStyle = TextUtil.base.white.sp(11);

  @override
  Widget build(BuildContext context) {
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
            ColorUtil.whiteOpacity05,
            ColorUtil.whiteOpacity03,
          ],
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 15,
            color: ColorUtil.blackOpacity008,
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: ColorUtil.transparent,
        // color: generateColor(_pairs[0].first.name),
        child: InkWell(
          onTap: () => showCourseDialog(context, _pairs),
          borderRadius: BorderRadius.circular(5),
          splashFactory: InkRipple.splashFactory,
          splashColor: ColorUtil.white199,
          child: _hide
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Spacer(),
                      Text(formatText(_pairs[0].first.name),
                          style: _activeNameStyle, textAlign: TextAlign.center),
                      SizedBox(height: 2),
                      Text(teacher,
                          style: _activeTeacherStyle,
                          textAlign: TextAlign.center),
                      if (_pairs[0].arrange.location != "")
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                              replaceBuildingWord(_pairs[0].arrange.location),
                              style: _activeClassroomStyle,
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
