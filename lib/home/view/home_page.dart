import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemNavigator, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/profile_page.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/xiaotian/view/page/xiaotian_page.dart';

import '../../auth/view/user/account_upgrade_dialog.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/colored_icon.dart';

class HomePage extends StatefulWidget {
  final int? page;

  HomePage(this.page);

  @override
  _HomePageState createState() => _HomePageState();
}

enum _HomeTabId { home, feedback, ai, profile }

class _HomeTabItem {
  const _HomeTabItem({
    required this.id,
    required this.page,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.iconWidth,
  });

  final _HomeTabId id;
  final Widget page;
  final String activeIcon;
  final String inactiveIcon;
  final double iconWidth;
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// bottomNavigationBar对应的分页
  late List<_HomeTabItem> _tabs;
  int _currentIndex = 0;
  DateTime? _lastPressedAt;
  late TabController _tabController;
  final feedbackKey = GlobalKey<FeedbackHomePageState>();

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
    _currentIndex = _indexForLegacyPage(widget.page);
    _tabController = _createTabController(_currentIndex);
    CommonPreferences.showXiaotianTabNotifier
        .addListener(_handleXiaotianTabVisibilityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PushManager>().initGeTuiSdk();

      final manager = context.read<PushManager>();
      final cid = (await manager.getCid()) ?? '';
      final now = DateTime.now();
      DateTime lastTime;
      try {
        lastTime = DateTime.tryParse(CommonPreferences.pushTime.value)!;
      } catch (_) {
        lastTime = now.subtract(Duration(days: 3));
      }
      if (cid != CommonPreferences.pushCid.value ||
          CommonPreferences.userNumber.value !=
              CommonPreferences.pushUser.value ||
          now.difference(lastTime).inDays >= 3) {
        AuthService.updateCid(cid, onResult: (_) {
          debugPrint('cid $cid 更新成功');
          CommonPreferences.pushCid.value = cid;
          CommonPreferences.pushUser.value = CommonPreferences.userNumber.value;
          CommonPreferences.pushTime.value =
              DateFormat('yyyy-MM-dd').format(now);
        }, onFailure: (_) {
          debugPrint('cid $cid 更新失败');
        });
      }

      // 检查当前是否有未处理的事件
      checkEventList(context);
      // 友盟统计账号信息
      UmengCommonSdk.onProfileSignIn(CommonPreferences.account.value);
      // 刷新自习室数据
      context.read<CampusProvider>().init();
    });
    if (widget.page != null) _tabController.animateTo(_currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CommonPreferences.accountUpgrade.value.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AccountUpgradeDialog(),
        );
      }
    });
  }

  List<_HomeTabItem> _buildTabs() {
    return [
      _HomeTabItem(
        id: _HomeTabId.home,
        page: WPYPage(),
        activeIcon: 'assets/images/home.png',
        inactiveIcon: 'assets/images/home_grey.png',
        iconWidth: 24,
      ),
      _HomeTabItem(
        id: _HomeTabId.feedback,
        page: FeedbackHomePage(key: feedbackKey),
        activeIcon: 'assets/images/lake.png',
        inactiveIcon: 'assets/images/lake_grey.png',
        iconWidth: 29,
      ),
      if (CommonPreferences.showXiaotianTab.value)
        _HomeTabItem(
          id: _HomeTabId.ai,
          page: AiPage(),
          activeIcon: 'assets/images/ai.png',
          inactiveIcon: 'assets/images/ai_grey.png',
          iconWidth: 24,
        ),
      _HomeTabItem(
        id: _HomeTabId.profile,
        page: ProfilePage(),
        activeIcon: 'assets/images/my.png',
        inactiveIcon: 'assets/images/my_grey.png',
        iconWidth: 24,
      ),
    ];
  }

  TabController _createTabController(int initialIndex) {
    late final TabController controller;
    controller = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _tabs.length - 1),
    )..addListener(() {
        if (controller.index != controller.previousIndex && mounted) {
          setState(() {
            _currentIndex = controller.index;
          });
        }
      });
    return controller;
  }

  int _indexForLegacyPage(int? page) {
    final id = switch (page) {
      1 => _HomeTabId.feedback,
      2 => _HomeTabId.ai,
      3 => _HomeTabId.profile,
      _ => _HomeTabId.home,
    };
    return _indexForTabId(id);
  }

  int _indexForTabId(_HomeTabId id) {
    final index = _tabs.indexWhere((tab) => tab.id == id);
    return index == -1 ? 0 : index;
  }

  void _handleXiaotianTabVisibilityChanged() {
    final currentTab = _tabs[_currentIndex.clamp(0, _tabs.length - 1)].id;
    final oldController = _tabController;

    setState(() {
      _tabs = _buildTabs();
      _currentIndex = _indexForTabId(currentTab);
      _tabController = _createTabController(_currentIndex);
    });

    oldController.dispose();
  }

  @override
  void dispose() {
    CommonPreferences.showXiaotianTabNotifier
        .removeListener(_handleXiaotianTabVisibilityChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTabId = _tabs[_currentIndex.clamp(0, _tabs.length - 1)].id;
    var bottomNavigationBar = Container(
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        boxShadow: [
          BoxShadow(
              color: WpyTheme.of(context).get(WpyColorKey.dislikeSecondary),
              spreadRadius: -1,
              blurRadius: 2)
        ],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _buildBottomNavigationItem(_tabs[i], i),
            ],
          ),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (() {
        if (currentTabId == _HomeTabId.feedback) {
          if (WpyTheme.of(context).brightness == Brightness.light)
            return SystemUiOverlayStyle.dark.copyWith(
                systemNavigationBarColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor));
          else
            return SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarColor: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor));
        } else if (currentTabId == _HomeTabId.profile) {
          return SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor));
        } else {
          return SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor));
        }
      })(),
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: bottomNavigationBar,
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            // 如果是通过系统返回键触发的 pop，且已经 pop，则直接返回
            if (didPop) return;

            // 重置最后一次显示对话框的时间
            CommonPreferences.lastActivityDialogShownDate.value = "";

            // _tabController 是控制 主页/论坛/个人页面 的 TabBarView 的 TabController
            // 如果是主页，则判断是否需要退出程序
            if (_tabController.index == 0) {
              // 检查是否为首次点击或点击间隔超过1秒
              if (_lastPressedAt == null ||
                  DateTime.now().difference(_lastPressedAt!) >
                      Duration(seconds: 1)) {
                // 更新最后一次点击时间
                _lastPressedAt = DateTime.now();
                ToastProvider.running('再按一次退出程序'); // 提示用户再按一次以退出程序
              } else {
                SystemNavigator.pop(); // 退出程序
              }
            } else {
              // 如果已经在第一个 Tab，重新动画到第一个 Tab
              _tabController.animateTo(0);
            }
          },
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(), // 禁止用户手动滑动 Tab
            children: _tabs.map((tab) => tab.page).toList(growable: false),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationItem(_HomeTabItem tab, int index) {
    final selected = _currentIndex == index;

    return SizedBox(
      height: 70.h,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: IconButton(
          key: ValueKey('${tab.id}-$selected'),
          splashRadius: 1,
          icon: ColoredIcon(
            selected ? tab.activeIcon : tab.inactiveIcon,
            width: tab.iconWidth.h,
            color: selected ? WpyTheme.of(context).primary : null,
          ),
          color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          onPressed: () {
            if (tab.id == _HomeTabId.feedback && selected) {
              feedbackKey.currentState?.listToTop();
              LakeUtil.getClipboardWeKoContents(context);
              return;
            }

            _tabController.animateTo(index);
          },
        ),
      ),
    );
  }
}
