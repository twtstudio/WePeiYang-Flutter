import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/scroll_synchronizer.dart';
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
                      style: TextUtil.base.PingFangSC.label(context).sp(14)),
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

  BuildingGrid(this.list, {Key? key}) : super(key: key);

  final ScrollController _sc2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SynchronizedScrollArea(
      inner: _sc2,
      builder: (context, physics) => GridView.builder(
        controller: _sc2,
        // 每格最宽 80 设计稿单位：手机上正好一行 5 个，宽屏自动增加列数
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80.w,
          childAspectRatio: 0.7,
        ),
        physics: physics,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Align(
            alignment: Alignment.topCenter,
            child: _BuildingItem(list[index]),
          );
        },
      ),
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
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextUtil.base.Swis.primaryAction(context).w400.sp(10),
      textAlign: TextAlign.center,
    );

    final buildingImage = Container(
      height: 54.h,
      child: ColoredIcon(
        StudyroomImages.building,
        color: WpyTheme.of(context).primary,
      ),
    );

    return WButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          StudyRoomRouter.building,
          arguments: building.id,
        );
      },
      // 图标可以在格子里收缩，保证文字总能放下
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: building.name != '南开大学'
                ? buildingImage
                : Container(
                    height: 54.h,
                    child: ColoredIcon(
                      key: ValueKey(building.name),
                      StudyroomImages.collectedBuilding,
                      color: Color.fromRGBO(126, 12, 110, 1),
                    ),
                  ),
          ),
          SizedBox(height: 8.h),
          buildingName,
        ],
      ),
    );
  }
}
