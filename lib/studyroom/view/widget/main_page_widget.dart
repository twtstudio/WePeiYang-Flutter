import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/util/studyroom_images.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/building_grid_view.dart';

class MainPageStudyRoomWidget extends StatelessWidget {
  const MainPageStudyRoomWidget({Key? key}) : super(key: key);

  // TODO: 收藏被干掉了，数据结构被重写了，这里留着参考
  // Widget _favorList(BuildContext context) {
  //   return Consumer<StudyroomProvider>(builder: (_, sp, __) {
  //     final favors = sp.favorRooms.values.toList();
  //     if (!sp.favorLoaded) return Loading();
  //
  //     if (favors.isEmpty)
  //       return Center(
  //         child: Text('暂无收藏信息', style: TextUtil.base.PingFangSC.black2A.sp(14)),
  //       );
  //     // 按照字典序排下
  //     favors.sort((a, b) => a.name.compareTo(b.name));
  //
  //     return SingleChildScrollView(
  //       physics: BouncingScrollPhysics(),
  //       scrollDirection: Axis.horizontal,
  //       child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children:
  //               favors.map((classroom) => FavourRoomCard(classroom)).toList()),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          // TODO: 收藏暂时被砍掉了
          // Padding(
          //   padding: EdgeInsets.only(left: 8.w),
          //   child: Text(
          //     '我的收藏',
          //     style: TextUtil.base.PingFangSC.black2A.bold.sp(14.2),
          //   ),
          // ),
          // SizedBox(height: 25.h),
          // _favorList(context),
          TextButton.icon(
            onPressed: () => context.read<CampusProvider>().next(),
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.only(left: 8.w))),
            icon: Text(
              context.watch<CampusProvider>().name,
              style: TextUtil.base.PingFangSC.label.bold.sp(14),
            ),
            label: SvgPicture.asset(
              StudyroomImages.direction,
              width: 10.w,
            ),
          ),
          Expanded(
            child: BuildingGridViewWidget(),
          )
        ],
      ),
    );
  }
}
