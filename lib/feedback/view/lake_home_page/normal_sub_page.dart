import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:we_pei_yang_flutter/commons/widgets/adaptive_viewport.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/activity_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/hot_rank_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../components/feed_card.dart';
import '../../../commons/widgets/w_button.dart';

class NSubPage extends StatefulWidget {
  final int index;

  const NSubPage({Key? key, required this.index}) : super(key: key);

  @override
  NSubPageState createState() => NSubPageState(this.index);
}

class NSubPageState extends State<NSubPage> with AutomaticKeepAliveClientMixin {
  int index;

  NSubPageState(this.index);

  List<String> topText = [
    "正在刷新喵",
  ];

  void getRecTag() {
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  bool _shouldToggleSearchbar(
      ScrollNotification scrollInfo, double pixels, double maxScrollExtent) {
    return scrollInfo.metrics.axisDirection == AxisDirection.down &&
        (pixels - _previousOffset).abs() >= 20 &&
        pixels >= 10 &&
        pixels <= maxScrollExtent - 10;
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    // 手动滚动后，阅读位置以屏幕上的帖子为准，不再定位到上次打开的帖子
    if (scrollInfo is UserScrollNotification &&
        scrollInfo.direction != ScrollDirection.idle) {
      PostCardNormal.lastOpenedPostId = null;
    }
    final pixels = scrollInfo.metrics.pixels;
    final maxScrollExtent = scrollInfo.metrics.maxScrollExtent;
    final threshold = 12.h + FeedbackHomePageState.searchBarHeight;

    // Check for refresh idle state and feedback conditions
    if (_refreshController.isRefresh && pixels >= 2) {
      _refreshController.refreshToIdle();
    }
    if (pixels < threshold) {
      _setShowSearch(true);
    }

    // Toggle feedback based on scroll direction
    if (_shouldToggleSearchbar(scrollInfo, pixels, maxScrollExtent)) {
      _setShowSearch(pixels <= _previousOffset);
      _previousOffset = pixels;
    }

    return true;
  }

  bool _showSearchScheduled = false;
  bool _showSearchTarget = true;

  // 滚动通知可能在 SmartRefresher 的 header(LayoutBuilder) 正在 layout 时派发
  // （尤其下拉刷新回弹那一帧），此时直接写 LakeUtil.showSearch 会让监听它的
  // ValueListenableBuilder 在 layout 阶段 setState —— Flutter 3.44 会抛
  // "Build scheduled during frame" 断言并打断这一帧，导致刷新过渡动画丢失。
  // 这里把写入去抖并延后到帧末执行，避免在布局期间触发重建。
  void _setShowSearch(bool value) {
    _showSearchTarget = value;
    if (_showSearchScheduled) return;
    if (LakeUtil.showSearch.value == value) return;
    _showSearchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSearchScheduled = false;
      if (!mounted) return;
      LakeUtil.showSearch.value = _showSearchTarget;
    });
  }

  double _previousOffset = 0;

  Future<void> _onRefresh() async {
    // 这里的逻辑是: 开始刷新-delay100ms-显示刷新动画-结束刷新
    // 或者可能是:  开始刷新 - delay100ms - 显示刷新动画
    //            - 刷新结束但动画还没开始（网太快了）
    //            - 取消动画 （不播放了）-  结束刷新

    // 记录松手进入刷新的时刻，保证"正在刷新"指示至少展示 450ms
    final refreshStart = DateTime.now();

    Timer? task;
    if (!_sortRefreshRequested) {
      task = Timer(Duration(milliseconds: 250), () {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        setState(() {
          _postRefreshSkeleton = true;
        });
      });
    }
    // 刷新
    try {
      _initializeHotTagsIfNeeded();
      _initializeProviders();
      getRecTag();
      await _refreshPostList(refreshStart);
      _initializeLakeArea();
    } catch (e) {
      await _handleRefreshError();
    }

    // 如果还没执行就不执行了
    if (task?.isActive ?? false) task!.cancel();
    if (!mounted) return;
    setState(() {
      // 不再改 ListView 的 key —— 数据通过 postHolder 的 ListenableBuilder 流入并
      // 由 Flutter 增量 diff，换 key 会整树销毁重建（卡顿）并丢失滚动位置（跳回顶部）。
      _listVersion++;
      _postRefreshSkeleton = false;
      _sortRefreshRequested = false;
    });
  }

  void _initializeHotTagsIfNeeded() {
    if (index == 0) {
      context.read<FbHotTagsProvider>().initHotTags();
    }
  }

  Future<void> _refreshPostList(DateTime refreshStart) async {
    await LakeUtil.initPostList(index, forced: true)
        .catchError((e) => _handlePostListFailure(e));
    // 保证"正在刷新"指示至少展示 450ms（自松手进入刷新起算），
    // 不足则补齐再调用 refreshCompleted，避免网络过快时一闪而过
    final elapsed = DateTime.now().difference(refreshStart);
    const minRefreshDuration = Duration(milliseconds: 450);
    if (elapsed < minRefreshDuration) {
      await Future.delayed(minRefreshDuration - elapsed);
    }
    _refreshController.refreshCompleted();
  }

  void _handlePostListFailure(DioException e) {
    final refresh = _refreshController;
    if ([
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout
    ].contains(e.type)) {
      refresh.refreshToIdle();
    }
    refresh.refreshFailed();
  }

  Future<void> _handleRefreshError() async {
    await LakeTokenManager().refreshToken();
    _onRefresh();
    ToastProvider.error("发生未知错误");
    _refreshController.refreshFailed();
  }

  void _initializeAdditionalProviders() {
    context.read<FestivalProvider>().initFestivalList();
    context.read<NoticeProvider>().initNotices();
  }

  _onLoading() async {
    final refresh = _refreshController;
    await LakeUtil.getNextPage(index).catchError((e) => refresh.loadFailed());
    refresh.loadComplete();
  }

  late final LakePageController pageController;
  late final RefreshController _refreshController;
  late final ScrollController _scrollController;
  late Future<void> _postListFuture;
  int _listVersion = 0;

  @override
  void initState() {
    super.initState();
    pageController = LakeUtil.lakePageControllers[index]!;
    _refreshController = RefreshController();
    _scrollController = ScrollController();
    _postListFuture = LakeUtil.initPostList(index);
    // 每个 tab 与它的 LakePageController 一一对应，直接无条件挂上自己的控制器。
    // 不再根据「是否当前 tab」来挂载——那套逻辑依赖 build 重跑，但 keepAlive 下
    // 切 tab 不会重跑 build，导致当前 tab 的控制器挂不上、底栏刷新拿到的是空/旧控制器。
    pageController.attachControllers(_scrollController, _refreshController);
    _initializeProviders();
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _highlightPost.dispose();
    pageController.detachControllers(_scrollController, _refreshController);
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeProviders() {
    _initializeAdditionalProviders();
    context.read<FbHotTagsProvider>().initHotTags();
  }

  void _initializeLakeArea() {
    LakeUtil.initPostList(index);
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildErrorPage() {
    return HomeErrorContainer(
      onRetry: () => setState(() {
        _postListFuture = LakeUtil.initPostList(index, forced: true);
      }),
      errorText: "网络状况不佳，请重试",
    );
  }

  bool _postRefreshSkeleton = false;
  bool _sortRefreshRequested = false;

  void _changeSortAndRefresh(int sortSeq) {
    setState(() {
      _postRefreshSkeleton = true;
      _sortRefreshRequested = true;
    });
    if (LakeUtil.sortSeq.value == sortSeq) {
      _refreshController.requestRefresh();
      return;
    }
    LakeUtil.sortSeq.value = sortSeq;
    _refreshController.requestRefresh();
  }

  Row _buildSortSelection() {
    final hasTop = pageController.postHolder.postsList
        .any((p) => p.eTag == 'top');
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      WButton(
        onPressed: () => _changeSortAndRefresh(1),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 5.w, 6.h),
          child: ValueListenableBuilder(
            valueListenable: LakeUtil.sortSeq,
            builder: (context, sortSeq, _) {
              return Text('默认排序',
                  style: sortSeq != 0
                      ? TextUtil.base.primaryAction(context).w600.sp(14)
                      : TextUtil.base.label(context).w400.sp(14));
            },
          ),
        ),
      ),
      WButton(
        onPressed: () => _changeSortAndRefresh(0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 14.h, 10.w, 6.h),
          child: ValueListenableBuilder(
              valueListenable: LakeUtil.sortSeq,
              builder: (context, sortSeq, _) {
                return Text('最新发帖',
                    style: sortSeq != 0
                        ? TextUtil.base.label(context).w400.sp(14)
                        : TextUtil.base.primaryAction(context).w600.sp(14));
              }),
        ),
      ),
      if (hasTop) ...[
        Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 14.h, 12.w, 6.h),
          child: ValueListenableBuilder(
            valueListenable: LakeUtil.collapsedTopTabs,
            builder: (context, collapsed, _) {
              final isCollapsed = collapsed.contains('$index');
              // 折叠后隐藏开关，仅保留横栏的展开入口
              if (isCollapsed) return SizedBox.shrink();
              return WButton(
                onPressed: () => LakeUtil.toggleCollapsedTop(index),
                child: Text(
                  '折叠置顶帖',
                  style: TextUtil.base.label(context).w400.sp(14),
                ),
              );
            },
          ),
        ),
      ],
    ]);
  }

  // Listview.builder 的builder, 单独写在外面， 比较好看
  /// 每列帖子至少一屏手机宽度（390），放得下两列时才使用瀑布流
  static const _wideFeedMinWidth = 390.0 * 2;

  bool _isWideFeed(BuildContext context) {
    final wide = context.paneDesignWidth > _wideFeedMinWidth;
    _keepReadingPosition(MediaQuery.sizeOf(context).width, wide);
    return wide;
  }

  int get _postCount => _postRefreshSkeleton
      ? 5
      : pageController.postHolder.postsList.length;

  /// 宽屏：欢迎栏、热榜、排序选择器横向撑满，横幅和帖子按瀑布流多列排布。
  /// 每列最宽 585（1.5 屏手机宽度），总宽度超过 780 才使用瀑布流，
  /// 因此列宽始终在 390~585 之间，由框架决定列数（约 1170 起为三列）。
  Widget _buildWideFeed() {
    return CustomScrollView(
      key: PageStorageKey("$index"),
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildPostList(context, 0)),
        SliverToBoxAdapter(child: _buildPostList(context, 1)),
        SliverToBoxAdapter(child: _buildPostList(context, 3)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          sliver: SliverMasonryGrid.extent(
            maxCrossAxisExtent: 585.w,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.w,
            childCount: _postCount + 1,
            // 第一个是横幅，其余是帖子；多列时每条帖子单独成卡片，便于区分边界
            itemBuilder: (context, i) => i == 0
                ? _buildPostList(context, 2)
                : FeedCard(child: _buildPostList(context, i + 3)),
          ),
        ),
      ],
    );
  }

  Widget _buildPostList(context, ind) {
    // Welcome 栏
    if (ind == 0) return AnnouncementBannerWidget();
    ind--;
    // 可能出现的热榜
    if (ind == 0) return index == 0 ? HotCard() : SizedBox(height: 10.h);
    ind--;

    // Banner
    if (ind == 0) return AdCardWidget();
    ind--;

    // 排序方式选择器
    if (ind == 0) return _buildSortSelection();
    ind--;

    if (_postRefreshSkeleton) return PostSkeleton();

    // Post
    final postsList = pageController.postHolder.postsList;
    final post = postsList[ind];
    final isTop = post.eTag == 'top';
    final collapsed = isTop &&
        LakeUtil.collapsedTopTabs.value.contains('$index');
    if (collapsed) {
      // 置顶帖连续排前：仅首个置顶帖位置渲染"展开置顶帖"栏，其余置顶帖留空
      final isFirstTop = postsList.take(ind).every((p) => p.eTag != 'top');
      return isFirstTop ? _buildCollapsedTopBar(index) : const SizedBox.shrink();
    }
    final card = AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: PostCardNormal(
        post,
        key: ValueKey('${LakeUtil.sortSeq.value}-$_listVersion-${post.id}'),
      ),
    );
    return _PostAnchor(
        id: post.id,
        registry: _postAnchors,
        highlight: _highlightPost,
        child: card);
  }

  /// 已构建的帖子所在位置（帖子 id -> context），用于保持阅读位置
  final Map<int, BuildContext> _postAnchors = {};

  /// 需要闪烁提示的帖子
  final ValueNotifier<int?> _highlightPost = ValueNotifier(null);

  double? _lastFeedWidth;
  bool? _lastWideFeed;
  Timer? _settleTimer;

  /// 宽度变化时保持阅读位置（在 build 中调用，此时帖子仍是上一帧的位置）：
  /// * 多列/单列切换且刚打开过帖子（平行视界展开/收起）：把这条帖子滚动到顶部附近，
  ///   等分栏动画结束后平滑对齐并闪烁提示；
  /// * 其它情况（拖动改变窗口大小）：保持屏幕顶部正在阅读的帖子与列表顶部的距离不变。
  void _keepReadingPosition(double width, bool wideFeed) {
    final widthChanged = _lastFeedWidth != null && _lastFeedWidth != width;
    final modeChanged = _lastWideFeed != null && _lastWideFeed != wideFeed;
    _lastFeedWidth = width;
    _lastWideFeed = wideFeed;
    if (!widthChanged) return;

    final opened = PostCardNormal.lastOpenedPostId;
    if (modeChanged && opened != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealPost(opened));
      _settleTimer?.cancel();
      _settleTimer = Timer(const Duration(milliseconds: 320),
          () => _revealPost(opened, animate: true));
      return;
    }
    final reading = _readingAnchor();
    if (reading == null) return;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _restoreAnchor(reading.id, reading.top));
  }

  /// 帖子相对列表顶部的位置
  double? _postTop(int id) {
    final list = context.findRenderObject();
    final box = _postAnchors[id]?.findRenderObject();
    if (list is! RenderBox || box is! RenderBox) return null;
    if (!list.attached || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: list).dy;
  }

  /// 屏幕上正在阅读的帖子：最靠上、且仍有一部分露在列表顶部以下的帖子
  ({int id, double top})? _readingAnchor() {
    ({int id, double top})? best;
    for (final entry in _postAnchors.entries) {
      final top = _postTop(entry.key);
      final box = entry.value.findRenderObject();
      if (top == null || box is! RenderBox) continue;
      if (top + box.size.height <= 40) continue;
      if (best == null || top < best.top) best = (id: entry.key, top: top);
    }
    return best;
  }

  void _restoreAnchor(int id, double oldTop) {
    if (!mounted || !_scrollController.hasClients) return;
    final top = _postTop(id);
    if (top == null) return;
    final position = _scrollController.position;
    _scrollController.jumpTo((position.pixels + top - oldTop)
        .clamp(0.0, position.maxScrollExtent));
  }

  /// 把帖子滚动到列表顶部附近；[animate] 时平滑滚动并闪烁提示
  void _revealPost(int id, {bool animate = false, int attempt = 0}) {
    if (!mounted || !_scrollController.hasClients) return;
    final anchor = _postAnchors[id];
    final box = anchor != null && anchor.mounted ? anchor.findRenderObject() : null;
    if (box != null && box.attached) {
      // 只滚动帖子列表自身。Scrollable.ensureVisible 会逐级滚动所有外层可滚动组件，
      // 包括首页分页和湖底分区的横向 TabBarView，折叠屏展开时会把首页切到湖底
      _scrollController.position.ensureVisible(box,
          alignment: 0.05,
          duration:
              animate ? const Duration(milliseconds: 380) : Duration.zero,
          curve: Curves.easeOutCubic);
      if (animate) {
        _highlightPost.value = null;
        _highlightPost.value = id;
      }
      return;
    }
    // 帖子还没有构建：按它在列表中的位置估算偏移，跳过去后再精确对齐
    final posts = pageController.postHolder.postsList;
    final index = posts.indexWhere((p) => p.id == id);
    if (index < 0 || attempt >= 3) return;
    final position = _scrollController.position;
    final estimate = position.maxScrollExtent * index / posts.length;
    _scrollController.jumpTo(estimate.clamp(0.0, position.maxScrollExtent));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _revealPost(id, animate: animate, attempt: attempt + 1));
  }

  /// 折叠置顶帖后的统一"展开置顶帖"栏（不显示任何标题，极简）
  Widget _buildCollapsedTopBar(int tabId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 4),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: () => LakeUtil.toggleCollapsedTop(tabId),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.lightBorderColor),
                    width: 1.h),
              ),
            ),
            child: Row(
              children: [
                ETagWidget(entry: 'top', full: false),
                SizedBox(width: 8),
                Text('展开置顶帖',
                    style: TextUtil.base.NotoSansSC.w400.sp(14).primary(context)),
                Spacer(),
                Icon(Icons.keyboard_arrow_down,
                    size: 22,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.secondaryTextColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
        future: _postListFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: () {
              // 为了让AnimatedSwitcher能够执行，这里用了一个匿名函数
              // 有点丑陋，但是不知道怎么解决
              if (snapshot.hasError) {
                return _buildErrorPage();
              }

              if (snapshot.connectionState != ConnectionState.done) {
                return RefreshSkeleton();
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) =>
                    _onScrollNotification(scrollInfo),
                child: ListenableBuilder(
                  // 这里是Post的Listview, 需要监听Post刷新
                  // 同时监听折叠状态，切换折叠时重建列表
                  listenable: Listenable.merge(
                      [pageController.postHolder, LakeUtil.collapsedTopTabs]),
                  builder: (context, oldChild) {
                    final refresher = SmartRefresher(
                      physics: BouncingScrollPhysics(),
                      controller: _refreshController,
                      scrollController: _scrollController,
                      header: ClassicHeader(
                        height: 5.h,
                        completeDuration: Duration(milliseconds: 300),
                        idleText: '下拉以刷新 (乀*･ω･)乀',
                        releaseText: '下拉以刷新',
                        refreshingText:
                            topText[Random().nextInt(topText.length)],
                        completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
                        failedText: '刷新失败（；´д｀）ゞ',
                      ),
                      cacheExtent: context.sh(),
                      enablePullDown: true,
                      onRefresh: _onRefresh,
                      footer: ClassicFooter(
                        idleText: '下拉以刷新',
                        noDataText: '无数据',
                        loadingText: '加载中，请稍等  ;P',
                        failedText: '加载失败（；´д｀）ゞ',
                      ),
                      enablePullUp: true,
                      onLoading: _onLoading,
                      // 宽屏放得下两列帖子时改为瀑布流，手机上保持原来的列表
                      child: _isWideFeed(context)
                          ? _buildWideFeed()
                          : ListView.builder(
                              // 根据要求， Listview必须紧挨着SmartRefresher，不能包装任何东西
                              key: PageStorageKey("$index"),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // 4是因为前面有4个widget，
                              // Welcome, 热榜， Banner, 排序选择器
                              itemCount: _postCount + 4,
                              itemBuilder: _buildPostList,
                            ),
                    );
                    return refresher;
                  },
                ),
              );
            }(),
          );
        });
  }
}

