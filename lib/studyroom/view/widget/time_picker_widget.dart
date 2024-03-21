import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/util/session_util.dart';
import 'package:we_pei_yang_flutter/studyroom/util/time_util.dart';

class TimePickerWidget extends StatelessWidget {
  TimePickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tableCalendar = _TableCalender();

    const tableClassTimes = _TableClassTimes();

    final okButton = WButton(
      onPressed: () => Navigator.pop(context),
      child: Container(
          width: 1.sw,
          height: 54.h + ScreenUtil().bottomBarHeight,
          color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          child: SafeArea(
            child: Center(
              child: Text(
                '确定',
                style: TextUtil.base.w400.PingFangSC.reverse(context).sp(14),
              ),
            ),
          )),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            15.w,
            20.h,
            15.w,
            10.h,
          ),
          child: Column(
            children: [
              tableCalendar,
              tableClassTimes,
              // SizedBox(height: 10.w),
            ],
          ),
        ),
        okButton,
      ],
    );
  }
}

class _TableCalender extends StatefulWidget {
  const _TableCalender({Key? key}) : super(key: key);

  @override
  _TableCalenderState createState() => _TableCalenderState();
}

class _TableCalenderState extends State<_TableCalender>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String dateTimeToNum(DateTime date) => num[date.weekday - 1];

  static const num = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _selectedDay = context.read<TimeProvider>().date;
      });
    });
  }

  Widget dowBuilder(_, DateTime date) {
    return Center(
      child: Text(
        dateTimeToNum(date),
        style: TextUtil.base.PingFangSC.bold.label(context).sp(16),
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      context.read<TimeProvider>().date = selectedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
      leftChevronIcon: SizedBox(height: 30.h),
      rightChevronIcon: SizedBox(height: 30.h),
      titleTextFormatter: (dateTime, _) {
        return '${dateTime.year}年${dateTime.month}月';
      },
      titleTextStyle: TextUtil.base.PingFangSC.w400.label(context).sp(16),
    );

    final calenderStyle = CalendarStyle(
      outsideDaysVisible: true,
      defaultTextStyle: TextUtil.base.PingFangSC.w400.primary(context).sp(16),
      outsideTextStyle: TextStyle(
        fontSize: 16.sp,
        color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
      ),
      disabledTextStyle: TextStyle(
        fontSize: 12.sp,
        color: WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor),
      ),
      selectedDecoration: BoxDecoration(
        color: WpyTheme.of(context)
            .get(WpyColorKey.primaryActionColor)
            .withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      selectedTextStyle:
          TextUtil.base.PingFangSC.w400.primaryAction(context).sp(16),
      todayDecoration: BoxDecoration(
        border: Border.all(
          color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
          width: 0.5.w,
        ),
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        fontSize: 16.sp,
        color: WpyTheme.of(context).get(WpyColorKey.basicTextColor),
      ),
    );

    final tableCalendar = TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(Duration(days: 6)),
      focusedDay: _focusedDay,
      daysOfWeekHeight: 40,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
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
  late ClassTimerange timeRange;

  @override
  void initState() {
    super.initState();

    // updateTimeRange(context.read<StudyroomProvider>().timeRange);
  }

  updateTimeRange(ClassTimerange range) {
    setState(() {
      timeRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _session = context.watch<TimeProvider>().session;

    Widget tableClassTimes = SizedBox(
      height: 220.h,
      child: GridView.count(
        scrollDirection: Axis.vertical,
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        children: List.generate(SessionIndexUtil.periods.length, (i) {
          var period = SessionIndexUtil.periods[i];
          return _TimeItem(
            title: period.toString(),
            isChecked: i + 1 == _session,
            onclick: () {
              if (i + 1 == _session) {
                context.read<TimeProvider>().session = -1;
              } else {
                context.read<TimeProvider>().session = i + 1;
              }
            },
          );
        }),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 5.w, 14.w, 0),
      child: tableClassTimes,
    );
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
      style: isChecked
          ? TextUtil.base.PingFangSC.w400.primaryAction(context).sp(12)
          : TextUtil.base.PingFangSC.w400.label(context).sp(12),
    );

    final button = TextButton(
      onPressed: onclick,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isChecked
              ? WpyTheme.of(context)
                  .get(WpyColorKey.primaryLightestActionColor)
                  .withOpacity(0.5)
              : WpyTheme.of(context)
                  .get(WpyColorKey.primaryBackgroundColor)
                  .withOpacity(0.1),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.w),
          ),
        ),
        overlayColor: WpyTheme.of(context).primary == null
            ? null
            : MaterialStateColor.resolveWith(
                (states) => WpyTheme.of(context).primary!.withOpacity(0.1)),
        side: MaterialStateProperty.all(
          BorderSide(
            color: isChecked
                ? WpyTheme.of(context).get(WpyColorKey.primaryActionColor)
                : WpyTheme.of(context).get(WpyColorKey.unlabeledColor),
            width: 0.5.w,
          ),
        ),
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
