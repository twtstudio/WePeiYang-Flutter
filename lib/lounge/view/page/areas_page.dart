// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/base_page.dart';
import 'package:provider/provider.dart';

class AreasPage extends StatelessWidget {
  final String bId;

  const AreasPage({Key? key, required this.bId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // debugPrint('build AreasPage');
    final building = context.read<BuildingData>().buildings[bId]!;

    final pageTitle = Row(
      children: [
        const SizedBox(width: 1),
        Image.asset(
          Images.building,
          height: 17.w,
          color: Theme.of(context).areaIconColor,
        ),
        const SizedBox(width: 7),
        Text(
          building.name + '教学楼',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: Theme.of(context).areaTitle,
          ),
        ),
      ],
    );

    final areaColors = Theme.of(context).areaItemColors;

    final areasGridView = GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.w,
        childAspectRatio: 9 / 8,
      ),
      itemCount: building.areas.values.length,
      itemBuilder: (context, index) => _AreaItem(
        index,
        areaColors[index % areaColors.length],
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
  final Color color;
  final Area area;

  const _AreaItem(
    this.index,
    this.color,
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
    final areaName = Text(
      area.id + '区',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).areaText,
        fontSize: 14.sp,
      ),
    );

    return InkWell(
      onTap: () => pushToClassroomsPage(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          shape: BoxShape.rectangle,
          color: color,
        ),
        alignment: Alignment.center,
        child: areaName,
      ),
    );
  }
}
