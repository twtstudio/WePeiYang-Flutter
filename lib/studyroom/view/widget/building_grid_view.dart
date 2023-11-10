import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_router.dart';
import 'package:we_pei_yang_flutter/studyroom/util/studyroom_images.dart';

import '../../../commons/widgets/w_button.dart';

class BuildingGridViewWidget extends StatelessWidget {
  const BuildingGridViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyroomProvider>(builder: (_, data, __) {
      if (!data.buildingsLoaded) return Loading();
      if (data.buildings.isEmpty) {
        return Center(
          child: Text('暂无数据', style: TextUtil.base.PingFangSC.black2A.sp(14)),
        );
      }

      final wjlBuildings = BuildingGrid(data.wjl);
      final byyBuildings = BuildingGrid(data.byy);

      return Builder(
        builder: (context) => AnimatedCrossFade(
          firstChild: wjlBuildings,
          secondChild: byyBuildings,
          crossFadeState: data.state,
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 200),
        ),
      );
    });
  }
}

class BuildingGrid extends StatelessWidget {
  final List<Building> list;

  const BuildingGrid(this.list, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _BuildingItem(list[index]);
      },
    );
  }
}

class _BuildingItem extends StatelessWidget {
  final Building building;

  const _BuildingItem(this.building, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buildingName = Text(
      building.name + "教",
      style: TextUtil.base.Swis.blue2C.w400.sp(10),
    );

    final buildingImage =
        Container(height: 54.h, child: Image.asset(StudyroomImages.building));

    return WButton(
      onPressed: () {
        final len = building.areas?.length ?? 0;
        if (len == 0) {
          ToastProvider.error('此楼暂无信息');
          return;
        }
        if (len == 1)
          Navigator.pushNamed(
            context,
            StudyRoomRouter.classrooms,
            arguments: [building.id, building.areas!.first.id],
          );
        else
          Navigator.pushNamed(
            context,
            StudyRoomRouter.areas,
            arguments: building.id,
          );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildingImage,
          SizedBox(height: 8.h),
          buildingName,
        ],
      ),
    );
  }
}
