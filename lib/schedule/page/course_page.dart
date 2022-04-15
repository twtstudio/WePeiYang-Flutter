// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show WpyDioError;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/gpa/view/classes_need_vpn_dialog.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_detail_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_bottom_sheet.dart';
import 'package:we_pei_yang_flutter/schedule/view/week_select_widget.dart';

/// 课表总页面
class CoursePage extends StatefulWidget {
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      /// 初次使用课表时展示办公网dialog
      if (CommonPreferences.firstUse.value) {
        CommonPreferences.firstUse.value = false;
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ClassesNeedVPNDialog());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CourseAppBar(),
      backgroundColor: Colors.white,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _TitleWidget(),
          WeekSelectWidget(),
          CourseDetailWidget(),
          _HoursCounterWidget()
        ],
      ),
    );
  }
}

/// 课表页默认AppBar
class _CourseAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    var titleColor = FavorColors.scheduleTitleColor;

    var leading = Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
          child: Image.asset(
            'assets/images/schedule/back.png',
            height: 22,
            width: 22,
            color: titleColor,
          ),
        ),
      ),
    );

    var actions = [
      GestureDetector(
        onTap: () {
          if (!CommonPreferences.isBindTju.value) {
            ToastProvider.error("请绑定办公网");
            Navigator.pushNamed(context, AuthRouter.tjuBind);
            return;
          }
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
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/schedule/refresh.png',
            height: 25,
            width: 25,
            color: titleColor,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, ScheduleRouter.customCourse);
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/schedule/list.png',
            height: 25,
            width: 25,
            color: titleColor,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          var pvd = context.read<EditProvider>();
          pvd.init();
          showModalBottomSheet(
            context: context,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isDismissible: false,
            enableDrag: false,
            isScrollControlled: true,
            builder: (context) => EditBottomSheet(pvd.nameSave, pvd.creditSave),
          );
        },
        child: Container(
          decoration: BoxDecoration(),
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/schedule/add.png',
            height: 25,
            width: 25,
            color: titleColor,
          ),
        ),
      ),
    ];

    return AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      leading: leading,
      actions: actions,
      iconTheme: IconThemeData(color: titleColor, size: 28),
      leadingWidth: 60,
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
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: Row(
        children: [
          Text('课程表',
              style: FontManager.YaQiHei.copyWith(
                  color: FavorColors.scheduleTitleColor, fontSize: 30)),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 12),
            child: Builder(builder: (context) {
              var currentWeek =
                  context.select<CourseProvider, int>((p) => p.currentWeek);
              return Text('WEEK $currentWeek',
                  style: FontManager.Texta.copyWith(
                      color: Color.fromRGBO(114, 113, 113, 1), fontSize: 16));
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
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: Image.asset(
                      provider.shrink
                          ? 'assets/images/schedule/up.png'
                          : 'assets/images/schedule/down.png',
                      color: FavorColors.scheduleTitleColor,
                      height: 20,
                      width: 20),
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
    double totalWidth = WePeiYangApp.screenWidth - 2 * 15;
    double leftWidth = totalWidth * currentHours / totalHours;
    if (leftWidth > totalWidth) leftWidth = totalWidth;

    /// 如果学期还没开始，则不显示学时
    if (isBeforeTermStart) leftWidth = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerLeft,
              child: Text("Total Class Hours: $totalHours",
                  style: FontManager.Aspira.copyWith(
                      color: Color.fromRGBO(205, 206, 211, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.bold))),
          Stack(
            children: [
              Container(
                height: 12,
                width: totalWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(236, 238, 237, 1)),
              ),
              Container(
                height: 12,
                width: leftWidth,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(15)),
                    color: FavorColors.scheduleTitleColor),
              )
            ],
          ),
          SizedBox(height: 45)
        ],
      ),
    );
  }
}
