import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';

class TodayCoursesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      List<ScheduleCourse> todayCourses = _getTodayCourses(notifier);
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(25.0, 20.0, 0.0, 12.0),
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('课程表',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(100, 103, 122, 1.0),
                        fontWeight: FontWeight.bold)),
                Expanded(child: Text("")),
                Padding(
                  padding: const EdgeInsets.only(right: 25.0, top: 2),
                  child: (todayCourses.length == 0)
                      ? Container()
                      : GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(
                            context, ScheduleRouter.schedule),
                    child: DefaultTextStyle(
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(100, 103, 122, 1.0)),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: (notifier.nightMode && DateTime
                            .now()
                            .hour >= 21) ? "明天" : "今天"),
                        TextSpan(
                            text: todayCourses.length.toString(),
                            style:
                            TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "节课 "),
                        TextSpan(text: ">", style: TextStyle(fontSize: 15))
                      ])),
                    ),
                  ),
                )
              ],
            ),
          ),
          _getDisplayWidget(todayCourses)
        ],
      );
    });
  }

  List<ScheduleCourse> _getTodayCourses(ScheduleNotifier notifier) {
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
  Widget _getDisplayWidget(List<ScheduleCourse> todayCourses) {
    if (todayCourses.length == 0) {
      // 如果今天没有课，就返回文字框
      return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
              color: Color.fromRGBO(236, 238, 237, 1),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text("NO COURSE TODAY",
                style: TextStyle(
                    color: Color.fromRGBO(207, 208, 212, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5)),
          ));
    }

    /// 给本日课程排序
    todayCourses.sort((a, b) => a.arrange.start.compareTo(b.arrange.start));
    return Container(
      height: 180.0,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: todayCourses.length,
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, ScheduleRouter.schedule),
              child: Container(
                height: 180.0,
                width: 150.0,
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: Card(
                  color: FavorColors.homeSchedule[i % 5],
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 95.0,
                          alignment: Alignment.centerLeft,
                          child: Text(todayCourses[i].courseName,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                              getCourseTime(todayCourses[i].arrange.start,
                                  todayCourses[i].arrange.end),
                              style: TextStyle(
                                  fontSize: 13.0, color: Colors.white)),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                              replaceBuildingWord(todayCourses[i].arrange.room),
                              style: TextStyle(
                                  fontSize: 13.0,
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
