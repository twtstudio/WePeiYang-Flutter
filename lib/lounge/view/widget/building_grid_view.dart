// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/load_state_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
class BuildingGridViewWidget extends LoadStateListener<BuildingData> {
  const BuildingGridViewWidget({Key? key}) : super(key: key);

  @override
  Widget init(BuildContext context, _) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: const Center(
        child: Loading(),
      ),
    );
  }

  @override
  Widget refresh(BuildContext context, _) {
    late double height;
    final campus = context.read<LoungeConfig>().campus;
    if (campus.isWjl) {
      height = (MediaQuery.of(context).size.width - 40.w) / 4 / 1.05;
    } else {
      height = (MediaQuery.of(context).size.width - 40.w) / 4 / 1.05 * 3;
    }
    return SizedBox(
      height: height,
      child: const Center(
        child: Loading(),
      ),
    );
  }

  @override
  Widget success(BuildContext context, data) {
    if (data.buildings.isEmpty) {
      return const Text('暂无数据');
    }

    final wjlBuildings = BuildingGrid(data.wjl);
    final byyBuildings = BuildingGrid(data.byy);

    return Builder(
      builder: (context) => AnimatedCrossFade(
        firstChild: wjlBuildings,
        secondChild: byyBuildings,
        crossFadeState: context.select((LoungeConfig config) => config.state),
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 200),
      ),
    );
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

    final buildingImage = Container(
        width: 54.w,
        child: Image.asset(Images.building));

    return InkWell(
      onTap: () {
        if (building.areas.length > 1) {
          Navigator.pushNamed(
            context,
            LoungeRouter.areas,
            arguments: building.id,
          );
        } else {
          Navigator.pushNamed(
            context,
            LoungeRouter.classrooms,
            arguments: [building.id, building.areas.values.first.id],
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildingImage,
          buildingName,
        ],
      ),
    );
  }
}
