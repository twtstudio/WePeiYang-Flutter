// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

class TodayCoursesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(builder: (context, provider, _) {
      var nightMode =
          context.select<CourseDisplayProvider, bool>((p) => p.nightMode);
      var todayPairs = _getTodayPairs(provider, nightMode);
      return Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ScheduleRouter.course),
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
                    child: (todayPairs.length == 0)
                        ? Container()
                        : DefaultTextStyle(
                            style: FontManager.YaHeiRegular.copyWith(
                                fontSize: 12,
                                color: Color.fromRGBO(100, 103, 122, 1)),
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: (nightMode && DateTime.now().hour >= 21)
                                      ? "明天 "
                                      : "今天 "),
                              TextSpan(
                                  text: todayPairs.length.toString(),
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
          _getDisplayWidget(context, todayPairs, nightMode)
        ],
      );
    });
  }

  /// 获取今天（夜猫子则是明天）的课程列表
  List<Pair<Course, int>> _getTodayPairs(
      CourseProvider provider, bool nightMode) {
    /// 如果学期还没开始，则不显示
    if (isOneDayBeforeTermStart) return [];
    List<Pair<Course, int>> todayPairs = [];
    int today = DateTime.now().weekday;
    bool readNightMode = nightMode;
    if (DateTime.now().hour < 21) readNightMode = false;
    bool flag;
    provider.courses.forEach((course) {
      for (int i = 0; i < course.arrangeList.length; i++) {
        if (readNightMode) {
          flag = judgeActiveTomorrow(provider.currentWeek, today,
              provider.weekCount, course.arrangeList[i]);
        } else {
          flag = judgeActiveInDay(provider.currentWeek, today,
              provider.weekCount, course.arrangeList[i]);
        }
        if (flag) todayPairs.add(Pair(course, i));
      }
    });
    return todayPairs;
  }

  /// 返回首页显示课程的widget
  Widget _getDisplayWidget(BuildContext context,
      List<Pair<Course, int>> todayPairs, bool nightMode) {
    if (todayPairs.length == 0) {
      // 如果今天没有课，就返回文字框
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, ScheduleRouter.course),
        child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
                color: Color.fromRGBO(236, 238, 237, 1),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(
                  (nightMode && DateTime.now().hour >= 21)
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
    todayPairs
        .sort((a, b) => a.arrange.unitList.first.compareTo(b.arrange.unitList.first));
    return SizedBox(
      height: 185,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: todayPairs.length,
          itemBuilder: (context, i) {
            return Container(
              height: 185,
              width: 140,
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
              child: Material(
                color: FavorColors
                    .homeSchedule[i % FavorColors.homeSchedule.length],
                borderRadius: BorderRadius.circular(15),
                elevation: 2,
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, ScheduleRouter.course),
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
                          child: Text(formatText(todayPairs[i].first.name),
                              style: FontManager.YaHeiBold.copyWith(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 5),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(getCourseTime(todayPairs[i].arrange.unitList),
                              style: FontManager.Aspira.copyWith(
                                  fontSize: 11.5, color: Colors.white)),
                        ),
                        SizedBox(height: 15),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              replaceBuildingWord(
                                  todayPairs[i].arrange.location),
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
