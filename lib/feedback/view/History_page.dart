import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/refresh_header.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';
import '../../commons/themes/template/wpy_theme_data.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/util/text_util.dart';
import '../../commons/util/toast_provider.dart';
import '../network/feedback_service.dart';
import 'collection_page.dart';
import 'components/post_card.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

enum _CurrentTab {
  myPosts,
  myHistory,
}

class _HistoryPageState extends State<HistoryPage> {
  ValueNotifier<_CurrentTab> _currentTab = ValueNotifier(_CurrentTab.myHistory);
  late final PageController _tabController;
  List<Post> _historyList = [];
  var _refreshController = RefreshController(initialRefresh: true);
  bool tap = false;
  int currentPage = 1;

  _getMyHistory({Function(List<Post>)? onSuccess, Function? onFail}) {
    FeedbackService.getHistoryPosts(
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
    _getMyHistory(onSuccess: (list) {
      _historyList = list;
      _refreshController.refreshCompleted();
    }, onFail: () {
      _refreshController.refreshFailed();
    });
  }

//下拉加载
  _onLoading() {
    currentPage++;
    _getMyHistory(onSuccess: (list) {
      if (list.length == 0) {
        _refreshController.loadNoData();
        currentPage--;
      } else {
        _historyList.addAll(list);
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
    _getMyHistory();
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
        Widget history = PostCardNormal(
          _historyList[index],
        );
        return history;
      },
      itemCount: _historyList.length,
    ));
    var list = ExpandablePageView(
      controller: _tabController,
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Builder(
              key: ValueKey(_historyList.length.isZero),
              builder: (context) {
                if (_historyList.length.isZero) {
                  return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text("暂无浏览记录",
                          style: TextUtil.base.oldThirdAction(context)));
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
          backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
              size: 20.w,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "历史浏览",
            style: TextUtil.base.NotoSansSC.label(context).w600.sp(18),
          ),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Container(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryBackgroundColor),
              child: list),
        )
      ],
    );

    return Container(
      //改背景色用
      color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      child: SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController,
        header: RefreshHeader(context),
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