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
import 'package:we_pei_yang_flutter/schedule/view/course_detail_widget.dart';
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

/// 课表页AppBar
class _CourseAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    var quietDisplayPvd = context.read<CourseDisplayProvider>();
    var titleColor = FavorColors.scheduleTitleColor;
    return AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      leading: GestureDetector(
          child: Icon(Icons.arrow_back, color: titleColor, size: 32),
          onTap: () => Navigator.pop(context)),
      actions: [
        Builder(
          builder: (context) {
            var shrink =
                context.select<CourseDisplayProvider, bool>((p) => p.shrink);
            return IconButton(
              icon: Icon(
                  shrink ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: titleColor,
                  size: 35),
              onPressed: () {
                quietDisplayPvd.shrink = !shrink;
              },
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.autorenew, color: titleColor, size: 28),
          onPressed: () {
            if (CommonPreferences.isBindTju.value) {
              context.read<CourseProvider>().refreshCourse(
                    hint: true,
                    onFailure: (e) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return TjuRebindDialog(
                            reason:
                                e is WpyDioError ? e.error.toString() : null,
                          );
                        },
                      );
                    },
                  );
            } else {
              ToastProvider.error("请绑定办公网");
              Navigator.pushNamed(context, AuthRouter.tjuBind);
            }
          },
        ),
        SizedBox(width: 10),
      ],
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
                  context.select<CourseProvider, int>((p) => p.selectedWeek);
              return Text('WEEK $currentWeek',
                  style: FontManager.Texta.copyWith(
                      color: Color.fromRGBO(114, 113, 113, 1), fontSize: 16));
            }),
          ),
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
    if (provider.courses.length == 0) return Container();
    int currentHours = getCurrentHours(
        provider.currentWeek, DateTime.now().weekday, provider.courses);
    int totalHours = getTotalHours(provider.courses);
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
