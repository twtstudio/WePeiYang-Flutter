// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/room_favor_provider.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/base_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/building_grid_view.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/campus_text_button.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/favor_list.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/search_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await getBuildingGridViewData();
      await getFavorList();
    });
  }

  @override
  void dispose(){
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: const Size(390, 844),
      orientation: Orientation.portrait,
    );
    super.dispose();
  }

  Future<void> getBuildingGridViewData() async {
    await context.read<BuildingData>().initData();
  }

  Future<void> getFavorList() async {
    await context
        .read<RoomFavorProvider>()
        .refreshData(dateTime: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: const Size(360, 690),
      orientation: Orientation.portrait,
    );

    return LoungeBasePage(
      padding: EdgeInsets.only(left: 20.w, top: 24.w),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: const CampusTextButton(),
          ),
          // changeTheme,
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: const SearchBar(),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.w, top: 6.w),
            child: const BuildingGridViewWidget(),
          ),
          const LoungeFavorList('我的收藏'),
        ],
      ),
    );
  }
}
