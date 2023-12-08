import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/util/theme_util.dart';
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
          color: ColorUtil.blue2CColor,
          child: SafeArea(
            child: Center(
              child: Text(
                '确定',
                style: TextUtil.base.w400.PingFangSC.white.sp(14),
              ),
            ),
          )),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 20.h,
          ),
          child: Column(
            children: [tableCalendar, tableClassTimes, SizedBox(height: 10.w)],
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
        _selectedDay = context.read<StudyroomProvider>().dateTime;
      });
    });
  }

  Widget dowBuilder(_, DateTime date) {
    return Center(
      child: Text(
        dateTimeToNum(date),
        style: TextUtil.base.PingFangSC.bold.black2A.sp(16),
      ),
    );
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      context.read<StudyroomProvider>().setDateTime(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
      leftChevronIcon: Icon(
        Icons.chevron_left,
        color: ColorUtil.black2AColor,
        size: 30.w,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        color: ColorUtil.black2AColor,
        size: 30.w,
      ),
      titleTextFormatter: (dateTime, _) {
        return '${dateTime.year}年${dateTime.month}月';
      },
      titleTextStyle: TextUtil.base.PingFangSC.w400.black2A.sp(16),
    );

    final calenderStyle = CalendarStyle(
      outsideDaysVisible: true,
      defaultTextStyle: TextUtil.base.PingFangSC.w400.black2A.sp(16),
      outsideTextStyle: TextStyle(
        fontSize: 16.sp,
        color: Theme.of(context).calenderOutsideText,
      ),
      selectedDecoration: BoxDecoration(
        color: Theme.of(context).calenderSelectBackground,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: TextUtil.base.PingFangSC.w400.blue2C.sp(16),
      todayDecoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).calenderTodayBorder,
          width: 0.5.w,
        ),
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        fontSize: 16.sp,
        color: Theme.of(context).calenderTodayText,
      ),
    );
    final termStart = DateTime.parse(CommonPreferences.termStartDate.value);
    final termEnd = termStart.add(Duration(days: 180));

    final tableCalendar = TableCalendar(
      firstDay: termStart,
      lastDay: termEnd,
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
  late ClassTimerange timeRange;

  @override
  void initState() {
    super.initState();

    updateTimeRange(context.read<StudyroomProvider>().timeRange);
  }

  updateTimeRange(ClassTimerange range) {
    setState(() {
      timeRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget tableClassTimes = GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.6,
      children: Time.rangeList.map((range) {
        return _TimeItem(
          title: range.timeRange,
          isChecked: timeRange == range,
          onclick: () {
            setState(() {
              updateTimeRange(range);
            });
            context.read<StudyroomProvider>().setTimeRange(timeRange);
          },
        );
      }).toList(),
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
          ? TextUtil.base.PingFangSC.w400.blue2C.sp(12)
          : TextUtil.base.PingFangSC.w400.black2A.sp(12),
    );

    final button = TextButton(
      onPressed: onclick,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.w),
          ),
        ),
        side: MaterialStateProperty.all(
          BorderSide(
            color: isChecked
                ? Theme.of(context).calenderTimeTableBorder
                : ColorUtil.grey97Color,
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
