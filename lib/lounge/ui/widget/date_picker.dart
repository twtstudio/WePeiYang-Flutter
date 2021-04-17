import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/lounge/service/repository.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';

class TimeCheckWidget extends StatelessWidget {
  const TimeCheckWidget({
    Key key,
  }) : super(key: key);

  _modalBottomSheetMenu(BuildContext context) async {
    await initializeDateFormatting()
        .then((value) async => await showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: BottomDatePicker());
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Builder(
        builder: (_) => InkWell(
          onTap: () async => await _modalBottomSheetMenu(context),
          child: Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                size: 25,
                color: Color(0XFF62677B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomDatePicker extends StatefulWidget {
  @override
  _BottomDatePickerState createState() => _BottomDatePickerState();
}

class _BottomDatePickerState extends State<BottomDatePicker>
    with TickerProviderStateMixin {
  CalendarController _calendarController;
  AnimationController _animationController;
  List<ClassTime> currentTime = [];
  LoungeTimeModel model;
  FToast _fToast;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _fToast = FToast();
    _fToast.init(context);
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this)
          ..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print(Time.classOfDay(DateTime.now()).timeRange);
      // updateGroupValue(Time.classOfDay(DateTime.now()));
      model.classTime.forEach((v) {
        updateGroupValue(v);
      });
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(Icons.check),
          // SizedBox(
          //   width: 12.0,
          // ),
          Text("正在加载数据，请稍后"),
        ],
      ),
    );

    _fToast.removeQueuedCustomToasts();

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 1),
    );
  }

  void updateGroupValue(ClassTime v) {
    setState(() {
      currentTime.contains(v) ? currentTime.remove(v) : currentTime.add(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    model = Provider.of<LoungeTimeModel>(context);
    var cannotTap = !(LoungeRepository.canLoadLocalData == true &&
        LoungeRepository.canLoadTemporaryData == true);
    return Padding(
      padding: EdgeInsets.all(10),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          GestureDetector(
            onTap: (){
              if(cannotTap){
                _showToast();
              }
            },
            child: AbsorbPointer(
              absorbing: cannotTap,
              child: TableCalendar(
                locale: Intl.getCurrentLocale(),
                calendarController: _calendarController,
                startingDayOfWeek: StartingDayOfWeek.monday,
                initialCalendarFormat: CalendarFormat.month,
                formatAnimation: FormatAnimation.slide,
                availableGestures: AvailableGestures.horizontalSwipe,
                headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonVisible: false,
                    headerMargin: EdgeInsets.fromLTRB(0, 8, 0, 8)),
                calendarStyle: CalendarStyle(
                    outsideDaysVisible: true,
                    todayStyle: TextStyle().copyWith(color: Color(0XFF62677B)),
                    weekdayStyle: TextStyle().copyWith(color: Color(0XFF62677B)),
                    weekendStyle: TextStyle().copyWith(color: Color(0XFF62677B)),
                    unavailableStyle:
                        TextStyle().copyWith(color: Color(0XFFCFD0D5))),
                builders:
                    CalendarBuilders(selectedDayBuilder: (context, date, _) {
                  return FadeTransition(
                    opacity:
                        Tween(begin: 0.0, end: 1.0).animate(_animationController),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0XFF62677B),
                        ),
                        width: 35,
                        height: 35,
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                }, todayDayBuilder: (context, date, _) {
                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0XFF62677B),
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      width: 35,
                      height: 35,
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle()
                              .copyWith(fontSize: 16, color: Color(0XFF62677B)),
                        ),
                      ),
                    ),
                  );
                }, dowWeekdayBuilder: (context, date) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 13),
                    child: Container(
                      child: Center(
                        child: Text(date),
                      ),
                    ),
                  );
                }),
                onDaySelected: (date, events, holidays) async {
                  _fToast.removeCustomToast();
                  _fToast.removeQueuedCustomToasts();
                  _animationController.forward(from: 0.0);
                  await model.setTime(date: date);
                },
                initialSelectedDay: model.dateTime,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              children: Time.rangeList.map((range) {
                return TimeItem(
                  title: range.timeRange,
                  isChecked: currentTime.contains(range),
                  onclick: () async {
                    updateGroupValue(range);
                    await model.setTime(schedule: currentTime);
                  },
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(child: SizedBox()),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '确定',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF62677B),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              )
            ],
          )
        ],
      ),
    );
  }
}

class TimeItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final VoidCallback onclick;

  const TimeItem({
    @required this.title,
    @required this.isChecked,
    @required this.onclick,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: InkWell(
          onTap: () {
            onclick();
          },
          child: Container(
            height: 45,
            width: 130,
            padding: EdgeInsets.all(5),
            decoration: isChecked
                ? BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(22.5)),
                    color: Color(0XFF62677B))
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(22.5),
                    border: Border.all(
                      color: Color(0XFF62677B),
                      width: 1,
                    )),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: isChecked ? Colors.white : Color(0XFF62677B),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
