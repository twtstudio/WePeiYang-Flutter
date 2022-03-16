// @dart = 2.12
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/provider/room_favor_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/data_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/base_page.dart';

class _RoomPlanData extends LoungeDataChangeNotifier {
  final Classroom _room;

  Classroom get room => _room;

  final RefreshController _refreshController;

  RefreshController get refreshController => _refreshController;

  final BuildContext _context;

  set room(Classroom data) {
    if (data != _room) {
      _room.statuses = Map.from(data.statuses);
    }
  }

  _RoomPlanData._(this._room, this._refreshController, this._context);

  factory _RoomPlanData(BuildContext context, Classroom room) {
    final dataProvider = context.read<BuildingData>();
    final data = dataProvider.getClassroom(room);
    return _RoomPlanData._(
      Classroom.deepCopy(data),
      RefreshController(),
      context,
    );
  }

  // TODO: 存在可能时间不一样，教室不一样
  @override
  void getNewData(BuildingData dataProvider) {
    final newData = dataProvider
        .buildings[_room.bId]?.areas[_room.aId]?.classrooms[_room.id];
    if (newData != null) {
      room = newData;
      stateSuccess('刷新教室数据成功');
    } else {
      ToastProvider.error('新数据出现错误');
      stateError();
    }
  }

  @override
  void getDataError() {
    ToastProvider.error('刷新出现错误');
    stateError();
  }

  @override
  bool stateSuccess([String? msg]) {
    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }
    return super.stateSuccess(msg);
  }

  @override
  bool stateError([String? msg]) {
    if (_refreshController.isRefresh) {
      _refreshController.refreshFailed();
    }
    return super.stateError(msg);
  }

  @override
  bool stateRefreshing({msg, notifier = true}) {
    return super.stateRefreshing(
      msg: msg,
      notifier: !_refreshController.isRefresh,
    );
  }

  void onRefresh() {
    _context.read<BuildingData>().getDataOfWeek();
  }
}

class RoomPlanPage extends StatelessWidget {
  final Classroom room;

  const RoomPlanPage({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageTitle = Padding(
      padding: EdgeInsets.only(left: 21.w, right: 11.w),
      child: PageTitleWidget(room: room),
    );

    final table = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.w),
      child: const ClassTableWidget(),
    );

    Widget body = Builder(
      builder: (context) => SmartRefresher(
        controller: context.read<_RoomPlanData>().refreshController,
        onRefresh: context.read<_RoomPlanData>().onRefresh,
        header: ClassicHeader(),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [pageTitle, table],
        ),
      ),
    );

    body = ChangeNotifierProxyProvider<BuildingData, _RoomPlanData>(
      create: (context) => _RoomPlanData(context, room),
      update: (context, dataProvider, data) {
        if (data == null) {
          return _RoomPlanData(context, room);
        }
        return data..update(dataProvider);
      },
      child: body,
    );

    return LoungeBasePage(body: body);
  }
}

class PageTitleWidget extends StatelessWidget {
  final Classroom room;

  const PageTitleWidget({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = Text(
      DataFactory.getRoomTitle(room),
      style: TextStyle(
        color: Theme.of(context).roomTitle,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
      ),
    );

    final convertedWeek = Builder(builder: (context) {
      final dateTime = context.select(
        (LoungeConfig config) => config.dateTime,
      );
      return Text(
        'WEEK ${dateTime.convertedWeek}',
        style: TextStyle(
          color: Theme.of(context).roomConvertWeek,
          fontSize: 14.sp,
        ),
      );
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        title,
        Padding(
          padding: EdgeInsets.only(bottom: 3.w, left: 20.w),
          child: convertedWeek,
        ),
        const Spacer(),
        _FavorButton(room),
      ],
    );
  }
}

class _FavorButton extends StatelessWidget {
  final Classroom room;

  const _FavorButton(this.room, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        onPrimary: Colors.transparent,
        onSurface: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: () {
        context.read<RoomFavour>().changeFavor(room);
      },
      child: Builder(builder: (context) {
        final unFavorStyle = TextStyle(
          color: Theme.of(context).favorButtonUnfavor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w900,
        );

        final favorStyle = unFavorStyle.copyWith(
          color: Theme.of(context).favorButtonFavor,
        );

        final isFavor = context.select(
          (RoomFavour data) => data.favourList.containsKey(room.id),
        );

        if (isFavor) {
          return Text('已收藏', style: favorStyle);
        } else {
          return Text('收藏', style: unFavorStyle);
        }
      }),
    );
  }
}

double get cardStep => 6.w;

double get schedulePadding => 11.67.w;

double get countTabWidth => 22.67.w;

double get dateTabHeight => 28.27.w;

/// 这个Widget包括日期栏和下方的具体课程
class ClassTableWidget extends StatelessWidget {
  const ClassTableWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wholeWidth = MediaQuery.of(context).size.width - schedulePadding * 2;
    final dayCount = CommonPreferences.dayNumber.value;
    final cardWidth =
        (wholeWidth - countTabWidth - dayCount * cardStep) / dayCount;
    final tabHeight = cardWidth * 136 / 96;
    final wholeHeight = tabHeight * 12 + cardStep * 12 + dateTabHeight;

