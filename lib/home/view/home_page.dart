import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/network/error_interceptor.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/main_page_widget.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_page.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// bottomNavigationBar对应的分页
  List<Widget> pages = [];
  int _currentIndex = 0;
  DateTime _lastPressedAt;
  TabController _tabController;
  final feedbackKey = GlobalKey<FeedbackHomePageState>();

  @override
  void initState() {
    super.initState();
    pages
      ..add(WPYPage())
      ..add(FeedbackHomePage(key: feedbackKey))
      ..add(UserPage());
    _tabController = TabController(
      length: pages.length,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
        if (_tabController.index != _tabController.previousIndex) {
          setState(() {
            _currentIndex = _tabController.index;
          });
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // WbyFontLoader.initFonts();
      context.read<PushManager>().initGeTuiSdk();
      context.read<UpdateManager>().checkUpdate();
      var hasReport = await reportDio.getTodayHasReported();
      if (hasReport) {
        CommonPreferences().reportTime.value = DateTime.now().toString();
      } else {
        CommonPreferences().reportTime.value = "";
      }
      // 检查当前是否有未处理的事件
      context.findAncestorStateOfType<WePeiYangAppState>().checkEventList();
      // 友盟统计账号信息
      UmengCommonSdk.onProfileSignIn(CommonPreferences().account.value);
      // 刷新自习室数据
      initLoungeFavourDataAtMainPage(context);
    });
    if(DateTime.now().month==4&&DateTime.now().day==1&&CommonPreferences().isAprilFoolGen.value){
      CommonPreferences().isAprilFool.value = true;
      CommonPreferences().isAprilFoolLike.value = true;
      CommonPreferences().isAprilFoolGPA.value = true;
      CommonPreferences().isAprilFoolClass.value = true;
      ///如果不刷新GPA，就不会显示满绩
      Provider.of<GPANotifier>(context, listen: false)
          .refreshGPA(
          hint: true,
          onFailure: (e) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) => TjuRebindDialog(
                  reason: e is WpyDioError
                      ? e.error.toString()
                      : null),
            );
          })
          .call();
      CommonPreferences().isAprilFoolGen.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = WePeiYangApp.screenWidth / 3;

    var homePage = SizedBox(
      height: 70.w,
      width: width,
      child: IconButton(
        splashRadius: 1,
        icon: Image.asset(
          'assets/images/home_logo.png',
          color: _currentIndex == 0
              ? Color.fromRGBO(38, 56, 95, 1.0)
              : ColorUtil.searchBarIconColor,
        ),
        color: Colors.white,
        onPressed: () => _tabController.animateTo(0),
      ),
    );

    var feedbackPage = SizedBox(
      height: 70.w,
      width: width,
      child: IconButton(
        splashRadius: 1,
        icon: Image.asset(
          'assets/images/lake_logo.png',
          color: _currentIndex == 1
              ? Color.fromRGBO(38, 56, 95, 1.0)
              : ColorUtil.searchBarIconColor,
        ),
        color: Colors.white,
        onPressed: () {
          if (_currentIndex == 1) {
            feedbackKey.currentState.listToTop();
          } else
            _tabController.animateTo(1);
        },
      ),
    );

    var selfPage = SizedBox(
      height: 70.w,
      width: width,
      child: IconButton(
        splashRadius: 1,
        icon: Image.asset(
          'assets/images/myself_logo.png',
          color: _currentIndex == 2
              ? Color.fromRGBO(38, 56, 95, 1.0)
              : ColorUtil.searchBarIconColor,
        ),
        color: Colors.white,
        onPressed: () => _tabController.animateTo(2),
      ),
    );

    var bottomNavigationBar = Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.95),
          boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 0, blurRadius: 3)],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        ),
        child: Row(children: <Widget>[homePage, feedbackPage, selfPage]));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _tabController.index == 2
          ? SystemUiOverlayStyle.light
              .copyWith(systemNavigationBarColor: Colors.white)
          : SystemUiOverlayStyle.dark
              .copyWith(systemNavigationBarColor: Colors.white),
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: bottomNavigationBar,
        body: WillPopScope(
          onWillPop: () async {
            if (_tabController.index == 0) {
              if (_lastPressedAt == null ||
                  DateTime.now().difference(_lastPressedAt) >
                      Duration(seconds: 1)) {
                //两次点击间隔超过1秒则重新计时
                _lastPressedAt = DateTime.now();
                ToastProvider.running('再按一次退出程序');
                return false;
              }
            } else {
              await _tabController.animateTo(0);
              return false;
            }
            return true;
          },
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: pages,
          ),
        ),
      ),
    );
  }
}
