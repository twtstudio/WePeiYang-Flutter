import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_service.dart';
import 'package:we_pei_yang_flutter/studyroom/util/theme_util.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/room_card.dart';

import '../../util/data_util.dart';

class ClassroomsPage extends StatelessWidget {
  final int buildingId;

  ClassroomsPage(this.buildingId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudyroomBasePage(
      isOutside: true,
      body: _FloorsView(
        buildingId,
      ),
    );
  }
}

class _FloorsView extends StatelessWidget {
  final int buildingId;

  _FloorsView(
    this.buildingId, {
    Key? key,
  }) : super(key: key);

  final splitRooms = ValueNotifier<Map<String, List<Room>>>({});

  void initRooms() async {
    final _rooms = await StudyroomService.getRoomList(buildingId);
    splitRooms.value = StudyRoomDataUtil.prefixBasedSplit(_rooms);
  }

  @override
  Widget build(BuildContext context) {
    initRooms();
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20.h, 0, 50.h),
          child: _PathTitle(
            context.read<CampusProvider>().building(buildingId).name,
            "-1",
          ),
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
              child: ListenableBuilder(
                listenable: splitRooms,
                builder: (_, __) {
                  if (splitRooms.value.isEmpty)
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 600.h,
                      ),
                      child: Loading(),
                    );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var entry in splitRooms.value.entries)
                        FloorWidget(entry.key, entry.value),
                    ],
                  );
                },
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
          buildingName,
          style: TextUtil.base.white.sp(20).Swis.w400.space(letterSpacing: 5),
        )
      ],
    );
  }
}

class FloorWidget extends StatelessWidget {
  final String name;
  final List<Room> rooms;

  const FloorWidget(
    this.name,
    this.rooms, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomsGridView = Column(
      children: [
        for (int i = 0; i < rooms.length; i += 4)
          Row(
            children: [
              for (int j = 0; j < 4; j++)
                if (i + j < rooms.length)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.w),
                    child: _RoomItem(rooms[i + j], "-1"),
                  )
                else
                  Container(), // or any other placeholder if needed
            ],
          ),
      ],
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
                RegExp(r'\d$').hasMatch(name) ? '$name层' : name,
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
  final Room classroom;

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
