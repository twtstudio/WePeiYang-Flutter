import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/util/studyroom_images.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/room_card.dart';

import '../../../commons/widgets/w_button.dart';

/// 收藏列表的每一个item
class FavourRoomCard extends StatelessWidget {
  final Room room;

  const FavourRoomCard(
    this.room, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomState = RoomStateText(room, onlyCurrent: true);

    return WButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          StudyRoomRouter.detail,
          arguments: room,
        );
      },
      child: Container(
        height: 120.h,
        width: 70.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              StudyroomImages.collectedBuilding,
              height: 54.h,
            ),
            SizedBox(height: 8.h),
            Text(
              room.name,
              style: TextUtil.base.Swis.w400.FavorRoomColor.sp(10),
            ),
            SizedBox(height: 8.h),
            roomState,
          ],
        ),
      ),
    );
  }
}
