// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/util/theme_util.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/room_card.dart';

// // 教室列表页面的数据和ui控制
// class _ClassroomsPageData extends LoungeDataChangeNotifier {
//   final Area _area;

//   Area get area => _area;

//   set area(Area data) {
//     _area.bId = data.bId;
//     _area.building = data.building;
//     _area.classrooms = data.classrooms;
//   }

//   final BuildContext _context;

//   final RefreshController _refreshController;

//   RefreshController get refreshController => _refreshController;

//   _ClassroomsPageData._(this._area, this._refreshController, this._context);

//   factory _ClassroomsPageData(BuildContext context, String bId, String aId) {
//     final dataProvider = context.read<BuildingData>();
//     final data = dataProvider.buildings[bId]?.areas[aId] ?? Area.empty();
//     return _ClassroomsPageData._(data, RefreshController(), context);
//   }

//   @override
//   void getNewData(BuildingData dataProvider) {
//     final newData = dataProvider.buildings[area.bId]?.areas[area.id];
//     if (newData != null) {
//       area = newData;
//       if (_refreshController.isRefresh) {
//         _refreshController.refreshCompleted();
//       }
//       stateSuccess('刷新楼层数据成功');
//     } else {
//       // 新的数据中没有这个区域的数据
//       ToastProvider.error('新数据出现错误');
//       stateError();
//     }
//   }

//   @override
//   void getDataError() {
//     // 获取数据出错
//     ToastProvider.error('刷新出现错误');
//     stateError();
//   }

//   @override
//   bool stateError([String? msg]) {
//     if (_refreshController.isRefresh) {
//       _refreshController.refreshFailed();
//     }
//     return super.stateError(msg);
//   }

//   void onRefresh() {
//     _context.read<BuildingData>().getDataOfWeek();
//   }
// }

class ClassroomsPage extends StatelessWidget {
  final String buildingId;
  final String areaId;

  ClassroomsPage(this.buildingId, this.areaId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<StudyroomProvider, List<Building>>(
      selector: (_, sp) => sp.buildings,
      builder: (_, buildings, __) {
        try {
          final building = buildings.firstWhere((b) => b.id == buildingId);
          final area = building.areas!.firstWhere((a) => a.id == areaId);
          area.splitFloors();
          return StudyroomBasePage(
            isOutside: true,
            body: _FloorsView(building.name, area),
          );
        } on StateError catch (e, s) {
          Logger.reportError(e, s);
          return Text('暂无数据');
        }
      },
    );
  }
}

class _FloorsView extends StatelessWidget {
  final String buildingName;
  final Area area;

  const _FloorsView(
    this.buildingName,
    this.area, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floors = area.floors;

    Widget floorListView = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: floors.length,
      itemBuilder: (context, index) {
        if (index < floors.length) {
          return FloorWidget(floors.entries.toList()[index], area.id);
        }
        return SizedBox.shrink();
      },
    );

    floorListView = ListView(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20.h, 0, 50.h),
          child: _PathTitle(buildingName, area.id),
        ),
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 36.h),
              child: floorListView,
            ),
          ),
        ),
      ],
    );

    return floorListView;
  }
}

class _PathTitle extends StatelessWidget {
  final String buildingName;
  final String areaName;

  _PathTitle(this.buildingName, this.areaName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          areaName != '-1'
              ? buildingName + '教学楼' + areaName + '区'
              : buildingName + '教学楼',
          style: TextUtil.base.white.sp(20).Swis.w400.space(letterSpacing: 5),
        )
      ],
    );
  }
}

class FloorWidget extends StatelessWidget {
  final MapEntry<String, List<Classroom>> entry;
  final String areaId;

  const FloorWidget(
    this.entry,
    this.areaId, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floor = entry.key;
    final classrooms = entry.value;

    final roomsGridView = Column(
      children: List.generate(
        classrooms.length ~/ 4 + 1,
        (index) {
          final row = List.generate(
            4,
            (index2) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.w),
              child: index * 4 + index2 < classrooms.length
                  ? _RoomItem(classrooms[index * 4 + index2], areaId)
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
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Image.asset('assets/images/lounge_icons/point.png', width: 6.w),
              SizedBox(width: 6.w),
              Text(
                floor + "F",
                style: TextUtil.base.PingFangSC.w400.black2A.sp(16),
              ),
            ],
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
    this.classroom,
    this.areaId, {
    Key? key,
  }) : super(key: key);

  final String areaId;
  final Classroom classroom;

  @override
  Widget build(BuildContext context) {
    final roomCard = RoomStateText(classroom);

    final roomItem = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          areaId == '-1' ? classroom.name : areaId + classroom.name,
          style: TextUtil.base.black2A.w400.PingFangSC.sp(14),
        ),
        SizedBox(height: 5.w),
        roomCard,
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
          StudyRoomRouter.detail,
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
