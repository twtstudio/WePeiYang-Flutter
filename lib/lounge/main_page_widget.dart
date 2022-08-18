// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/building_grid_view.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/campus_text_button.dart';

import 'lounge_router.dart';
import 'provider/building_data_provider.dart';
import 'provider/room_favor_provider.dart';
import 'view/widget/favor_list.dart';

/// 初始化自习室小组件数据
void initLoungeFavourDataAtMainPage(BuildContext context) {
  context.read<RoomFavour>().refreshData().then((_) {
    if (context.read<RoomFavour>().favourList.isNotEmpty) {
      context.read<BuildingData>().getDataOfWeek();
    }
  });
}

class MainPageLoungeWidget extends StatelessWidget {
  const MainPageLoungeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18, bottom: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(LoungeRouter.main);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoungeFavorList('我的收藏'),
            CampusTextButton(),
            BuildingGridViewWidget(),
          ],
        ),
      ),
    );
  }
}