    final weekBar = Positioned(
      top: 0,
      left: cardStep + countTabWidth,
      child: SizedBox(
        height: dateTabHeight,
        width: cardWidth * dayCount + cardStep * (dayCount - 1),
        child: WeekDisplayWidget(cardWidth, dayCount),
      ),
    );

    final courseTab = Positioned(
      top: cardStep + dateTabHeight,
      left: 0,
      child: CourseTabDisplayWidget(tabHeight, dayCount),
    );

    final planGrid = Positioned(
      top: cardStep + dateTabHeight,
      left: cardStep + countTabWidth,
      child: CourseDisplayWidget(cardWidth, dayCount),
    );

    return SizedBox(
      height: wholeHeight,
      width: wholeWidth,
      child: Stack(
        children: [weekBar, planGrid, courseTab],
      ),
    );
  }
}

class CourseTabDisplayWidget extends StatelessWidget {
  final int dayCount;
  final double tabHeight;

  const CourseTabDisplayWidget(
    this.tabHeight,
    this.dayCount, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeRange = context.select((LoungeConfig config) => config.timeRange);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: Time.rangeList.asMap().keys.map((step) {
        var chosen = timeRange.contains(Time.rangeList[step]);

        final courseTabs = [
          CourseTab(
            tabHeight,
            chosen,
            step * 2 + 1,
          ),
          SizedBox(height: cardStep),
          CourseTab(
            tabHeight,
            chosen,
            step * 2 + 2,
          ),
        ];

        if (step != Time.rangeList.length - 1) {
          courseTabs.add(SizedBox(height: cardStep));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: courseTabs,
        );
      }).toList(),
    );
  }
}

class CourseTab extends StatelessWidget {
  final double height;
  final bool chosen;
  final int step;

  const CourseTab(this.height, this.chosen, this.step, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor =
        chosen ? theme.coordinateChosenBackground : theme.coordinateBackground;

    final textColor =
        chosen ? theme.coordinateChosenText : theme.coordinateText;

    return Container(
      height: height,
      width: countTabWidth,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: TextStyle(
          color: textColor,
          fontSize: 12.w,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class WeekDisplayWidget extends StatelessWidget {
  final double cardWidth;
  final int dayCount;

  const WeekDisplayWidget(
    this.cardWidth,
    this.dayCount, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateTime = context.select((LoungeConfig config) => config.dateTime);

    return Row(
      children: dateTime.thisWeek.sublist(0, dayCount).map((date) {
        final backgroundColor = dateTime.isTheSameDay(date)
            ? Theme.of(context).coordinateChosenBackground
            : Theme.of(context).coordinateBackground;

        final textColor = dateTime.isTheSameDay(date)
            ? Theme.of(context).coordinateChosenText
            : Theme.of(context).coordinateText;

        return Container(
          height: dateTabHeight,
          width: cardWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5.w),
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.month}/${date.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

class CourseDisplayWidget extends LoadStateListener<_RoomPlanData> {
  final double cardWidth;
  final int dayCount;

  const CourseDisplayWidget(
    this.cardWidth,
    this.dayCount, {
    Key? key,
  }) : super(key: key);

  @override
  Widget refresh(BuildContext context, _) {
    return const Center(child: Loading());
  }

  @override
  Widget success(BuildContext context, _RoomPlanData data) {
    var singleCourseHeight = cardWidth * 136 / 96;

    final statuses = data.room.statuses.map(
      (key, value) =>
          MapEntry(Time.week[key - 1], DataFactory.splitPlan(value)),
    );

    return Stack(
      children: _generatePositioned(
        context,
        singleCourseHeight,
        statuses,
        dayCount,
      ),
    );
  }

  @override
  Widget error(BuildContext context, _) {
    return const Center(child: Text('error'));
  }

  @override
  Widget build(BuildContext context) {
    var singleCourseHeight = cardWidth * 136 / 96;

    return SizedBox(
      height: singleCourseHeight * 12 + cardStep * 11,
      width: MediaQuery.of(context).size.width -
          schedulePadding * 2 -
          countTabWidth -
          cardStep,
      child: super.build(context),
    );
  }

  // ignore: unused_element
  List<Widget> _generatePositioned(
    BuildContext context,
    double courseHeight,
    Map<String, List<String>> plan,
    int dayCount,
  ) {
    List<Widget> list = [];
    final colors = Theme.of(context).roomPlanItemColors;
    var d = 1;
    for (var wd in Time.week.getRange(0, dayCount)) {
      var index = 1;
      final dayPlan = plan[wd];
      if (dayPlan == null) {
        continue;
      }
      for (var c in dayPlan) {
        int day = d;
        int start = index;
        index = index + c.length;
        int end = index - 1;
        double top = (start == 1) ? 0 : (start - 1) * (courseHeight + cardStep);
        double left = (day == 1) ? 0 : (day - 1) * (cardWidth + cardStep);
        double height =
            (end - start + 1) * courseHeight + (end - start) * cardStep;

        /// 判断周日的课是否需要显示在课表上
        if (day <= 7 && c.contains('1')) {
          Widget planItem = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.w),
              shape: BoxShape.rectangle,
              color: colors[Random().nextInt(colors.length)],
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Text(
              '课程占用',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).roomPlanItemText,
              ),
            ),
          );

          planItem = Positioned(
            top: top,
            left: left,
            height: height,
            width: cardWidth,
            child: planItem,
          );

          list.add(planItem);
        }
      }
      d++;
    }
    return list;
  }
}
