// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_campus.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/util/studyroom_images.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/building_grid_view.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/favour_room_card.dart';

class MainPageStudyRoomWidget extends StatelessWidget {
  const MainPageStudyRoomWidget({Key? key}) : super(key: key);

  Widget _favorList(BuildContext context) {
    return Consumer<StudyroomProvider>(builder: (_, sp, __) {
      final favors = sp.favorRooms.values.toList();
      if (!sp.favorLoaded) return Loading();

      if (favors.isEmpty)
        return Center(
          child: Text('暂无收藏信息', style: TextUtil.base.PingFangSC.black2A.sp(14)),
        );
      // 按照字典序排下
      favors.sort((a, b) => a.title.compareTo(b.title));

      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                favors.map((classroom) => FavourRoomCard(classroom)).toList()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Text(
              '我的收藏',
              style: TextUtil.base.PingFangSC.black2A.bold.sp(14.2),
            ),
          ),
          SizedBox(height: 25.h),
          _favorList(context),
          TextButton.icon(
            onPressed: () => context.read<StudyroomProvider>().changeCampus(),
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.only(left: 8.w))),
            icon: Text(
              context.watch<StudyroomProvider>().campus.campusName + '校区',
              style: TextUtil.base.PingFangSC.black2A.bold.sp(14),
            ),
            label: SvgPicture.asset(
              StudyroomImages.direction,
              width: 10.w,
            ),
          ),
          BuildingGridViewWidget(),
        ],
      ),
    );
  }
}
