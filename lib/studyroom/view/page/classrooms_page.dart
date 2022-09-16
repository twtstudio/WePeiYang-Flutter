// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/util/theme_util.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/room_card.dart';

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

    return ListView(
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
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('assets/images/studyroom_background.png'),
                    fit: BoxFit.fill)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 36.h),
              child: Column(
                children: List.generate(
                    floors.length,
                    (index) =>
                        FloorWidget(floors.entries.toList()[index], area.id)),
              ),
            ),
          ),
        ),
      ],
    );
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
              Image.asset('assets/images/studyroom_icons/point.png',
                  width: 6.w),
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
    final roomState = RoomStateText(classroom);

    final roomItem = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          areaId == '-1' ? classroom.name : areaId + classroom.name,
          style: TextUtil.base.black2A.w400.PingFangSC.sp(14),
        ),
        SizedBox(height: 5.w),
        roomState,
      ],
    );

    var boxDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2))
      ],
      borderRadius: BorderRadius.circular(8.w),
      shape: BoxShape.rectangle,
      color: Theme.of(context).classroomItemBackground,
    );

    return WButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          StudyRoomRouter.detail,
          arguments: classroom,
        );
      },
      // style: Theme.of(context).roomButtonStyle,
      child: Center(
        child: Container(
          height: 53.w,
          width: 67.w,
          decoration: boxDecoration,
          child: roomItem,
        ),
      ),
    );
  }
}
