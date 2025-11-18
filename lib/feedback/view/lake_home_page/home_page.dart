import 'dart:io';
import 'dart:math';

import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tab.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/normal_sub_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import 'package:badges/badges.dart' as badges;

class FeedbackHomePage extends StatefulWidget {
  FeedbackHomePage({Key? key}) : super(key: key);

  @override
  FeedbackHomePageState createState() => FeedbackHomePageState();
}

class FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final fbKey = new GlobalKey<FbTagsWrapState>();

  bool initializeRefresh = false;

  bool showFBDropdown = false;

  // double get _safeTop => MediaQuery.of(context).padding.top;
  /// 42.h
  static double get searchBarHeight => 42.h;

  /// 46.h
  double get tabBarHeight => 46.h;

  late final FbDepartmentsProvider _departmentsProvider;

  initPage() {
    _departmentsProvider.initDepartments();
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
    context.read<FbHotTagsProvider>().initHotTags();
    FeedbackService.getUserInfo(
        onSuccess: () {},
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        });
  }

  @override
  void initState() {
    super.initState();
    _departmentsProvider =
        Provider.of<FbDepartmentsProvider>(context, listen: false);
    LakeUtil.getClipboardWeKoContents(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPage();
    });
  }

  @override
  bool get wantKeepAlive => true;

  void listToTop() async {
    // 页面还没加载完成， 无法滚动到顶部
    if (tabController == null) return;
    final controller = LakeUtil.currentController.scrollController;
    if (!controller.hasClients) return;

    // 如果距离太大，直接跳转到1500， 防止动画太夸张
    if (controller.offset > 1500) {
      controller.jumpTo(1500.toDouble());
    }

    await controller.animateTo(
      -85.toDouble(),
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCirc,
    );
    Future.delayed(Duration(milliseconds: 400), () {
      controller.jumpTo(0.toDouble());
    });
  }

  TabController? tabController;

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _onTabChange() {
    LakeUtil.currentTab.value = tabController!.index;
    if (tabController != null && LakeUtil.tabList.isNotEmpty) {
      final currentTabIndex = tabController!.index;
      final isSchoolAffairsTab =
          LakeUtil.tabList[currentTabIndex].name == '校务专区';

      if (!isSchoolAffairsTab) {
        fbKey.currentState?.hide();
      }
    }
  }

  void _initializeTabController(int length) {
    tabController = TabController(
      length: length,
      vsync: this,
      initialIndex: min(max(0, length - 1), LakeUtil.currentTab.value),
    )..addListener(() {
        _onTabChange();
      });
  }

  Widget _buildSearchBar() {
    return WButton(
      onPressed: () => Navigator.pushNamed(context, FeedbackRouter.search),
      child: Container(
        height: searchBarHeight - 8.h,
        margin: EdgeInsets.fromLTRB(15.h, 8.h, 10.h, 0),
        decoration: BoxDecoration(
            color:
                WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
            borderRadius: BorderRadius.all(Radius.circular(15.h))),
        child: Row(children: [
          SizedBox(width: 14.h),
          Icon(
            Icons.search,
            size: 19,
            color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
          ),
          SizedBox(width: 12.h),
          Consumer<FbHotTagsProvider>(
              builder: (_, data, __) => Row(children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1.sw - 260),
                      child: Text(
                        data.recTag == null ? '搜索发现' : '#${data.recTag?.name}#',
                        overflow: TextOverflow.ellipsis,
                        style: TextUtil.base
                            .infoText(context)
                            .NotoSansSC
                            .w400
                            .sp(15),
                      ),
                    ),
                    //搜索栏文字
                    if (data.recTag != null) ...[
                      SizedBox(width: 10),
                      Text(
                        '为你推荐',
                        overflow: TextOverflow.ellipsis,
                        style: TextUtil.base
                            .infoText(context)
                            .NotoSansSC
                            .w400
                            .sp(15),
                      ),
                    ],
                  ])),
          Spacer(),
          SizedBox(width: 14.h),
        ]),
      ),
    );
  }

  Widget _buildReloadPage() {
    return HomeErrorContainer(
      // 直接重新Load 这个Widget,重新来FutureBuilder的Future
      onRetry: () => setState(() {}),
      errorText: "完全没有网络，论坛加载失败",
    );
  }

  Widget _buildLoadingPage() {
    final base = WpyTheme.of(context).get(WpyColorKey.infoTextColor);
    final highlight =
        WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor);
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 0.9.sw, child: _buildSearchBar()),
                    _buildMessageButton()
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: tabBarHeight - 14,
                  width: 1.sw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            for (int i = 0; i < 7; i++)
                              Shimmer.fromColors(
                                child: Container(
                                  width: 50,
                                  margin: EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                baseColor: base,
                                highlightColor: highlight,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
              // 因为上面的空要藏住搜索框
              top: max(MediaQuery.of(context).padding.top + searchBarHeight,
                  searchBarHeight + tabBarHeight),
              bottom: Platform.isWindows ? 0 : 52.h),
          child: RefreshSkeleton(),
        ),
      ],
    );
  }

  Widget _buildForumView(List<WPYTab> tabs) {
    return ExtendedTabBarView(
      cacheExtent: 0,
      controller: tabController!,
      children: List<Widget>.generate(
        tabs.length,
        (i) => NSubPage(index: tabs[i].id),
      ),
    );
  }

  Widget _buildTabBar(List<WPYTab> tabList) {
    return Expanded(
      child: TabBar(
        dividerHeight: 0,
        indicatorPadding: EdgeInsets.only(bottom: 2.h),
        labelPadding: EdgeInsets.only(bottom: 3.h),
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        physics: BouncingScrollPhysics(),
        controller: tabController!,
        labelColor: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
        labelStyle: TextUtil.base.w400.NotoSansSC.sp(18),
        unselectedLabelColor:
            WpyTheme.of(context).get(WpyColorKey.labelTextColor),
        unselectedLabelStyle: TextUtil.base.w400.NotoSansSC.sp(18),
        indicator: CustomIndicator(
          borderSide: BorderSide(
            color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
            width: 2.h,
          ),
        ),
        onTap: (index) {
          // final tabName = tabList[index].name;
          //
          // if (tabName == '校务专区') {
          //   fbKey.currentState?.tap();
          // } else {
          //   fbKey.currentState?.hide();
          // }
        },
        tabs: List.generate(tabList.length, (index) {
          final isSchoolAffairs = tabList[index].name == '校务专区';
          final isSelected = index == tabController!.index;

          return DaTab(
            selected: isSelected,
            text: tabList[index].shortname,
            withDropDownButton: isSchoolAffairs,
            onTap: isSchoolAffairs ? () => fbKey.currentState?.tap() : null,
          );
        }),
      ),
    );
  }

  Widget _buildMessageButton() {
    return Builder(builder: (context) {
      List<MessageType> types = MessageType.values;
      int count = 0;
      for (var type in types) {
        count += context
            .select((MessageProvider messageProvider) =>
                messageProvider.getMessageCount(type: type))
            .toInt();
      }

      final MailIcon = Icon(
        Icons.mail_outline,
        color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
        size: 25.r,
      );
      return WButton(
        onPressed: () {
          Navigator.pushNamed(context, FeedbackRouter.mailbox);
        },
        child: Container(
          margin: EdgeInsets.only(top: 8.h),
          child: count == 0
              ? MailIcon
              : badges.Badge(
                  child: MailIcon,
                  //考古, 红点实现方法!!
                  badgeContent: Text(
                    count.toString(),
                    style: TextUtil.base.reverse(context).sp(8),
                  )),
        ),
      );
    });
  }

  /*
  *
  * 具体的流程是： 首先打开， 加载Tab（使用FutureBuilder）
  * Tab没加载完成之前，显示全屏的Loading
  * 加载完成之后，初始化TabController
  * 构建TabBar SearchBar 和 ForumView (主要的帖子显示区域)
  * */
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 使用stack 为了让上面的搜索框可以根据下滑来决定是否展开
    // 这样看起来比较Q弹
    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      body: AnimatedSwitcher(
        // 给状态切换增加动画
        duration: Duration(milliseconds: 200),
        child: FutureBuilder(
            future: LakeUtil.initTabList(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildReloadPage();
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return _buildLoadingPage();
              }
              // 第一次打开页面，且加载成功, 初始化tabController
              if (tabController == null) {
                _initializeTabController(LakeUtil.tabList.length);
              }
              return Stack(
                children: [
                  // 主要的ListView, 帖子渲染在这个里面
                  Padding(
                    padding: EdgeInsets.only(
                        // 因为上面的空要藏住搜索框
                        top: max(
                            MediaQuery.of(context).padding.top +
                                searchBarHeight,
                            searchBarHeight + tabBarHeight),
                        bottom: Platform.isWindows ? 0 : 52.h),
                    child: _buildForumView(LakeUtil.tabList),
                  ),

                  // TabBar & SearchBar，根据是否展开搜索框决定顶部Padding
                  ValueListenableBuilder(
                    valueListenable: LakeUtil.showSearch,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: 0.9.sw, child: _buildSearchBar()),
                            _buildMessageButton()
                          ],
                        ),
                        SizedBox(
                          height: tabBarHeight,
                          width: 1.sw,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(width: 4),
                              _buildTabBar(LakeUtil.tabList),
                              SizedBox(width: 4)
                            ],
                          ),
                        )
                      ],
                    ),
                    builder: (context, showSearch, child) {
                      return AnimatedContainer(
                          height: searchBarHeight + tabBarHeight,
                          margin: EdgeInsets.only(
                            top: () {
                              final topPadding =
                                  MediaQuery.of(context).padding.top;

                              if (showSearch) {
                                // If `barExtended` is true
                                if (topPadding < searchBarHeight) {
                                  return searchBarHeight;
                                } else {
                                  return topPadding;
                                }
                              } else {
                                if (topPadding < searchBarHeight) {
                                  return 0;
                                } else {
                                  return topPadding - searchBarHeight;
                                }
                              }
                            }()
                                .toDouble(),
                          ),
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.primaryBackgroundColor),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOutCirc,
                          child: child);
                    },
                  ),
                  // 用来遮挡隐藏上去的搜索框
                  Container(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.primaryBackgroundColor),
                      height:
                          MediaQuery.of(context).padding.top < searchBarHeight
                              ? searchBarHeight
                              : MediaQuery.of(context).padding.top),
                  ValueListenableBuilder<bool>(
                    valueListenable: LakeUtil.showSearch,
                    builder: (context, showSearch, _) {
                      final topPadding = MediaQuery.of(context).padding.top;
                      final totalHeaderHeight = searchBarHeight + tabBarHeight;

                      double headerMarginTop;
                      if (topPadding < searchBarHeight) {
                        headerMarginTop = showSearch ? searchBarHeight : 0;
                      } else {
                        headerMarginTop = showSearch
                            ? topPadding
                            : topPadding - searchBarHeight;
                      }

                      final calculatedTop = headerMarginTop + totalHeaderHeight;

                      return Positioned(
                        top: calculatedTop,
                        left: 0,
                        right: 0,
                        child: FbTagsWrap(
                          key: fbKey,
                          maxHeight: MediaQuery.of(context).size.height -
                              calculatedTop -
                              (Platform.isWindows ? 0 : 52.h) -
                              MediaQuery.of(context).padding.bottom,
                        ),
                      );
                    },
                  ),

                  // 发帖按钮 addPost
                  Positioned(
                    bottom: ScreenUtil().bottomBarHeight + 90.h,
                    right: 20.w,
                    child: Hero(
                      tag: "addNewPost",
                      child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: ColoredIcon(
                            'assets/images/add_post.png',
                            width: 72.r,
                            color: WpyTheme.of(context).primary,
                          ),
                          onTap: () {
                            initializeRefresh = true;
                            // TODO: 简化这里， 这里太丑陋了
                            context
                                    .read<NewPostProvider>()
                                    .postTypeNotifier
                                    .value =
                                LakeUtil.tabList[tabController!.index].id;
                            Navigator.pushNamed(context, FeedbackRouter.newPost,
                                arguments: NewPostArgs(false, '', 0, ''));
                          }),
                    ),
                  ),

                  // 似乎是活动悬浮球
                  BannerWidget(),
                ],
              );
            }),
      ),
    );
  }
}

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FestivalProvider>(
        builder: (BuildContext context, fp, Widget? child) {
      if (fp.popUpIndex() != -1) {
        int index = fp.popUpIndex();
        final url = fp.festivalList[index].url;
        final picUrl = fp.festivalList[index].image;
        return Positioned(
          bottom: ScreenUtil().bottomBarHeight + 180.h,
          right: 20.w + 6.r,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.all(Radius.circular(100.r)),
            child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  height: 60.r,
                  width: 60.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100.r)),
                    image: DecorationImage(
                        image: NetworkImage(picUrl), fit: BoxFit.cover),
                  ),
                ),
                onTap: () async {
                  if (!url.isEmpty) {
                    if (url.startsWith('browser:')) {
                      final launchUrl = url
                          .replaceAll('browser:', '')
                          .replaceAll(
                              '<token>', '${CommonPreferences.token.value}')
                          .replaceAll('<laketoken>',
                              '${await LakeTokenManager().refreshToken()}');
                      if (await canLaunchUrlString(launchUrl)) {
                        launchUrlString(launchUrl,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ToastProvider.error('好像无法打开活动呢，请联系天外天工作室');
                      }
                    } else
                      Navigator.pushNamed(context, FeedbackRouter.haitang,
                          arguments: FestivalArgs(
                              url,
                              context
                                  .read<FestivalProvider>()
                                  .festivalList[index]
                                  .title));
                  }
                }),
          ),
        );
      } else
        return SizedBox();
    });
  }
}

