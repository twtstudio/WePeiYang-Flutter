import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';

import 'components/post_card.dart';
import 'detail_page.dart';

class SearchResultPage extends StatefulWidget {
  final SearchResultPageArgs args;

  SearchResultPage(this.args);

  @override
  _SearchResultPageState createState() =>
      _SearchResultPageState(args.keyword, args.tagId, args.title);
}

class SearchResultPageArgs {
  final String keyword;
  final String tagId;
  final String title;

  SearchResultPageArgs(this.keyword, this.tagId, this.title);
}

enum SearchPageStatus {
  loading,
  idle,
  error,
}

class _SearchResultPageState extends State<SearchResultPage> {
  final String keyword;
  final String tagId;
  final String title;

  int currentPage = 1, totalPage = 1;
  SearchPageStatus status;

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  _SearchResultPageState(this.keyword, this.tagId, this.title);

  _onRefresh() {
    currentPage = 1;
    Provider.of<FeedbackNotifier>(context, listen: false).clearHomePostList();
    FeedbackService.getPosts(
      tagId: tagId,
      page: currentPage,
      keyword: keyword,
      onSuccess: (list, page) {
        totalPage = page;
        Provider.of<FeedbackNotifier>(context, listen: false)
            .addHomePosts(list);
        _refreshController.refreshCompleted();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        _refreshController.refreshFailed();
      },
    );
  }

  _onLoading() {
    if (currentPage != totalPage) {
      currentPage++;
      FeedbackService.getPosts(
        tagId: tagId,
        page: currentPage,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          Provider.of<FeedbackNotifier>(context, listen: false)
              .addHomePosts(list);
          _refreshController.loadComplete();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          _refreshController.loadFailed();
        },
      );
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    status = SearchPageStatus.loading;
    currentPage = 1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false).clearHomePostList();
      FeedbackService.getPosts(
        tagId: tagId,
        page: currentPage,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          Provider.of<FeedbackNotifier>(context, listen: false)
              .addHomePosts(list);
          setState(() {
            status = SearchPageStatus.idle;
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ColorUtil.mainColor,
        ),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorUtil.boldTextColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      primary: true,
    );

    Widget noPostPage = Center(
      child: Text(
        S.current.feedback_no_post,
        style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.lightTextColor,
        ),
      ),
    );

    Widget hasPostPage = Consumer<FeedbackNotifier>(
      builder: (BuildContext context, notifier, Widget child) {
        return SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(),
          enablePullDown: true,
          onRefresh: _onRefresh,
          footer: ClassicFooter(),
          enablePullUp: true,
          onLoading: _onLoading,
          child: ListView.builder(
            itemBuilder: (context, index) {
              Function goToDetailPage = () {
                Navigator.pushNamed(context, FeedbackRouter.detail,
                    arguments: DetailPageArgs(
                        notifier.homePostList[index], index, PostOrigin.home));
              };

              Function hitLike = () {
                FeedbackService.postHitLike(
                  id: notifier.homePostList[index].id,
                  isLiked: notifier.homePostList[index].isLiked,
                  onSuccess: () {
                    notifier.changeHomePostLikeState(index);
                  },
                  onFailure: (e) {
                    ToastProvider.error(e.error.toString());
                  },
                );
              };

              var postWithImage = PostCard.image(
                notifier.homePostList[index],
                onContentPressed: goToDetailPage,
                onLikePressed: hitLike,
              );

              var postWithoutImage = PostCard(
                notifier.homePostList[index],
                onContentPressed: goToDetailPage,
                onLikePressed: hitLike,
              );

              return notifier.homePostList[index].topImgUrl != '' &&
                  notifier.homePostList[index].topImgUrl != null
                  ? postWithImage
                  : postWithoutImage;
            },
            itemCount: notifier.homePostList.length,
          ),
        );
      },
    );

    Widget body;

    if (status == SearchPageStatus.loading) body = Center(child: Loading());
    if (status == SearchPageStatus.idle) if (Provider.of<FeedbackNotifier>(
        context,
        listen: false)
        .homePostList
        .length ==
        0)
      body = noPostPage;
    else
      body = hasPostPage;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
          appBar: appBar,
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: body,
          )),
    );
  }
}