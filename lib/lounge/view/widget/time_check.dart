// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

class TimeCheckWidget extends StatelessWidget {
  const TimeCheckWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeCheckerIcon = Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            // add itnl
            // await initializeDateFormatting();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7.w),
                  topRight: Radius.circular(7.w),
                ),
              ),
              builder: (_) => const _BottomDatePicker(),
            );
          },
          child: Icon(
            Icons.date_range_rounded,
            size: 26.w,
            color: Theme.of(context).baseIconColor,
          ),
        );
      },
    );

    return timeCheckerIcon;
  }
}

class _BottomDatePicker extends StatelessWidget {
  const _BottomDatePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // debugPrint('build _BottomDatePicker');

    const tableCalendar = _LoungeTableCalender();

    const tableClassTimes = _TableClassTimes();

    const okButton = _OkButton();

    Widget viewList = ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        tableCalendar,
        tableClassTimes,
        SizedBox(height: 10.w),
        okButton,
      ],
    );

    viewList = Padding(
      padding: EdgeInsets.only(
        left: 15.w,
        top: 20.w,
        right: 15.w,
        bottom: 30.w,
      ),
      child: viewList,
    );

    return viewList;
  }
}

class _LoungeTableCalender extends StatefulWidget {
  const _LoungeTableCalender({Key? key}) : super(key: key);

  @override
  __LoungeTableCalenderState createState() => __LoungeTableCalenderState();
}

class __LoungeTableCalenderState extends State<_LoungeTableCalender>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _animationController;

  String dateTimeToNum(DateTime date) => num[date.weekday - 1];

  static const num = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        _selectedDay = context.read<LoungeConfig>().dateTime;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget dowBuilder(_, DateTime date) => Center(
        child: Text(
          dateTimeToNum(date),
          style: TextStyle(
            color: Theme.of(context).calenderBaseText,
            fontSize: 13.sp,
            // fontWeight: FontWeight.bold,
          ),
        ),
      );

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      context.read<LoungeConfig>().setTime(date: selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
      leftChevronIcon: Icon(
        Icons.chevron_left,
        color: Theme.of(context).calenderBaseText,
        size: 17.w,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        color: Theme.of(context).calenderBaseText,
        size: 17.w,
      ),
      titleTextFormatter: (dateTime, _) {
        return '${dateTime.year}年 ${dateTime.month}月';
      },
      titleTextStyle: TextStyle(
        color: Theme.of(context).calenderBaseText,
        fontSize: 14.sp,
        // fontWeight: FontWeight.bold,
      ),
    );

    final calenderStyle = CalendarStyle(
      outsideDaysVisible: true,
      defaultTextStyle: TextStyle(
        fontSize: 13.sp,
        color: Theme.of(context).calenderBaseText,
      ),
      outsideTextStyle: TextStyle(
        fontSize: 13.sp,
        color: Theme.of(context).calenderOutsideText,
      ),
      selectedDecoration: BoxDecoration(
        color: Theme.of(context).calenderSelectBackground,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: TextStyle(
        color: Theme.of(context).calenderSelectText,
        fontSize: 13.sp,
      ),
      todayDecoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).calenderTodayBorder,
          width: 0.5.w,
        ),
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        fontSize: 12.sp,
        color: Theme.of(context).calenderTodayText,
        fontWeight: FontWeight.bold,
      ),
    );

    final tableCalendar = TableCalendar(
      firstDay: DateTime.utc(2010, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      // locale: Intl.getCurrentLocale(),
      daysOfWeekHeight: 40,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      // formatAnimation: FormatAnimation.slide,
      availableGestures: AvailableGestures.horizontalSwipe,
      headerStyle: headerStyle,
      calendarStyle: calenderStyle,
      calendarBuilders: CalendarBuilders(
        dowBuilder: dowBuilder,
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      // initialSelectedDay: model.dateTime,
    );

    return tableCalendar;
  }
}

class _TableClassTimes extends StatefulWidget {
  const _TableClassTimes({Key? key}) : super(key: key);

  @override
  _TableClassTimesState createState() => _TableClassTimesState();
}

class _TableClassTimesState extends State<_TableClassTimes> {
  List<ClassTime> timeRange = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      context.read<LoungeConfig>().timeRange.forEach((v) {
        updateGroupValue(v);
      });
      setState(() {});
    });
  }

  void updateGroupValue(ClassTime v) {
    timeRange.contains(v) ? timeRange.remove(v) : timeRange.add(v);
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('build _TableClassTimesState');

    Widget tableClassTimes = GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.6,
      children: Time.rangeList.map((range) {
        return _TimeItem(
          title: range.timeRange,
          isChecked: timeRange.contains(range),
          onclick: () {
            setState(() {
              updateGroupValue(range);
            });
            context.read<LoungeConfig>().setTime(range: timeRange);
          },
        );
      }).toList(),
    );

    tableClassTimes = Padding(
      padding: EdgeInsets.fromLTRB(14.w, 5.w, 14.w, 0),
      child: tableClassTimes,
    );

    return tableClassTimes;
  }
}

class _TimeItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final VoidCallback onclick;

  const _TimeItem({
    required this.title,
    required this.isChecked,
    required this.onclick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        color: isChecked
            ? Theme.of(context).calenderTimeTableSelectText
            : Theme.of(context).calenderTimeTableText,
      ),
    );

    final button = TextButton(
      onPressed: onclick,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19.w),
          ),
        ),
        side: MaterialStateProperty.all(
          BorderSide(
            color: Theme.of(context).calenderTimeTableBorder,
            width: 0.5.w,
          ),
        ),
        backgroundColor: isChecked
            ? MaterialStateProperty.all(
                Theme.of(context).calenderTimeTableSelectBackground,
              )
            : null,
      ),
      child: Center(child: text),
    );

    return Center(
      child: SizedBox(
        height: 38.w,
        width: 122.w,
        child: button,
      ),
    );
  }
}

class _OkButton extends StatelessWidget {
  const _OkButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '确定',
            style: TextStyle(
              color: Theme.of(context).calenderOkButton,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 19.w),
      ],
    );
  }
}
