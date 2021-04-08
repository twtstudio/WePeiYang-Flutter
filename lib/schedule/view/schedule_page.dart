import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/home/model/home_model.dart';
import 'package:wei_pei_yang_demo/schedule/extension/logic_extension.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import '../../main.dart';
import 'class_table_widget.dart';
import 'week_select_widget.dart';
import 'package:wei_pei_yang_demo/commons/res/color.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/auth/view/info/tju_rebind_dialog.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class SchedulePage extends StatefulWidget {
  /// 进入课程表页面后重设选中周并自动刷新数据
  SchedulePage() {
    var notifier = Provider.of<ScheduleNotifier>(
        WeiPeiYangApp.navigatorState.currentContext);
    notifier.quietResetWeek();
    notifier.refreshSchedule(hint: false);
  }

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: ClassTableWidget(),
          ),
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
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.autorenew, color: titleColor, size: 28),
              onTap: () {
                if (CommonPreferences().isBindTju.value) {
                  Provider.of<ScheduleNotifier>(context, listen: false)
                      .refreshSchedule(onFailure: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => TjuRebindDialog());
                  }).call();
                } else {
                  ToastProvider.error("请绑定办公网");
                  Navigator.pushNamed(context, AuthRouter.tjuBind);
                }
              }),
        ),
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
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Row(
                children: [
                  Text('Schedule',
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 35,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 12),
                    child: Text('today: WEEK ${notifier.currentWeek}',
                        style: TextStyle(
                            color: Color.fromRGBO(205, 206, 211, 1),
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
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
    var notifier = Provider.of<ScheduleNotifier>(context);
    if (notifier.coursesWithNotify.length == 0) return Container();
    int currentHours = getCurrentHours(notifier.currentWeek,
        DateTime.now().weekday, notifier.coursesWithNotify);
    int totalHours = getTotalHours(notifier.coursesWithNotify);
    double totalWidth = GlobalModel().screenWidth - 2 * 15;
    double leftWidth = totalWidth * currentHours / totalHours;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerLeft,
              child: Text("Total Class Hours: $totalHours",
                  style: TextStyle(
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
          Container(height: 45)
        ],
      ),
    );
  }
}
