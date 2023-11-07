import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

import '../../commons/util/color_util.dart';

class TodayCoursesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(builder: (context, provider, _) {
      var nightMode =
          context.select<CourseDisplayProvider, bool>((p) => p.nightMode);
      var todayPairs = _getTodayPairs(provider, nightMode);
      if (todayPairs.length == 0) return Container();

      return _detail(context, todayPairs, nightMode);
    });
  }

  /// 获取今天（夜猫子则是明天）的课程列表
  List<Pair<Course, int>> _getTodayPairs(
      CourseProvider provider, bool nightMode) {
    /// 如果学期还没开始，则不显示
    if (isOneDayBeforeTermStart) return [];
    List<Pair<Course, int>> todayPairs = [];
    int today = DateTime.now().weekday;
    if (DateTime.now().hour < 21) nightMode = false;
    bool flag;
    provider.totalCourses.forEach((course) {
      for (int i = 0; i < course.arrangeList.length; i++) {
        if (nightMode) {
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
  Widget _detail(BuildContext context, List<Pair<Course, int>> todayPairs,
      bool nightMode) {
    /// 给本日课程排序
    todayPairs.sort(
        (a, b) => a.arrange.unitList.first.compareTo(b.arrange.unitList.first));
    var height = todayPairs.length * 90.h;
    if (todayPairs.length > 3) height = 270.h;
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        itemCount: todayPairs.length,
        itemBuilder: (context, i) {
          return Container(
            height: 80.h,
            width: 330.w,
            margin: EdgeInsets.symmetric(vertical: 5.h),
            child: Material(
              color: ColorUtil.black12,
              borderRadius: BorderRadius.circular(20.r),
              elevation: 0,
              child: InkWell(
                onTap: () {
                  List<Pair<Course, int>> now = [todayPairs[i]];
                  Navigator.pushNamed(context, ScheduleRouter.course,
                      arguments: now);
                },
                borderRadius: BorderRadius.circular(20.r),
                splashFactory: InkRipple.splashFactory,
                splashColor: ColorUtil.black26,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(35.w, 0, 25.w, 0),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${getCourseTime(todayPairs[i].arrange.unitList)}   ${replaceBuildingWord(todayPairs[i].arrange.location)}',
                            style: TextUtil.base.bold
                                .sp(14)
                                .customColor(ColorUtil.white54),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 1.sw - 125.w - 50.r,
                            child: Text(
                              todayPairs[i].first.name,
                              style: TextUtil.base.PingFangSC.white.bold.sp(14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, ScheduleRouter.course),
                        child: Image.asset('assets/images/schedule/circle.png',
                            width: 50.r, height: 50.r),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
