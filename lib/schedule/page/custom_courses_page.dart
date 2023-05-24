import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/page/edit_detail_page.dart';

class CustomCoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var customCourses = context.watch<CourseProvider>().customCourses;
    return Stack(
      children: [
        Image.asset(
          "assets/images/schedule/custom_courses_bg.png",
          width: 1.sw,
          height: 1.sh,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(),
                  padding: EdgeInsets.fromLTRB(10.w, 9.h, 8.w, 8.h),
                  child: Image.asset(
                    'assets/images/schedule/back.png',
                    height: 20.r,
                    width: 20.r,
                  ),
                ),
              ),
            ),
            titleSpacing: 0,
            leadingWidth: 40.w,
            title: Text('我的自定义课程',
                style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
          ),
          body: Theme(
            data:
                Theme.of(context).copyWith(secondaryHeaderColor: Colors.white),
            child: ListView.builder(
              itemCount: customCourses.length,
              itemBuilder: (context, index) {
                return _item(context, customCourses[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, Course course, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<EditProvider>().load(course);
              Navigator.pushNamed(context, ScheduleRouter.editDetail,
                  arguments:
                      EditDetailPageArgs(index, course.name, course.credit));
            },
            splashFactory: InkRipple.splashFactory,
            borderRadius: BorderRadius.circular(10.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.name,
                      style: TextUtil.base.PingFangSC.bold.black2A.sp(16)),
                  SizedBox(height: 10.h),
                  ...course.arrangeList.map((arrange) {
                    var type = '每周';
                    if (arrange.weekList.length > 1) {
                      var odd = arrange.weekList.any((e) => e.isOdd);
                      var even = arrange.weekList.any((e) => e.isEven);
                      if (odd && !even) type = '单周';
                      if (even && !odd) type = '双周';
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '第${arrange.weekList.first}-${arrange.weekList.last}周 ${_weekDays[arrange.weekday]}',
                              style: TextUtil.base.PingFangSC.normal.black2A
                                  .sp(12)),
                          SizedBox(width: 5.w),
                          Text(_timeRange(arrange.unitList),
                              style:
                                  TextUtil.base.PingFangSC.w900.black00.sp(14)),
                          SizedBox(width: 5.w),
                          Text(type,
                              style: TextUtil.base.PingFangSC.normal.black2A
                                  .sp(12)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeRange(List<int> unitList) =>
      '${_startTimes[unitList.first]}-${_endTimes[unitList.last]}';

  static const _weekDays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _startTimes = [
    '',
    '08:30',
    '09:20',
    '10:25',
    '11:15',
    '13:30',
    '14:20',
    '15:25',
    '16:15',
    '18:30',
    '19:20',
    '20:10',
    '21:00'
  ];
  static const _endTimes = [
    '',
    '09:15',
    '10:05',
    '11:10',
    '12:00',
    '14:15',
    '15:05',
    '16:10',
    '17:00',
    '19:15',
    '20:05',
    '20:55',
    '21:45'
  ];
}