/// 记录帖子在列表中的 context（帖子被回收时自动移除），
/// 并在 [highlight] 指向自己时闪烁一下，帮助找到刚才阅读的帖子
class _PostAnchor extends StatefulWidget {
  const _PostAnchor({
    required this.id,
    required this.registry,
    required this.highlight,
    required this.child,
  });

  final int id;
  final Map<int, BuildContext> registry;
  final ValueNotifier<int?> highlight;
  final Widget child;

  @override
  State<_PostAnchor> createState() => _PostAnchorState();
}

class _PostAnchorState extends State<_PostAnchor>
    with SingleTickerProviderStateMixin {
  late final _flash = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    widget.highlight.addListener(_onHighlight);
  }

  void _onHighlight() {
    if (widget.highlight.value == widget.id) _flash.forward(from: 0);
  }

  @override
  void dispose() {
    widget.highlight.removeListener(_onHighlight);
    _flash.dispose();
    if (widget.registry[widget.id] == context) {
      widget.registry.remove(widget.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.registry[widget.id] = context;
    final color = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);
    // 结构保持不变（始终有 DecoratedBox），避免帖子被重建
    return AnimatedBuilder(
      animation: _flash,
      child: widget.child,
      builder: (context, child) {
        final t = _flash.value;
        // 快速亮起、缓慢消失
        final strength = (t < 0.15 ? t / 0.15 : (1 - t) / 0.85).clamp(0.0, 1.0);
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16 * strength),
          ),
          child: child,
        );
      },
    );
  }
}

