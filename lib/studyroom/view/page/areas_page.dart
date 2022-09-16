// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/src/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/base_page.dart';

class AreasPage extends StatelessWidget {
  late final Building building;
  final String buildingId;

  AreasPage(this.buildingId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buildings = context.read<StudyroomProvider>().buildings;

    final idx = buildings.indexWhere((element) => element.id == buildingId);
    if (idx == -1) return Text('无数据');
    building = buildings[idx];

    final pageTitle = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          building.name + '教学楼',
          style: TextUtil.base.white.sp(20).Swis.w400.space(letterSpacing: 5),
        )
      ],
    );

    final areasGridView = GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.w,
        childAspectRatio: 5 / 4,
      ),
      itemCount: building.areas?.length ?? 0,
      itemBuilder: (context, index) =>
          _AreaItem(index, building.areas!.toList()[index], building),
    );

    return StudyroomBasePage(
      padding: EdgeInsets.symmetric(horizontal: 23.w),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          pageTitle,
          SizedBox(height: 26.w),
          areasGridView,
        ],
      ),
    );
  }
}

class _AreaItem extends StatelessWidget {
  final int index;
  final Area area;
  final Building building;

  const _AreaItem(this.index, this.area, this.building, {Key? key})
      : super(key: key);

  void pushToClassroomsPage(BuildContext context) {
    Navigator.pushNamed(
      context,
      StudyRoomRouter.classrooms,
      arguments: [building.id, area.id],
    );
  }

  @override
  Widget build(BuildContext context) {
    final areaName = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/studyroom_icons/point.png', width: 6.w),
        SizedBox(width: 6.w),
        Text(
          area.id + '区',
          style: TextUtil.base.Swis.sp(16).black2A.space(letterSpacing: 5),
        ),
      ],
    );

    return InkWell(
      onTap: () => pushToClassroomsPage(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          shape: BoxShape.rectangle,
          color: Color.fromRGBO(213, 229, 249, 1),
        ),
        alignment: Alignment.center,
        child: areaName,
      ),
    );
  }
}
