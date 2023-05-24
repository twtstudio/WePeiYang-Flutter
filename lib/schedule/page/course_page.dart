import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show WpyDioError;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/gpa/view/classes_need_vpn_dialog.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_detail_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_dialog.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_bottom_sheet.dart';
import 'package:we_pei_yang_flutter/schedule/view/week_select_widget.dart';

/// 课表总页面
class CoursePage extends StatefulWidget {
  final List<Pair<Course, int>> pairs;

  const CoursePage(this.pairs);

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  /// 进入课程表页面后重设选中周并自动刷新数据
  _CoursePageState() {
    var provider =
        WePeiYangApp.navigatorState.currentContext!.read<CourseProvider>();
    provider.quietResetWeek();
    provider.refreshCourse();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 初次使用课表时展示办公网dialog
      if (CommonPreferences.firstClassesDialog.value) {
        CommonPreferences.firstClassesDialog.value = false;
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ClassesNeedVPNDialog());
      }
      if (widget.pairs.isNotEmpty && widget.pairs.isNotEmpty) {
        showCourseDialog(context, widget.pairs);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/schedule/home_bg.jpg",
          width: 1.sw,
          height: 1.sh,
          fit: BoxFit.cover,
        ),
        Scaffold(
          appBar: _CourseAppBar(),
          backgroundColor: Colors.transparent,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _TitleWidget(),
              WeekSelectWidget(),
              Column(
                children: [CourseDetailWidget(), _HoursCounterWidget()],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 课表页默认AppBar
class _CourseAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    var leading = Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.fromLTRB(0, 8.h, 8.w, 8.h),
          child: Image.asset(
            'assets/images/schedule/back.png',
            height: 18.r,
            width: 18.r,
            color: Colors.white,
          ),
        ),
      ),
    );

    var actions = [
      GestureDetector(
        onTap: () {
          context.read<CourseProvider>().refreshCourse(
              hint: true,
              onFailure: (e) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => TjuRebindDialog(
                    reason: e is WpyDioError ? e.error.toString() : null,
                  ),
                );
              });
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.all(10.r),
          child: Image.asset(
            'assets/images/schedule/refresh.png',
            height: 20.r,
            width: 20.r,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ScheduleRouter.customCourse);
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.all(10.r),
          child: Image.asset(
            'assets/images/schedule/list.png',
            height: 20.r,
            width: 20.r,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          var pvd = context.read<EditProvider>();
          pvd.init();
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            isDismissible: true,
            enableDrag: false,
            isScrollControlled: true,
            builder: (context) => EditBottomSheet(pvd.nameSave, pvd.creditSave),
          );
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: EdgeInsets.all(10.r),
          child: Image.asset(
            'assets/images/schedule/add.png',
            height: 20.r,
            width: 20.r,
          ),
        ),
      ),
      SizedBox(width: 5.w),
    ];

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      leadingWidth: 40.w,
      actions: actions,
      title: Text(
          'HELLO${(CommonPreferences.lakeNickname.value == '') ? '' : ', ${CommonPreferences.lakeNickname.value}'}',
          style: TextUtil.base.white.w900.sp(18)),
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 课表页标题栏
class _TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 5.h),
      child: Row(
        children: [
          Text('Schedule', style: TextUtil.base.w900.white.sp(18)),
          Padding(
            padding: EdgeInsets.only(left: 8.w, top: 4.h),
            child: Builder(builder: (context) {
              var currentWeek =
                  context.select<CourseProvider, int>((p) => p.currentWeek);
              return Text('WEEK $currentWeek',
                  style: TextUtil.base.Swis.bold
                      .sp(12)
                      .customColor(Color.fromRGBO(202, 202, 202, 1)));
            }),
          ),
          Builder(builder: (context) {
            var provider = context.watch<CourseDisplayProvider>();
            return GestureDetector(
                onTap: () {
                  provider.shrink = !provider.shrink;
                },
                child: Container(
                  decoration: BoxDecoration(),
                  padding: EdgeInsets.fromLTRB(8.w, 5.h, 8.w, 0),
                  child: Image.asset(
                      provider.shrink
                          ? 'assets/images/schedule/up.png'
                          : 'assets/images/schedule/down.png',
                      color: Colors.white,
                      height: 18.r,
                      width: 18.r),
                ));
          })
        ],
      ),
    );
  }
}

/// 课表页底部学时统计栏
class _HoursCounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<CourseProvider>();
    if (provider.schoolCourses.length == 0) return Container();
    int currentHours = getCurrentHours(
        provider.currentWeek, DateTime.now().weekday, provider.schoolCourses);
    int totalHours = getTotalHours(provider.schoolCourses);

    double totalWidth = 1.sw - 2 * 15.w;
    double leftWidth = totalWidth * currentHours / totalHours;
    if (leftWidth > totalWidth) leftWidth = totalWidth;

    /// 如果学期还没开始，则不显示学时
    if (isBeforeTermStart) leftWidth = 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 8.h),
              alignment: Alignment.centerLeft,
              child: Text("Total Class Hours: $totalHours",
                  style: TextUtil.base.Swis.bold.white.sp(12))),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12.h,
                width: totalWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: Colors.black12),
              ),
              Container(
                height: 8.h,
                width: leftWidth,
                margin: EdgeInsets.only(left: 2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white54],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 45.h)
        ],
      ),
    );
  }
}