class RefreshSkeleton extends StatelessWidget {
  const RefreshSkeleton({super.key, this.initialScrollOffset = true});

  final bool initialScrollOffset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      controller: initialScrollOffset
          ? ScrollController(
              initialScrollOffset: FeedbackHomePageState.searchBarHeight / 2)
          : null,
      children: [
        AnnouncementBannerWidget(),
        BannerSkeleton(),
        for (int i = 0; i < 5; i++) PostSkeleton(),
      ],
    );
  }
}

class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = WpyTheme.of(context).get(WpyColorKey.infoTextColor);
    final highlight =
        WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Shimmer.fromColors(
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black12,
                  ),
                ),
                baseColor: base,
                highlightColor: highlight,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      child: Container(
                        height: 15,
                        margin: EdgeInsets.symmetric(vertical: 2),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.black12,
                        ),
                      ),
                      baseColor: base,
                      highlightColor: highlight,
                    ),
                    Shimmer.fromColors(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.symmetric(vertical: 2),
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          color: Colors.black12,
                        ),
                      ),
                      baseColor: base,
                      highlightColor: highlight,
                    ),
                  ],
                ),
              ),
              Shimmer.fromColors(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.symmetric(vertical: 2),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: Colors.black12,
                  ),
                ),
                baseColor: base,
                highlightColor: highlight,
              ),
            ],
          ),
          SizedBox(height: 10),
          for (int i = 1; i <= 3; i++) ...[
            Shimmer.fromColors(
              child: Container(
                height: 18,
                margin: EdgeInsets.symmetric(vertical: 2),
                width: i == 3 ? 150 : double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: Colors.black12,
                ),
              ),
              baseColor: base,
              highlightColor: highlight,
            ),
            SizedBox(height: 5),
          ]
        ],
      ),
    );
  }
}

