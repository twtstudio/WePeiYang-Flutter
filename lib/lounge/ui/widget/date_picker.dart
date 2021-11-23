import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/service/repository.dart';
import 'package:we_pei_yang_flutter/lounge/service/time_factory.dart';
import 'package:we_pei_yang_flutter/lounge/view_model/lounge_time_model.dart';

class TimeCheckWidget extends StatelessWidget {
  const TimeCheckWidget({
    Key key,
  }) : super(key: key);

  _modalBottomSheetMenu(BuildContext context) async {
    await initializeDateFormatting();
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: BottomDatePicker());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
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
    );
  }
}

class BottomDatePicker extends StatefulWidget {
  @override
  _BottomDatePickerState createState() => _BottomDatePickerState();
}

class _BottomDatePickerState extends State<BottomDatePicker>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  List<ClassTime> currentTime = [];
  LoungeTimeModel model;
  DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this)
          ..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusedDay = model.dateTime;
      model.classTime.forEach((v) {
        updateGroupValue(v);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      padding: const EdgeInsets.all(10),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          AbsorbPointer(
            absorbing: cannotTap,
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              locale: Intl.getCurrentLocale(),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: CalendarFormat.month,
              // formatAnimation: FormatAnimation.slide,
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                headerMargin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              ),
              calendarStyle: CalendarStyle(outsideDaysVisible: true),

              calendarBuilders:
                  CalendarBuilders(selectedBuilder: (context, date, _) {
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
                          style: FontManager.YaHeiRegular.copyWith(
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              }, todayBuilder: (context, date, _) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0XFF62677B), width: 1),
                      shape: BoxShape.circle,
                    ),
                    width: 35,
                    height: 35,
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: FontManager.YaHeiRegular.copyWith(
                          fontSize: 16,
                          color: Color(0XFF62677B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }, dowBuilder: (context, date) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Center(
                    child: Text(dateTimeToNum(date)),
                  ),
                );
              }),
              onDaySelected: (selectedDay, focusedDay) async {
                _animationController.forward(from: 0.0);
                await model.setTime(date: selectedDay);
                if (mounted) _focusedDay = focusedDay;
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              // initialSelectedDay: model.dateTime,
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
              Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  S.current.ok,
                  style: FontManager.YaQiHei.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF62677B),
                  ),
                ),
              ),
              SizedBox(width: 20)
            ],
          )
        ],
      ),
    );
  }

  static const num = ['一', '二', '三', '四', '五', '六', '日'];

  String dateTimeToNum(DateTime date) => num[date.weekday - 1];
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
    return Center(
      child: InkWell(
        onTap: onclick,
        child: Container(
          height: 45,
          width: 130,
          padding: const EdgeInsets.all(5),
          decoration: isChecked
              ? BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(22.5),
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
                fontSize: 14,
                color: isChecked ? Colors.white : Color(0XFF62677B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
