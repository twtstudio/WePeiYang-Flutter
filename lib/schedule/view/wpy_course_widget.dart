import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/school_model.dart';

class TodayCoursesWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodayCoursesWidgetState();
}

class TodayCoursesWidgetState extends State<TodayCoursesWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      List<ScheduleCourse> todayCourses = _getTodayCourses(notifier);
      return Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ScheduleRouter.schedule),
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 0, 12),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(S.current.schedule,
                      style: FontManager.YaQiHei.copyWith(
                          fontSize: 16,
                          color: Color.fromRGBO(100, 103, 122, 1),
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 25, top: 2),
                    child: (todayCourses.length == 0)
                        ? Container()
                        : DefaultTextStyle(
                      style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 12,
                          color: Color.fromRGBO(100, 103, 122, 1)),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                            text: (notifier.nightMode &&
                                DateTime
                                    .now()
                                    .hour >= 21)
                                ? "明天 "
                                : "今天 "),
                        TextSpan(
                            text: todayCourses.length.toString(),
                            style:
                            TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " 节课 "),
                        TextSpan(
                            text: "> ", style: TextStyle(fontSize: 15))
                      ])),
                    ),
                  )
                ],
              ),
            ),
          ),
          _getDisplayWidget(notifier, todayCourses, context)
        ],
      );
    });
  }

  /// 获取今天（夜猫子则是明天）的课程列表
  List<ScheduleCourse> _getTodayCourses(ScheduleNotifier notifier) {
    /// 如果学期还没开始，则不显示
    if (notifier.isOneDayBeforeTermStart) return [];
    List<ScheduleCourse> todayCourses = [];
    int today = DateTime
        .now()
        .weekday;
    bool nightMode = notifier.nightMode;
    if (DateTime
        .now()
        .hour < 21) nightMode = false;
    bool flag;
    notifier.coursesWithNotify.forEach((course) {
      if (nightMode)
        flag = judgeActiveTomorrow(
            notifier.currentWeek, today, notifier.weekCount, course);
      else
        flag = judgeActiveInDay(
            notifier.currentWeek, today, notifier.weekCount, course);
      if (flag) todayCourses.add(course);
    });
    return todayCourses;
  }

  /// 返回首页显示课程的widget
  Widget _getDisplayWidget(ScheduleNotifier notifier,
      List<ScheduleCourse> todayCourses, BuildContext context) {
    if (todayCourses.length == 0) {
      // 如果今天没有课，就返回文字框
      return GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, ScheduleRouter.schedule).then((
                value) =>
                this.setState(() {
                })),
        child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
                color: Color.fromRGBO(236, 238, 237, 1),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(
                  (notifier.nightMode && DateTime
                      .now()
                      .hour >= 21)
                      ? "明天没有课哦"
                      : "今天没有课哦",
                  style: FontManager.YaHeiLight.copyWith(
                      color: Color.fromRGBO(207, 208, 212, 1),
                      fontSize: 14,
                      letterSpacing: 0.5)),
            )),
      );
    }

    /// 给本日课程排序
    todayCourses.sort((a, b) => a.arrange.start.compareTo(b.arrange.start));
    return SizedBox(
      height: 185,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: todayCourses.length,
          itemBuilder: (context, i) {
            return Container(
              height: 185,
              width: 140,
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
              child: Material(
                color: CommonPreferences().isBegonia.value?FavorColors
                    .homeSchedule[i % FavorColors.homeSchedule.length]:FavorColors
                    .defaultHomeSchedule[i % FavorColors.homeSchedule.length],
                borderRadius: BorderRadius.circular(15),
                elevation: 2,
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, ScheduleRouter.schedule),
                  borderRadius: BorderRadius.circular(15),
                  splashFactory: InkRipple.splashFactory,
                  splashColor: Color.fromRGBO(179, 182, 191, 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 95,
                          alignment: Alignment.centerLeft,
                          child: Text(formatText(todayCourses[i].courseName),
                              style: FontManager.YaHeiBold.copyWith(
                                  fontSize: 15,
                                  color: CommonPreferences().isBegonia.value?(FavorColors.homeSchedule[i %
                                      FavorColors.homeSchedule.length].value ==
                                      Color
                                          .fromRGBO(221, 182, 190, 1.0)
                                          .value) ? Color(0xfff1dce0):Colors.white
                                      : Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 5),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              getCourseTime(todayCourses[i].arrange.start,
                                  todayCourses[i].arrange.end),
                              style: FontManager.Aspira.copyWith(
                                  fontSize: 11.5, color: Colors.white)),
                        ),
                        SizedBox(height: 15),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              replaceBuildingWord(todayCourses[i].arrange.room),
                              style: FontManager.Aspira.copyWith(
                                  fontSize: 12.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