class WelcomeSkeleton extends StatelessWidget {
  const WelcomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        child: Container(
          height: 35.h,
          margin: EdgeInsets.only(
              // top: FeedbackHomePageState.searchBarHeight,
              left: 14.w,
              right: 14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            color: Colors.black12, // 写死Color, 这个在什么模式都调教的比较好看
          ),
        ),
        period: Duration(milliseconds: 1000),
        baseColor: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
        highlightColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor));
  }
}

class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        // 与活动横幅相同比例的骨架
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
          child: AspectRatio(
            aspectRatio: ActivityCard.aspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.black12,
              ),
            ),
          ),
        ),
        period: Duration(milliseconds: 1000),
        baseColor: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
        highlightColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryInfoTextColor));
  }
}

// 论坛首页的Banner
class AdCardWidget extends StatelessWidget {
  const AdCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _len = context.watch<FestivalProvider>().nonePopupListLength;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _len > 0
            ? ActivityCard()
            : Shimmer.fromColors(
                baseColor: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
                highlightColor: WpyTheme.of(context)
                    .get(WpyColorKey.secondaryInfoTextColor),
                child: AspectRatio(
                  aspectRatio: ActivityCard.aspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      color: Colors.black12,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// 错误的猴子
class HomeErrorContainer extends StatefulWidget {
  final void Function() onRetry;
  final String errorText;

  HomeErrorContainer({
    required this.onRetry,
    required this.errorText,
  });

  @override
  _HomeErrorContainerState createState() => _HomeErrorContainerState();
}

class _HomeErrorContainerState extends State<HomeErrorContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurveTween(curve: Curves.easeInOutCubic).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var errorImg = WpyPic('assets/images/lake_butt_icons/monkie.png',
        height: 160, width: 160);

    var errorText = Text(widget.errorText,
        style: TextUtil.base.label(context).NotoSansSC.w600.sp(16));

    var retryButton = FloatingActionButton(
      child: RotationTransition(
        alignment: Alignment.center,
        turns: animation,
        child: Icon(Icons.refresh),
      ),
      elevation: 4,
      heroTag: 'error_btn',
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      foregroundColor: WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
      onPressed: widget.onRetry,
      mini: true,
    );

    var paddingBox = SizedBox(height: 52.75.h);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            errorImg,
            SizedBox(height: 20.h),
            errorText,
            paddingBox,
            retryButton
          ],
        ),
      ),
    );
  }
}

