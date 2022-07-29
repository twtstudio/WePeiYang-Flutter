// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/room_favor_provider.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/base_page.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/building_grid_view.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/campus_text_button.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/favor_list.dart';
import 'package:we_pei_yang_flutter/lounge/view/widget/search_bar.dart';

class MainPageState extends ChangeNotifier {
  final RefreshController _refreshController;

  RefreshController get refreshController => _refreshController;

  BuildContext _context;

  MainPageState._(this._refreshController, this._context);

  factory MainPageState(BuildContext context) {
    return MainPageState._(RefreshController(), context);
  }

  Future<void> onRefresh() async {
    await Future.wait([
      _context.read<BuildingData>().getDataOfWeek(),
      _context.read<RoomFavour>().refreshData()
    ]).then(
      (_) => _refreshController.refreshToIdle(),
      onError: (_) => _refreshController.refreshFailed(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<RoomFavour>().init();
      context.read<BuildingData>().init();
    });
  }

  @override
  void dispose() {
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

    final listView = ListView(
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
          padding: EdgeInsets.only(right: 20.w),
          child: const BuildingGridViewWidget(),
        ),
        const LoungeFavorList('我的收藏'),
      ],
    );

    Widget body = Builder(
      builder: (context) => SmartRefresher(
        controller: context.read<MainPageState>().refreshController,
        onRefresh: context.read<MainPageState>().onRefresh,
        enablePullDown: true,
        header: ClassicHeader(),
        child: listView,
      ),
    );

    body = ChangeNotifierProvider<MainPageState>(
      create: (context) => MainPageState(context),
      child: body,
    );

    return LoungeBasePage(
      padding: EdgeInsets.only(left: 20.w, top: 24.w),
      body: body,
    );
  }
}
