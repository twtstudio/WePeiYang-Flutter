import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_page.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/update/update_service.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/tab_pages/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';

bool ifCanBeRefreshed = false;

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
      UpdateManager.checkUpdate();
      var hasReport = await reportDio.getTodayHasReported();
      if (hasReport) {
        CommonPreferences().reportTime.value = DateTime.now().toString();
      } else {
        CommonPreferences().reportTime.value = "";
      }
      // 检查当前是否有未处理的事件
      context.findAncestorStateOfType<WePeiYangAppState>().checkEventList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = WePeiYangApp.screenWidth / 3;

    var currentStyle = TextStyle(
        fontSize: 12, color: MyColors.deepBlue, fontWeight: FontWeight.w800);
    var otherStyle = TextStyle(
        fontSize: 12, color: MyColors.deepDust, fontWeight: FontWeight.w800);

    var homePage = SizedBox(
      height: 70,
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
          )),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ImageIcon(
                AssetImage('assets/images/lake_butt_icons/main_page.png'),
                size: 32,
                color: _currentIndex == 0 ? ColorUtil.mainColor : ColorUtil.lightTextColor,
              ),
            ),
            SizedBox(height: 2),
            Text('主页', style: _currentIndex == 0 ? currentStyle : otherStyle),
          ],
        ),
        onPressed: () => _tabController.animateTo(0),
      ),
    );

    var feedbackPage = SizedBox(
      height: 70,
      width: width,
      child: ElevatedButton(
        onPressed: () {
          if (_currentIndex == 1) {
            feedbackKey.currentState.listToTop();
          } else
            _tabController.animateTo(1);
        },
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder()),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.pressed))
                return Colors.transparent;
              return Colors.white;
            })),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FeedbackBadgeWidget(
              type: FeedbackMessageType.home,
              child: Center(
                child: ImageIcon(
                    AssetImage('assets/images/lake_butt_icons/dive_page.png'),
                  size: 32,
                  color: _currentIndex == 1 ? ColorUtil.mainColor : ColorUtil.lightTextColor,
                ),
              ),
            ),
            SizedBox(height: 2),
            Text('青年湖底', style: _currentIndex == 1 ? currentStyle : otherStyle),
          ],
        ),
      ),
    );

    var selfPage = SizedBox(
      height: 70,
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(18)),
          )),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 4),
            Center(
              child: ImageIcon(
                AssetImage('assets/images/lake_butt_icons/my_page.png'),
                size: 28,
                color: _currentIndex == 2 ? ColorUtil.mainColor : ColorUtil.lightTextColor,
              ),
            ),
            SizedBox(height: 2),
            Text('个人中心', style: _currentIndex == 2 ? currentStyle : otherStyle),
          ],
        ),
        onPressed: () => _tabController.animateTo(2),
      ),
    );

    var bottomNavigationBar = ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        child: BottomAppBar(
          child: Row(children: <Widget>[homePage, feedbackPage, selfPage]),
        ));

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
              _tabController.animateTo(0);
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
