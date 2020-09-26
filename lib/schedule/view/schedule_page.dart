import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/service/schedule_service.dart';
import 'class_table_widget.dart';
import 'week_select_widget.dart';

const double schedulePadding = 20;

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScheduleAppBar(),
      body: Theme(
        data: ThemeData(accentColor: Colors.white),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: schedulePadding),
          child: ListView(
            children: [
              TitleWidget(),
              WeekSelectWidget(),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClassTableWidget(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: GestureDetector(
            child: Icon(Icons.arrow_back,
                color: Color.fromRGBO(105, 109, 126, 1), size: 28),
            onTap: () => Navigator.pop(context)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.autorenew,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 25),
              onTap: () {
                Fluttertoast.showToast(
                    msg:"刷新数据中……",
                    textColor: Colors.white,
                    backgroundColor: Colors.blue,
                    timeInSecForIosWeb: 1,
                    fontSize: 16);
                getClassTable(onSuccess: (schedule) {
                  var provider = Provider.of<ScheduleNotifier>(context);
                  provider.termStart = schedule.termStart;
                  provider.coursesWithNotify = schedule.courses;
                  Fluttertoast.showToast(
                      msg: "刷新课程表数据成功",
                      textColor: Colors.white,
                      backgroundColor: Colors.green,
                      timeInSecForIosWeb: 1,
                      fontSize: 16);
                }, onFailure: (e) {
                  // TODO msg应和e相关
                  Fluttertoast.showToast(
                      msg: "刷新课程表数据失败",
                      textColor: Colors.white,
                      backgroundColor: Colors.red,
                      timeInSecForIosWeb: 1,
                      fontSize: 16);
                });
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.add,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 30),
              onTap: () {
                // TODO 更多功能
              }),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(
        builder: (context, notifier, _) => Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Text('Schedule',
                      style: TextStyle(
                          color: Color.fromRGBO(105, 109, 126, 1),
                          fontSize: 35,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 12),
                    child: Text('WEEK ${notifier.selectedWeek}',
                        style: TextStyle(
                            color: Color.fromRGBO(220, 220, 220, 1),
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ));
  }
}
