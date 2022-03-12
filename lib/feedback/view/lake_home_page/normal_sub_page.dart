import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class NSubPage extends StatefulWidget {
  final int index;

  const NSubPage({Key key, this.index}) : super(key: key);

  @override
  _NSubPageState createState() => _NSubPageState(this.index);
}

class _NSubPageState extends State<NSubPage> {
  int index;
  FbHomeListModel _listProvider;
  FbDepartmentsProvider _tagsProvider;
  FbHotTagsProvider _hotTagsProvider;
  _NSubPageState(this.index);

  List swapLister = [0, 1, 2, 3];
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  final ScrollController _controller = ScrollController();

  getHotList() {
    _hotTagsProvider.initHotTags(success: () {
      _refreshController.refreshCompleted();
    }, failure: (e) {
      ToastProvider.error(e.error.toString());
      _refreshController.refreshFailed();
    });
  }

  getRecTag() {
    _hotTagsProvider.initRecTag(
        success: () {},
        failure: (e) {
          ToastProvider.error(e.error.toString());
        });
  }

  onRefresh([AnimationController controller]) {
    FeedbackService.getToken(onResult: (_) {
      _tagsProvider.initDepartments();
      getRecTag();
      if (index == 1) getHotList();
      _listProvider.initPostList(swapLister[index], success: () {
        controller?.dispose();
        _refreshController.refreshCompleted();
      }, failure: (_) {
        controller?.stop();
        _refreshController.refreshFailed();
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
      controller?.stop();
      _refreshController.refreshFailed();
    });
  }

  _onLoading() {
    if (_listProvider.isLastPage) {
      _refreshController.loadNoData();
    } else {
      _listProvider.getNextPage(
        swapLister[index],
        success: () {
          _refreshController.loadComplete();
        },
        failure: (e) {
          _refreshController.loadFailed();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FbHomeListModel>(builder: (_, model, __) {
      return NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController,
          header: ClassicHeader(
            completeDuration: Duration(milliseconds: 300),
          ),
          enablePullDown: true,
          onRefresh: onRefresh,
          footer: ClassicFooter(),
          enablePullUp: !model.isLastPage,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: model.allList[swapLister[index]].length,
            itemBuilder: (context, index) {
              final post = model.allList[swapLister[index]][index];
              return PostCard.simple(post, key: ValueKey(post.id));
            },
          ),
        ),
        // onNotification: (ScrollNotification scrollInfo) =>
        //     _onScrollNotification(scrollInfo),
      );
    });
  }
}