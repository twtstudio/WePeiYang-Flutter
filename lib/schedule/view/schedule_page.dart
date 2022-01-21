import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/gpa/view/classes_need_vpn_dialog.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/view/class_table_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/week_select_widget.dart';

class SchedulePage extends StatefulWidget {
  /// 星期栏是否收缩
  final ValueNotifier<bool> isShrink =
      ValueNotifier<bool>(CommonPreferences().scheduleShrink.value);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  /// 进入课程表页面后重设选中周并自动刷新数据
  _SchedulePageState() {
    var notifier = Provider.of<ScheduleNotifier>(
        WePeiYangApp.navigatorState.currentContext,
        listen: false);
    notifier.quietResetWeek();
    notifier.refreshSchedule().call();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CommonPreferences().firstUse.value) {
        CommonPreferences().firstUse.value = false;
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ClassesNeedVPNDialog());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleColor = FavorColors.scheduleTitleColor();
    return Scaffold(
      appBar: ScheduleAppBar(titleColor),
      backgroundColor: Colors.white,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          TitleWidget(titleColor),
          WeekSelectWidget(),
          ClassTableWidget(titleColor),
          HoursCounterWidget(titleColor)
        ],
      ),
    );
  }
}

class ScheduleAppBar extends StatelessWidget with PreferredSizeWidget {
  final Color titleColor;

  ScheduleAppBar(this.titleColor);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      leading: GestureDetector(
          child: Icon(Icons.arrow_back, color: titleColor, size: 32),
          onTap: () => Navigator.pop(context)),
      actions: [
        ValueListenableBuilder(
          valueListenable:
              context.findAncestorWidgetOfExactType<SchedulePage>().isShrink,
          builder: (_, value, __) {
            return IconButton(
              icon: Icon(
                  value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: titleColor,
                  size: 35),
              onPressed: () {
                var notifier = context
                    .findAncestorWidgetOfExactType<SchedulePage>()
                    .isShrink;
                notifier.value = !value;
                CommonPreferences().scheduleShrink.value = !value;
              },
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.autorenew, color: titleColor, size: 28),
          onPressed: () {
            if (CommonPreferences().isBindTju.value) {
              Provider.of<ScheduleNotifier>(context, listen: false)
                  .refreshSchedule(
                      hint: true,
                      onFailure: (e) {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) => TjuRebindDialog(
                                reason: e is WpyDioError
                                    ? e.error.toString()
                                    : null));
                      })
                  .call();
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class TitleWidget extends StatelessWidget {
  final Color titleColor;

  TitleWidget(this.titleColor);

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(
        builder: (context, notifier, _) => Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
              child: Row(
                children: [
                  Text('课程表',
                      style: FontManager.YaQiHei.copyWith(
                          color: titleColor, fontSize: 30)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 12),
                    child: Text('WEEK ${notifier.currentWeek}',
                        style: FontManager.Texta.copyWith(
                            color: Color.fromRGBO(114, 113, 113, 1),
                            fontSize: 16)),
                  )
                ],
              ),
            ));
  }
}

class HoursCounterWidget extends StatelessWidget {
  final Color titleColor;

  HoursCounterWidget(this.titleColor);

  @override
  Widget build(BuildContext context) {
    var notifier = Provider.of<ScheduleNotifier>(context, listen: false);
    if (notifier.coursesWithNotify.length == 0) return Container();
    int currentHours = getCurrentHours(notifier.currentWeek,
        DateTime.now().weekday, notifier.coursesWithNotify);
    int totalHours = getTotalHours(notifier.coursesWithNotify);
    double totalWidth = WePeiYangApp.screenWidth - 2 * 15;
    double leftWidth = totalWidth * currentHours / totalHours;
    if (leftWidth > totalWidth) leftWidth = totalWidth;

    /// 如果学期还没开始，则不显示学时
    if (notifier.isBeforeTermStart) leftWidth = 0;
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
                    color: titleColor),
              )
            ],
          ),
          SizedBox(height: 45)
        ],
      ),
    );
  }
}
