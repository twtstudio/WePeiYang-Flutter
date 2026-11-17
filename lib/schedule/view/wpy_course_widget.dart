import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

import '../../commons/preferences/common_prefs.dart';
import '../../commons/widgets/w_button.dart';

class TodayCoursesWidget extends StatelessWidget {
  /// 宽度达到这个值（设计稿单位）时今日课程才分多列显示
  static const _multiColumnMinWidth = 390.0 * 3;

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(builder: (context, provider, _) {
      var nightMode =
          context.select<CourseDisplayProvider, bool>((p) => p.nightMode);
      var todayPairs = _getTodayPairs(provider, nightMode);
      if (todayPairs.length == 0) return SizedBox.shrink();

      return _detail(context, todayPairs, nightMode);
    });
  }

  /// 获取今天（夜猫子则是明天）的课程列表
  List<Pair<Course, int>> _getTodayPairs(
      CourseProvider provider, bool nightMode) {
    final now = DateTime.now();
    final offset = nightMode && now.hour >= 21 ? 1 : 0;
    return provider.coursesForDate(DateTime(now.year, now.month, now.day + offset));
  }

  /// 返回首页显示课程的widget
  Widget _detail(BuildContext context, List<Pair<Course, int>> todayPairs,
      bool nightMode) {
    /// 给本日课程排序
    todayPairs.sort(
        (a, b) => a.arrange.unitList.first.compareTo(b.arrange.unitList.first));
    // 平时按时间线单列显示；只有超宽屏（至少三屏手机宽度）才分多列，
    // 每列 390~780 设计稿单位，保证时间、地点完整显示
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        gridDelegate: constraints.maxWidth >= _multiColumnMinWidth.w
            ? SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 780.w,
                mainAxisExtent: 90.h,
                crossAxisSpacing: 16.w,
              )
            : SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 90.h,
              ),
        itemCount: todayPairs.length,
        itemBuilder: (context, i) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5.h),
            child: Material(
              color:
                  WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
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
                splashColor:
                    WpyTheme.of(context).get(WpyColorKey.dislikeSecondary),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(35.w, 0, 25.w, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${getCourseTime(todayPairs[i].arrange.unitList)}   ${replaceBuildingWord(todayPairs[i].arrange.location)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtil.base.bold.sp(14).customColor(
                                    WpyTheme.of(context)
                                        .get(WpyColorKey.brightTextColor)
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              (todayPairs[i].arrange.isExperiment &
                                      CommonPreferences.isShowExperiment.value)
                                  ? "[实验] ${todayPairs[i].arrange.name!}"
                                  : todayPairs[i].first.name,
                              style: TextUtil.base.PingFangSC
                                  .bright(context)
                                  .bold
                                  .sp(14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      WButton(
                        onPressed: () =>
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