class AnnouncementBannerWidget extends StatelessWidget {
  const AnnouncementBannerWidget({super.key});

  String get _getGreetText {
    int hour = DateTime.now().hour;
    if (hour < 5)
      return '晚上好';
    else if (hour >= 5 && hour < 12)
      return '早上好';
    else if (hour >= 12 && hour < 14)
      return '中午好';
    else if (hour >= 12 && hour < 17)
      return '下午好';
    else if (hour >= 17 && hour < 19)
      return '傍晚好';
    else
      return '晚上好';
  }

  /// 公告标题：去掉换行，过长时截断（跑马灯里需要固定长度的文字）
  String _shortTitle(String title) {
    final oneLine = title.replaceAll('\n', ' ');
    return oneLine.length > 21 ? '${oneLine.substring(0, 20)}...' : oneLine;
  }

  Widget _buildNotices(BuildContext context) {
    final notices = context.read<NoticeProvider>().noticeList;
    final style =
        TextUtil.base.primaryAction(context).w400.NotoSansSC.sp(15);
    if (notices.length == 1) {
      return Text(notices.first.title.replaceAll('\n', ' '),
          maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }
    return TextScroller(
      stepOffset: 500,
      duration: Duration(seconds: 20),
      paddingLeft: 0.0,
      children: [
        for (final notice in notices)
          Text('· ${_shortTitle(notice.title)}           ', style: style),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final nickname = CommonPreferences.lakeNickname.value;
    final name = nickname == '无昵称' ? '微友' : nickname;
    return Text(
      '${_getGreetText}, $name',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextUtil.base.primaryAction(context).w600.NotoSansSC.sp(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNotice = context.read<NoticeProvider>().noticeList.isNotEmpty;
    return Container(
      height: 35.h,
      margin: EdgeInsets.only(
          top: FeedbackHomePageState.searchBarHeight, left: 14.w, right: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          color: WpyTheme.of(context)
              .get(WpyColorKey.primaryActionColor)
              .withAlpha(12)),
      // 文字占满剩余宽度，放不下时省略/滚动
      child: Row(
        children: [
          if (hasNotice) ...[
            SvgPicture.asset(
              "assets/svg_pics/lake_butt_icons/la_ba.svg",
              width: 20,
              colorFilter: ColorFilter.mode(
                  WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                  BlendMode.srcIn),
            ),
            SizedBox(width: 6),
          ],
          Expanded(
            child: hasNotice
                ? _buildNotices(context)
                : _buildGreeting(context),
          ),
        ],
      ),
    );
  }
}

//https://www.cnblogs.com/qqcc1388/p/12405548.html
/// 跑马灯哗哗哗
/// 这个实现了Welcome的横向滚动
class TextScroller extends StatefulWidget {
  final Duration duration; // 轮播时间
  final double stepOffset; // 偏移量
  final double paddingLeft; // 内容之间的间距
  final List<Widget> children; //内容

  TextScroller(
      {required this.paddingLeft,
      required this.duration,
      required this.stepOffset,
      required this.children});

  _TextScrollerState createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  late ScrollController _controller; // 执行动画的controller
  late Timer _timer; // 定时器timer
  double _offset = 0.0; // 执行动画的偏移量

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: _offset);
    _timer = Timer.periodic(widget.duration, (timer) {
      double newOffset = _controller.offset + widget.stepOffset;
      if (newOffset != _offset) {
        _offset = newOffset;
        _controller.animateTo(_offset,
            duration: widget.duration, curve: Curves.linear); // 线性曲线动画
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _child() {
    return new Row(children: _children());
  }

  // 子视图
  List<Widget> _children() {
    List<Widget> items = [];
    List list = widget.children;
    for (var i = 0; i < list.length; i++) {
      Container item = new Container(
        margin: new EdgeInsets.only(right: widget.paddingLeft),
        child: list[i],
      );
      items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal, // 横向滚动
      controller: _controller, // 滚动的controller
      itemBuilder: (context, index) {
        return _child();
      },
    );
  }
}
