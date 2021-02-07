import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'class_table_widget.dart';
import 'week_select_widget.dart';

/// schedule页面两边的白边
const double schedulePadding = 15;

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 60,
      color: Color.fromRGBO(105, 109, 126, 1),
      onRefresh: Provider.of<ScheduleNotifier>(context).refreshSchedule(),
      child: Scaffold(
        appBar: ScheduleAppBar(),
        body: Container(
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
      leading: GestureDetector(
          child: Icon(Icons.arrow_back,
              color: Color.fromRGBO(105, 109, 126, 1), size: 32),
          onTap: () => Navigator.pop(context)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: GestureDetector(
              child: Icon(Icons.autorenew,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 28),
              onTap: Provider.of<ScheduleNotifier>(context).refreshSchedule()),
        ),
      ],
    );
  }

  // TODO 测试用，以后删(不舍得手敲了半天的假数据罢了)
  void test(BuildContext context) {
    List<Course> courses = [];
    courses.add(Course("1230000", "32100", "大学物理2B", "4.0", "冯星辉(讲师)", "北洋园",
        Week("4", "19"), Arrange("单周", "33楼221", "1", "2", "1")));
    courses.add(Course("1230000", "32100", "大学物理2B", "4.0", "冯星辉(讲师)", "北洋园",
        Week("4", "19"), Arrange("单双周", "33楼221", "3", "4", "3")));
    courses.add(Course(
        "1230000",
        "32100",
        "算法设计与分析",
        "3.0",
        "刘春凤(副教授),宫秀军(副教授)",
        "北洋园",
        Week("4", "17"),
        Arrange("单双周", "55楼A区308", "3", "4", "1")));
    courses.add(Course(
        "1230000",
        "32100",
        "算法设计与分析",
        "3.0",
        "刘春凤(副教授),宫秀军(副教授)",
        "北洋园",
        Week("4", "17"),
        Arrange("单双周", "55楼A区308", "7", "8", "3")));
    courses.add(Course("1230000", "32100", "马克思主义基本原理", "3.0", "刘金增(讲师)", "北洋园",
        Week("4", "19"), Arrange("单双周", "46楼A区303", "7", "8", "1")));
    courses.add(Course("1230000", "32100", "马克思主义基本原理", "3.0", "刘金增(讲师)", "北洋园",
        Week("4", "19"), Arrange("单周", "46楼A区303", "1", "2", "3")));
    courses.add(Course("1230000", "32100", "人类文明史漫谈（翻转）", "2.0", "张凯峰(讲师)",
        "北洋园", Week("4", "19"), Arrange("单双周", "46楼A区303", "9", "10", "1")));
    courses.add(Course("1230000", "32100", "操作系统原理", "3.0", "李罡(讲师)", "北洋园",
        Week("4", "17"), Arrange("单双周", "55楼B区316", "5", "6", "4")));
    courses.add(Course("1230000", "32100", "操作系统原理", "3.0", "李罡(讲师)", "北洋园",
        Week("4", "17"), Arrange("单双周", "55楼B区316", "1", "2", "2")));
    courses.add(Course("1230000", "32100", "概率论与数理统计1", "3.0", "吴华明(副研究员)",
        "北洋园", Week("4", "15"), Arrange("单双周", "46楼A309", "1", "2", "5")));
    courses.add(Course("1230000", "32100", "概率论与数理统计1", "3.0", "吴华明(副研究员)",
        "北洋园", Week("4", "15"), Arrange("单双周", "46楼A309", "3", "4", "2")));
    courses.add(Course("1230000", "32100", "体育C（体育舞蹈）", "1.0", "郭营(讲师)", "北洋园",
        Week("4", "19"), Arrange("单双周", "", "5", "6", "2")));
    courses.add(Course("1230000", "32100", "计算机产业前沿与创新创业", "1.0", "王文俊(教授)",
        "北洋园", Week("12", "19"), Arrange("单双周", "46楼A208", "7", "8", "2")));
    courses.add(Course("1230000", "32100", "大学英语3", "2.0", "张宇(讲师)", "北洋园",
        Week("4", "19"), Arrange("单双周", "46楼A114", "5", "6", "3")));
    courses.add(Course("1230000", "32100", "物理实验A", "1.0", "刘云朋(副教授)", "北洋园",
        Week("4", "19"), Arrange("单周", "", "1", "4", "4")));
    Provider.of<ScheduleNotifier>(context).coursesWithNotify = courses;
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
                    child: Text('WEEK ${notifier.currentWeek}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ));
  }
}