class FbTagsWrap extends StatefulWidget {
  final double maxHeight;
  const FbTagsWrap({Key? key, required this.maxHeight}) : super(key: key);

  @override
  FbTagsWrapState createState() => FbTagsWrapState();
}

class FbTagsWrapState extends State<FbTagsWrap>
    with SingleTickerProviderStateMixin {
  bool _tagsContainerCanAnimate = true;
  bool _tagsContainerBackgroundIsShow = false;
  bool _tagsWrapIsShow = false;
  double _tagsContainerBackgroundOpacity = 0;

  _offstageTheBackground() {
    _tagsContainerCanAnimate = true;
    if (_tagsContainerBackgroundOpacity < 1) {
      _tagsContainerBackgroundIsShow = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var tagsWrap = Consumer<FbDepartmentsProvider>(
      builder: (_, provider, __) {
        return Padding(
          padding: EdgeInsets.fromLTRB(12.h, 0, 12.h, 8.h),
          child: Wrap(
            spacing: 6,
            children: List.generate(provider.departmentList.length, (index) {
              return InkResponse(
                radius: 30,
                highlightColor: Colors.transparent,
                child: Chip(
                  backgroundColor:
                      WpyTheme.of(context).get(WpyColorKey.tagLabelColor),
                  label: Text(provider.departmentList[index].name,
                      style: TextUtil.base.normal
                          .label(context)
                          .NotoSansSC
                          .sp(13)),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    FeedbackRouter.searchResult,
                    arguments: SearchResultPageArgs(
                        '',
                        '',
                        provider.departmentList[index].id.toString(),
                        '#${provider.departmentList[index].name}',
                        1,
                        0),
                  );
                },
              );
            }),
          ),
        );
      },
    );
    var _departmentSelectionContainer = Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(22.h),
              bottomRight: Radius.circular(22.h))),
      child: AnimatedSize(
        curve: Curves.easeOutCirc,
        duration: Duration(milliseconds: 400),
        child: Offstage(offstage: !_tagsWrapIsShow, child: tagsWrap),
      ),
    );
    return Stack(
      children: [
        Offstage(
            offstage: !_tagsContainerBackgroundIsShow,
            child: AnimatedOpacity(
              opacity: _tagsContainerBackgroundOpacity,
              duration: Duration(milliseconds: 500),
              onEnd: _offstageTheBackground,
              child: Container(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.reverseBackgroundColor)
                    .withOpacity(0.45),
              ),
            )),
        Offstage(
          offstage: !_tagsContainerBackgroundIsShow,
          child: _departmentSelectionContainer,
        ),
      ],
    );
  }

  void tap() {
    if (_tagsContainerCanAnimate) _tagsContainerCanAnimate = false;
    if (_tagsWrapIsShow == false)
      setState(() {
        _tagsWrapIsShow = true;
        _tagsContainerBackgroundIsShow = true;
        _tagsContainerBackgroundOpacity = 1.0;
      });
    else
      setState(() {
        _tagsContainerBackgroundOpacity = 0;
        _tagsWrapIsShow = false;
      });
  }

  void hide() {
    if (_tagsWrapIsShow == true) {
      if (_tagsContainerCanAnimate) _tagsContainerCanAnimate = false;
      setState(() {
        _tagsContainerBackgroundOpacity = 0;
        _tagsWrapIsShow = false;
      });
    }
  }
}
