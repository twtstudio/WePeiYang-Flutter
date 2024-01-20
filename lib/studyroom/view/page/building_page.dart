import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/src/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_service.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';

import '../../../commons/widgets/w_button.dart';

class BuildingPage extends StatefulWidget {
  final int buildingId;

  BuildingPage(this.buildingId, {Key? key}) : super(key: key);

  @override
  State<BuildingPage> createState() => _BuildingPageState();
}

class _BuildingPageState extends State<BuildingPage> {
  List<Room> rooms = [];

  @override
  initState() {
    super.initState();
    initRooms();
  }

  void initRooms() async {
    print("==> start load rooms");
    final _rooms = await StudyroomService.getRoomList(widget.buildingId);
    setState(() {
      rooms = _rooms;
      print("==> room load finished");
    });
  }

  @override
  Widget build(BuildContext context) {
    final building = context.read<CampusProvider>().buildings.firstWhere(
          (element) => element.id == widget.buildingId,
          orElse: () => Building(widget.buildingId, '未知', -1),
        );
    final pageTitle = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          building.name,
          style: TextUtil.base.white.sp(20).Swis.w400.space(letterSpacing: 5),
        )
      ],
    );

    final roomGradView = GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.w,
        childAspectRatio: 5 / 4,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _RoomItem(index, rooms[index], building),
    );

    return StudyroomBasePage(
      padding: EdgeInsets.symmetric(horizontal: 23.w),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          pageTitle,
          SizedBox(height: 26.w),
          roomGradView,
        ],
      ),
    );
  }
}

class _RoomItem extends StatelessWidget {
  final int index;
  final Room room;
  final Building building;

  const _RoomItem(this.index, this.room, this.building, {Key? key})
      : super(key: key);

  void pushToClassroomsPage(BuildContext context) {
    Navigator.pushNamed(
      context,
      StudyRoomRouter.classrooms,
      arguments: [building.id],
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomName = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/studyroom_icons/point.png', width: 6.w),
        SizedBox(width: 6.w),
        Text(
          room.name,
          style: TextUtil.base.Swis.sp(16).black2A.space(letterSpacing: 5),
        ),
      ],
    );

    return WButton(
      onPressed: () => pushToClassroomsPage(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          shape: BoxShape.rectangle,
          color: Color.fromRGBO(213, 229, 249, 1),
        ),
        alignment: Alignment.center,
        child: roomName,
      ),
    );
  }
}
