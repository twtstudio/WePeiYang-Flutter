import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';

class TodayCoursesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(25.0, 20.0, 0.0, 12.0),
            alignment: Alignment.centerLeft,
            child: Text('课程表',
                style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(100, 103, 122, 1.0),
                    fontWeight: FontWeight.bold)),
          ),
          _getDisplayWidget(notifier)
        ],
      );
    });
  }

  /// 返回首页显示课程的widget
  Widget _getDisplayWidget(ScheduleNotifier notifier) {
    List<ScheduleCourse> todayCourses = [];
    int today = DateTime.now().weekday;
    bool nightMode = notifier.nightMode;
    if (DateTime.now().hour < 22) nightMode = false;
    bool flag;
    notifier.coursesWithNotify.forEach((course) {
      if (nightMode)
        flag = judgeActiveTomorrow(
            notifier.currentWeekWithNotify, today, notifier.weekCount, course);
      else
        flag = judgeActiveInDay(
            notifier.currentWeekWithNotify, today, notifier.weekCount, course);
      if (flag) todayCourses.tryMerge(course);
    });
    if (todayCourses.length == 0) // 如果今天没有课，就返回文字框
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
    else // 否则返回所有今日课程
      return Container(
        height: 180.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: todayCourses.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/schedule'),
                child: Container(
                  height: 180.0,
                  width: 150.0,
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Card(
                    color: MyColors.colorList[i % 5],
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
                                replaceBuildingWord(
                                    todayCourses[i].arrange.room),
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

/// 尝试在添加今日课程时合并相同课程
extension TryMerge on List<ScheduleCourse> {
  void tryMerge(ScheduleCourse course) {
    if (isEmpty)
      add(course);
    else if (last.courseName == course.courseName)
      last.arrange.end = course.arrange.end;
    else
      add(course);
  }
}
