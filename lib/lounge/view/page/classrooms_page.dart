// @dart = 2.12
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/base_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/room_state.dart';

// 教室列表页面的数据和ui控制
class _ClassroomsPageData extends LoungeDataChangeNotifier {
  final Area _area;

  Area get area => _area;

  set area(Area data) {
    _area.bId = data.bId;
    _area.building = data.building;
    _area.classrooms = data.classrooms;
  }

  final BuildContext _context;

  final RefreshController _refreshController;

  RefreshController get refreshController => _refreshController;

  _ClassroomsPageData._(this._area, this._refreshController, this._context);

  factory _ClassroomsPageData(BuildContext context, String bId, String aId) {
    final dataProvider = context.read<BuildingData>();
    final data = dataProvider.buildings[bId]?.areas[aId] ?? Area.empty();
    return _ClassroomsPageData._(data, RefreshController(), context);
  }

  @override
  void getNewData(BuildingData dataProvider) {
    final newData = dataProvider.buildings[area.bId]?.areas[area.id];
    if (newData != null) {
      area = newData;
      if (_refreshController.isRefresh) {
        _refreshController.refreshCompleted();
      }
      stateSuccess('刷新楼层数据成功');
    } else {
      // 新的数据中没有这个区域的数据
      ToastProvider.error('新数据出现错误');
      stateError();
    }
  }

  @override
  void getDataError() {
    // 获取数据出错
    ToastProvider.error('刷新出现错误');
    stateError();
  }

  @override
  bool stateError([String? msg]) {
    if (_refreshController.isRefresh) {
      _refreshController.refreshFailed();
    }
    return super.stateError(msg);
  }

  void onRefresh() {
    _context.read<BuildingData>().getDataOfWeek();
  }
}

class ClassroomsPage extends StatelessWidget {
  final String bId;
  final String aId;

  const ClassroomsPage({
    required this.bId,
    required this.aId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = ChangeNotifierProxyProvider<BuildingData, _ClassroomsPageData>(
      create: (context) => _ClassroomsPageData(context, bId, aId),
      update: (context, allData, data) {
        if (data == null) {
          return _ClassroomsPageData(context, bId, aId);
        }
        return data..update(allData);
      },
      child: const BuildingFloors(),
    );

    return LoungeBasePage(
      // padding: EdgeInsets.symmetric(horizontal: 23.w),
      body: body,
    );
  }
}

class BuildingFloors extends StatelessWidget {
  const BuildingFloors({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floors =
        context.select((_ClassroomsPageData data) => data.area).splitByFloor;

    Widget floorListView = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: floors.length,
      itemBuilder: (context, index) {
        if (index < floors.length) {
          return FloorWidget(
            floor: floors.keys.toList()[index],
          );
        }
        return SizedBox.shrink();
      },
    );

    floorListView = ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: 27.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: const _PathTitle(),
        ),
        SizedBox(height: 16.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          child: floorListView,
        ),
        SizedBox(height: 30.w),
      ],
    );

    floorListView = SmartRefresher(
      controller: context.read<_ClassroomsPageData>().refreshController,
      onRefresh: context.read<_ClassroomsPageData>().onRefresh,
      header: ClassicHeader(),
      child: floorListView,
    );

    return floorListView;
  }
}

class _PathTitle extends StatelessWidget {
  const _PathTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final area = context.select((_ClassroomsPageData data) => data.area);

    return Row(
      children: [
        Image.asset(
          Images.building,
          height: 17.w,
          color: Theme.of(context).classroomIcon,
        ),
        SizedBox(width: 7.w),
        Text(
          area.id != '-1'
              ? area.building + '教学楼' + area.id + '区'
              : area.building + '教学楼',
          style: TextStyle(
            color: Theme.of(context).classroomTitle,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        )
      ],
    );
  }
}

class FloorWidget extends StatelessWidget {
  final String floor;

  const FloorWidget({
    required this.floor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classrooms = context
        .select((_ClassroomsPageData data) => data.area)
        .splitByFloor[floor]!;

    final roomsGridView = Column(
      children: List.generate(
        classrooms.length ~/ 4 + 1,
        (index) {
          final row = List.generate(
            4,
            (index2) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.w),
              child: index * 4 + index2 < classrooms.length
                  ? _RoomItem(classrooms[index * 4 + index2])
                  : null,
            ),
          );
          return Row(
            children: row,
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            floor + "F",
            style: TextStyle(
              color: Theme.of(context).classroomFloor,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
        SizedBox(height: 10.w),
        roomsGridView,
        SizedBox(height: 16.w),
      ],
    );
  }
}

class _RoomItem extends StatelessWidget {
  const _RoomItem(
    this.classroom, {
    Key? key,
  }) : super(key: key);

  final Classroom classroom;

  @override
  Widget build(BuildContext context) {
    final roomState = RoomState(classroom);

    final roomItem = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          classroom.aId == '-1'
              ? classroom.name
              : classroom.aId + classroom.name,
          style: TextStyle(
            color: Theme.of(context).classroomItemName,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 5.w),
        roomState,
      ],
    );

    var boxDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).classroomItemShadow,
          blurRadius: 47.w,
        )
      ],
      borderRadius: BorderRadius.circular(8.w),
      shape: BoxShape.rectangle,
      color: Theme.of(context).classroomItemBackground,
    );

    var inkWell = InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          LoungeRouter.plan,
          arguments: classroom,
        );
      },
      // style: Theme.of(context).roomButtonStyle,
      child: roomItem,
    );

    return Center(
      child: Container(
        height: 53.w,
        width: 67.w,
        decoration: boxDecoration,
        child: inkWell,
      ),
    );
  }
}
