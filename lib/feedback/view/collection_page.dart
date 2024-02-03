import 'package:flutter/material.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/refresh_header.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import 'components/post_card.dart';

/// Almost the same as [UserPage].
class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

enum _CurrentTab {
  myPosts,
  myCollect,
}

class _CollectionPageState extends State<CollectionPage> {
  ValueNotifier<_CurrentTab> _currentTab = ValueNotifier(_CurrentTab.myCollect);
  late final PageController _tabController;
  List<Post> _favList = [];
  var _refreshController = RefreshController(initialRefresh: true);
  bool tap = false;
  int currentPage = 1;

  _getMyCollects({Function(List<Post>)? onSuccess, Function? onFail}) {
    FeedbackService.getFavoritePosts(
        page: currentPage,
        page_size: 10,
        onResult: (list) {
          setState(() {
            onSuccess?.call(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail?.call();
        });
  }

  //刷新
  _onRefresh() {
    FeedbackService.getUserInfo(onSuccess: () {
      setState(() {});
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
    currentPage = 1;
    _refreshController.resetNoData();
    _getMyCollects(onSuccess: (list) {
      _favList = list;
      _refreshController.refreshCompleted();
    }, onFail: () {
      _refreshController.refreshFailed();
    });
  }

//下拉加载
  _onLoading() {
    currentPage++;
    _getMyCollects(onSuccess: (list) {
      if (list.length == 0) {
        _refreshController.loadNoData();
        currentPage--;
      } else {
        _favList.addAll(list);
        _refreshController.loadComplete();
      }
    }, onFail: () {
      currentPage--;
      _refreshController.loadFailed();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = PageController(
      initialPage: 0,
    )..addListener(() {
        var absPosition =
            (_tabController.page! - _currentTab.value.index).abs();
        if (absPosition > 0.5 && !tap) {
          _currentTab.value = _CurrentTab.values[_tabController.page!.round()];
        }
        _refreshController.requestRefresh();
      });
    _currentTab.addListener(() {
      tap = true;
      _tabController
          .animateToPage(
            1,
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          )
          .then((value) => tap = false);
    });
    _getMyCollects();
  }

  @override
  Widget build(BuildContext context) {
    ///拆出去单写会刷新错误..
    ///收藏List栏，为空时显示无
    var favLists = (ListView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Widget fav = PostCardNormal(
          _favList[index],
        );
        return fav;
      },
      itemCount: _favList.length,
    ));
    var list = ExpandablePageView(
      controller: _tabController,
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Builder(
              key: ValueKey(_favList.length.isZero),
              builder: (context) {
                if (_favList.length.isZero) {
                  return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text("暂无收藏", style: TextUtil.base.grey6267));
                } else {
                  return Column(
                    children: [favLists, SizedBox(height: 20.w)],
                  );
                }
              }),
        )
      ],
    );

    Widget body = CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: ColorUtil.secondaryBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorUtil.bold42TextColor,
              size: 20.w,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "我的收藏",
            style: TextUtil.base.NotoSansSC.black2A.w600.sp(18),
          ),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Container(color: ColorUtil.secondaryBackgroundColor, child: list),
        )
      ],
    );

    return Container(
      //改背景色用
      color: ColorUtil.secondaryBackgroundColor,
      child: SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController,
        header: RefreshHeader(),
        footer: ClassicFooter(
          idleText: '没有更多数据了:>',
          idleIcon: Icon(Icons.check),
        ),
        enablePullDown: true,
        onRefresh: _onRefresh,
        enablePullUp: true,
        onLoading: _onLoading,
        child: body,
      ),
    );
  }
}

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;
  final PageController controller;

  const ExpandablePageView({
    Key? key,
    required this.children,
    required this.controller,
  }) : super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final List<double> _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = widget.controller //
      ..addListener(() {
        final _newPage = _pageController.page!.round();
        if (_currentPage != _newPage) {
          setState(() => _currentPage = _newPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: _heights[0], end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView(
        controller: _pageController,
        children: _sizeReportingChildren,
      ),
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap() //
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            //needed, so that parent won't impose its constraints on the children, thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) =>
                  setState(() => _heights[index] = size.height),
              child: child,
            ),
          ),
        ),
      )
      .values
      .toList();
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget>
    with AutomaticKeepAliveClientMixin {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size!);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
