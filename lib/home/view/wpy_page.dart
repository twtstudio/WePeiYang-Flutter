import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/model/banner_pic.dart';
import 'package:we_pei_yang_flutter/auth/model/nacid_info.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/network/splash_service.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/scroll_synchronizer.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_curve_detail.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_course_widget.dart';
import 'package:we_pei_yang_flutter/schedule/view/wpy_exam_widget.dart';
import 'package:we_pei_yang_flutter/studyroom/view/widget/main_page_widget.dart';

import 'dialogs/acid_check_dialog.dart';
import 'dialogs/activity_dialog.dart';
import 'map_calendar_page.dart';

class WPYPage extends StatefulWidget {
  @override
  WPYPageState createState() => WPYPageState();
}

class WPYPageState extends State<WPYPage> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> showSchedule = ValueNotifier(true);
  ValueNotifier<bool> useRound = ValueNotifier(true);

  final ScrollController _sc = ScrollController();
  late final TabController _tc;

  String md = '';

  ValueNotifier<DateTime> _now = ValueNotifier(DateTime.now());
  Future<NAcidInfo> acidInfo = AuthService.checkNuclearAcid();
  bool hasShow = false;

  void _handleScroll() {
    if (_sc.position.maxScrollExtent - _sc.offset < 20.h &&
        showSchedule.value == true) showSchedule.value = false;
    if (_sc.position.maxScrollExtent - _sc.offset > 20.1.h &&
        showSchedule.value == false) showSchedule.value = true;
  }

  Future<void> showActivityDialog(List<BannerPic> banners) async {
    if (!mounted || banners.isEmpty) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivityDialog(banners: banners),
    );
  }

  void showAcidCheckDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AcidCheckDialog(acidInfo, _now);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _sc.addListener(_handleScroll);
    //隐私政策部分挪到了app一打开就会显示的部分（login_page.dart里面
    // if (CommonPreferences.firstPrivacy.value == true) {
    //   rootBundle.loadString('privacy/privacy_content.md').then((str) {
    //     setState(() {
    //       md = str;
    //     });
    //   });
    // }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // if (CommonPreferences.firstPrivacy.value == true) {
      //   showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (BuildContext context) {
      //         return PrivacyDialog(md);
      //       });
      //   CommonPreferences.firstPrivacy.value = false;
      // }
      var info = await acidInfo;
      if (!mounted) return;
      if (info.id != -1 &&
          hasShow == false &&
          info.endTime != null &&
          DateTime.now().isBefore(info.endTime!.add(Duration(hours: 1)))) {
        showAcidCheckDialog();
        hasShow = true;
      }

      var _show = () {
        unawaited(_loadAndShowActivityDialog());
      };

      try {
        final lastDate =
            DateTime.parse(CommonPreferences.lastActivityDialogShownDate.value);
        if (!lastDate.isSameDay(DateTime.now())) _show();
      } catch (_) {
        _show();
      }
    });
  }

  Future<void> _loadAndShowActivityDialog() async {
    try {
      final banners =
          await SplashService.getBanner().timeout(const Duration(seconds: 3));
      if (!mounted || banners.isEmpty) return;
      await showActivityDialog(banners);
      if (!mounted) return;
      CommonPreferences.lastActivityDialogShownDate.value =
          DateTime.now().toString();
    } catch (_) {
      // 开屏活动拉取失败时保持首页正常展示，不弹加载态或错误态。
    }
  }

  @override
  void dispose() {
    _sc
      ..removeListener(_handleScroll)
      ..dispose();
    _tc.dispose();
    showSchedule.dispose();
    useRound.dispose();
    _now.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreeting(),
              // 按首页自身的宽度选择布局（不含侧边导航栏）
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return _buildScrollBody(
                    wrapTools: width >= _largeMinWidth.w,
                    sideBySide: width >= _panelsMinWidth.w,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 顶部渐变背景：滚到底部时切换为普通背景色
  Widget _buildBackground() {
    return ListenableBuilder(
      listenable: showSchedule,
      builder: (context, _) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          gradient: WpyTheme.of(context).getGradient(
              showSchedule.value && !Platform.isWindows
                  ? WpyColorSetKey.primaryGradient
                  : WpyColorSetKey.gradientPrimaryBackground),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final nickname = CommonPreferences.lakeNickname.value;
    final greeting = nickname.isEmpty ? 'HELLO' : 'HELLO, $nickname';
    return Container(
      height: 60.h,
      margin: EdgeInsets.fromLTRB(30.w, 10.h, 30.w, 0),
      alignment: Alignment.centerLeft,
      child: ListenableBuilder(
        listenable: showSchedule,
        builder: (context, _) => AnimatedDefaultTextStyle(
          style: showSchedule.value && !Platform.isWindows
              ? TextUtil.base.bright(context).w400.sp(22)
              : TextUtil.base.primary(context).w400.sp(22),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          onEnd: () => useRound.value = showSchedule.value,
          child: Text(greeting, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  /// 今日课程在上，下方白色卡片恰好占满一屏，自习室/GPA/考表填满卡片剩余高度
  /// （不再露出底部的背景色）。手机上与原来一致；较宽时功能卡片换行铺开，
  /// 足够宽时自习室/GPA/考表三栏并排。
  Widget _buildScrollBody({bool wrapTools = false, bool sideBySide = false}) {
    return Provider<ScrollSynchronizer>(
      create: (_) => ScrollSynchronizer.fromExist(_sc),
      child: ListenableBuilder(
        listenable: useRound,
        builder: (context, child) => ClipRRect(
          borderRadius: useRound.value
              ? BorderRadius.vertical(top: Radius.circular(40.r))
              : BorderRadius.zero,
          child: child,
        ),
        child: ScrollConfiguration(
          behavior: WPYScrollBehavior(),
          child: LayoutBuilder(
            builder: (context, viewport) => ListView(
              controller: _sc,
              children: [
                TodayCoursesWidget(),
                SizedBox(
                  height: math.max(viewport.maxHeight, _minSheetHeight.h),
                  child: _buildSheet(
                    margin: EdgeInsets.only(top: 20.h),
                    // 一直延伸到屏幕底部，只有上方是圆角
                    radius: BorderRadius.vertical(top: Radius.circular(40.r)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40.h),
                        ..._buildTools(wrap: wrapTools),
                        Expanded(
                          child: sideBySide
                              ? _buildInfoPanels()
                              : _buildInfoTabs(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 卡片的最小高度（设计稿单位）。窗口很矮（如手机横屏）时保证自习室/GPA/考表
  /// 仍有足够空间，整页继续向下滚动；竖屏手机的一屏高度总是大于它，不受影响
  static const _minSheetHeight = 600.0;

  /// 宽度达到这个值（设计稿单位）时功能卡片换行铺开，不再横向滚动
  static const _largeMinWidth = 600.0;

  /// 宽度达到这个值时自习室 / GPA / 考表三栏并排（每栏至少一屏手机宽度）
  static const _panelsMinWidth = 390.0 * 3;

  static const _infoTitles = ['Study Room', 'GPA Curves', 'Exam Detail'];

  List<Widget> get _infoPages =>
      [MainPageStudyRoomWidget(), GPAPreview(), WpyExamWidget()];

  /// 三栏并排：每栏一个标题 + 占满高度的内容
  Widget _buildInfoPanels() {
    final theme = WpyTheme.of(context);
    final pages = _infoPages;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          14.w, 0, 14.w, MediaQuery.paddingOf(context).bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < pages.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10.w),
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                              color: theme.get(WpyColorKey.warningColor),
                              width: 4),
                        ),
                      ),
                      child: Text(_infoTitles[i],
                          style: TextUtil.base.w400
                              .sp(14)
                              .copyWith(
                                  color:
                                      theme.get(WpyColorKey.basicTextColor))),
                    ),
                    Expanded(child: pages[i]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 白色圆角卡片
  Widget _buildSheet(
      {required Widget child,
      required BorderRadius radius,
      EdgeInsets? margin}) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// 功能跳转卡片与地图校历
  List<Widget> _buildTools({bool wrap = false}) => [
        SliverCardsWidget(CommonPreferences.displayedTool.value, wrap: wrap),
        if (CommonPreferences.showMap.value) const MapAndCalender(),
      ];

  /// 自习室 / GPA / 考表：标签栏 + 占满剩余高度的内容区。
  /// 底部留出导航栏的高度（导航栏浮在页面之上）。
  Widget _buildInfoTabs() {
    final theme = WpyTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: TabBar(
              controller: _tc,
              dividerHeight: 0,
              labelStyle: TextUtil.base.w400.sp(14),
              labelPadding: EdgeInsets.zero,
              labelColor: theme.get(WpyColorKey.basicTextColor),
              unselectedLabelColor: theme.get(WpyColorKey.secondaryTextColor),
              indicator: CustomIndicator(
                  left: true,
                  borderSide: BorderSide(
                      color: theme.get(WpyColorKey.warningColor), width: 4)),
              tabs: [
                for (final label in _infoTitles)
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Tab(text: label)),
              ]),
        ),
        Expanded(
          child: TabBarView(
              controller: _tc,
              physics: BouncingScrollPhysics(),
              children: _infoPages),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ],
    );
  }
}

class SliverCardsWidget extends StatelessWidget {
  final List<CardBean> cards;
  final List<int> order;
  final ScrollController controller = ScrollController();
  static List<String> peiyangLabel = [
    '课程表',
    '入校码',
    '新闻网',
    '课评网',
    '地图·校历',
    '成绩',
    // '小游戏'
    // '失物招领'
  ];

  /// 宽屏时换行铺开显示全部卡片（手机上为可拖动排序的横向列表）
  final bool wrap;

  SliverCardsWidget(this.cards, {this.wrap = false})
      : order = CommonPreferences.sanitizedDisplayOrder();

  Widget _buildItem(BuildContext context, int i) {
    final cardBean = cards[order[i]];
    final isWeb = !peiyangLabel.contains(cardBean.label);
    return WButton(
      key: ValueKey(cardBean.route),
      onPressed: () async {
        if (!isWeb) {
          Navigator.pushNamed(context, cardBean.route);
        } else if (await canLaunchUrl(Uri.parse(cardBean.route))) {
          await launchUrl(Uri.parse(cardBean.route),
              mode: LaunchMode.externalApplication);
        } else {
          ToastProvider.error('请检查网络状态');
        }
      },
      child: generateCard(context, cardBean),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Padding(
        padding: EdgeInsets.only(left: 16.h),
        child: Wrap(children: [
          for (var i = 0; i < order.length; i++) _buildItem(context, i),
        ]),
      );
    }
    Widget cardList = ReorderableListView.builder(
      buildDefaultDragHandles: false,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return child;
      },
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 16.h),
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      itemCount: order.length,
      // 与手机上一致：长按卡片拖动排序
      itemBuilder: (context, i) => ReorderableDelayedDragStartListener(
        key: ValueKey(cards[order[i]].route),
        index: i,
        child: _buildItem(context, i),
      ),
      onReorderItem: (int oldIndex, int newIndex) {
        final int movedIndex = order.removeAt(oldIndex);
        order.insert(newIndex, movedIndex);

        CommonPreferences.displayOrder.value = order.join(',');
      },
    );

    return SizedBox(
      height: 100.h,
      width: double.infinity,
      child: cardList,
    );
  }

  Widget generateCard(BuildContext context, CardBean bean) {
    return Container(
      width: 150.w,
      height: 80.h,
      margin: EdgeInsets.fromLTRB(0, 2.h, 18.h, 16.h),
      decoration: MapAndCalenderState().cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 8.w),
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.2,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bean.label == '地图·校历'
                        ? WpyTheme.of(context).get(WpyColorKey.beanLightColor)
                        : WpyTheme.of(context).get(WpyColorKey.beanDarkColor),
                  ),
                ),
              ),
              ColoredIcon(
                bean.path,
                color: WpyTheme.of(context).primary,
                width: bean.width,
              )
            ],
          ),
          SizedBox(width: 14.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 70.w,
                child: Text(bean.eng,
                    maxLines: 2,
                    style: TextUtil.base.w500.label(context).sp(12).w400,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(
                width: 70.w,
                child: Text(bean.label,
                    maxLines: 2,
                    style: TextUtil.base.w400.label(context).sp(12).medium),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CardBean {
  String path;
  double? width;
  String label;
  String eng;
  String route;

  CardBean(this.path, this.width, this.label, this.eng, this.route);

  /// 将工具转换为普通数据（缓存无法直接保存工具
  Map<String, dynamic> toJson() => {
        'path': path,
        'width': width,
        'label': label,
        'eng': eng,
        'route': route,
      };

  /// 普通数据还原为工具
  factory CardBean.fromJson(Map<String, dynamic> json) {
    return CardBean(
      json['path'] as String,
      (json['width'] as num?)?.toDouble(),
      json['label'] as String,
      json['eng'] as String,
      json['route'] as String,
    );
  }
}

class WPYScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      child: child,
      showLeading: false,
      showTrailing: false,
      axisDirection: AxisDirection.down,
      color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
}
