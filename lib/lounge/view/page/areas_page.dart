// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/base_page.dart';
import 'package:provider/provider.dart';

class AreasPage extends StatelessWidget {
  final String bId;

  const AreasPage({Key? key, required this.bId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final building = context.read<BuildingData>().buildings[bId]!;

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
      itemCount: building.areas.values.length,
      itemBuilder: (context, index) => _AreaItem(
        index,
        building.areas.values.toList()[index],
      ),
    );

    return LoungeBasePage(
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

  const _AreaItem(
    this.index,
    this.area, {
    Key? key,
  }) : super(key: key);

  void pushToClassroomsPage(BuildContext context) {
    Navigator.pushNamed(
      context,
      LoungeRouter.classrooms,
      arguments: [area.bId, area.id],
    );
  }

  @override
  Widget build(BuildContext context) {
    final areaName = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/lounge_icons/point.png', width: 6.w),
        SizedBox(width: 6.w),
        Text(
          area.id + '区',
          style: TextUtil.base.Swis.bold.sp(16).black2A.space(letterSpacing: 5),
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
