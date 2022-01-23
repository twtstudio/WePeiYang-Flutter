import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_page.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';
import 'package:provider/provider.dart';

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
      // WbyFontLoader.initFonts();
      PushManager.getInstance().initGeTuiSdk();
      context.read<UpdateManager>().checkUpdate();
      var hasReport = await reportDio.getTodayHasReported();
      if (hasReport) {
        CommonPreferences().reportTime.value = DateTime.now().toString();
      } else {
        CommonPreferences().reportTime.value = "";
      }

      UmengCommonSdk.initCommon(
        "60464782b8c8d45c1390e7e3",
        "605440876ee47d382b8b74c3",
        "Umeng",
      ).then(
        (_) {
          debugPrint('init umeng success');
          UmengCommonSdk.setPageCollectionModeManual();
        },
      );

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
          shape: MaterialStateProperty.all(RoundedRectangleBorder()),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
                width: 20,
                height: 20,
                image: _currentIndex == 0
                    ? AssetImage('assets/images/icon_home_active.png')
                    : AssetImage('assets/images/icon_home.png')),
            SizedBox(height: 3),
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
              child: SizedBox(
                width: 20,
                height: 20,
                child: _currentIndex == 1
                    ? Stack(children: [
                        Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: Image(
                                image: AssetImage(
                                    'assets/images/icon_feedback_active.png')),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 14,
                            color: MyColors.myGrey,
                          ),
                        ),
                      ])
                    : Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Image(
                            image:
                                AssetImage('assets/images/icon_feedback.png'),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('校务',
                  style: _currentIndex == 1 ? currentStyle : otherStyle),
            ),
          ],
        ),
      ),
    );

    var selfPage = SizedBox(
      height: 70,
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder()),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
                width: 20,
                height: 20,
                image: _currentIndex == 2
                    ? AssetImage('assets/images/icon_user_active.png')
                    : AssetImage('assets/images/icon_user.png')),
            SizedBox(height: 3),
            Text('个人中心', style: _currentIndex == 2 ? currentStyle : otherStyle),
          ],
        ),
        onPressed: () => _tabController.animateTo(2),
      ),
    );

    var bottomNavigationBar = BottomAppBar(
      child: Row(children: <Widget>[homePage, feedbackPage, selfPage]),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _tabController.index == 2
          ? SystemUiOverlayStyle.light
              .copyWith(systemNavigationBarColor: Colors.white)
          : SystemUiOverlayStyle.dark
              .copyWith(systemNavigationBarColor: Colors.white),
      child: Scaffold(
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
