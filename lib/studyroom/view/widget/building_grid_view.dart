import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
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
    return Consumer<CampusProvider>(builder: (_, data, __) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Builder(
            key: UniqueKey(),
            builder: (context) {
              if (!data.buildingLoaded) return Loading();

              if (data.buildings.isEmpty) {
                return Center(
                  child: Text('暂无数据',
                      style: TextUtil.base.PingFangSC.label.sp(14)),
                );
              }

              return BuildingGrid(data.buildings);
            }),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.topCenter,
          child: _BuildingItem(list[index]),
        );
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
      building.name,
      style: TextUtil.base.Swis.primaryAction.w400.sp(10),
      textAlign: TextAlign.center,
    );

    final buildingImage =
        Container(height: 54.h, child: Image.asset(StudyroomImages.building));

    return WButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          StudyRoomRouter.building,
          arguments: building.id,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (building.name != '南开大学')
            buildingImage
          else
            Container(
                height: 54.h,
                child: Image.asset(StudyroomImages.collectedBuilding)),
          SizedBox(height: 8.h),
          buildingName,
        ],
      ),
    );
  }
}
