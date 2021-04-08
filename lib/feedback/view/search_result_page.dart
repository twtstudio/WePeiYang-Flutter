import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/view/home_page.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/loading.dart';

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
    getPosts(
      tagId: tagId,
      page: currentPage,
      keyword: keyword,
      onSuccess: (list, page) {
        totalPage = page;
        Provider.of<FeedbackNotifier>(context, listen: false).addHomePosts(list);
        _refreshController.refreshCompleted();
      },
      onFailure: () {
        ToastProvider.error('校务专区获取帖子失败, 请刷新');
        _refreshController.refreshFailed();
      },
    );
  }

  _onLoading() {
    if (currentPage != totalPage) {
      currentPage++;
      getPosts(
        tagId: tagId,
        page: currentPage,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          Provider.of<FeedbackNotifier>(context, listen: false).addHomePosts(list);
          _refreshController.refreshCompleted();
        },
        onFailure: () {
          ToastProvider.error('校务专区获取帖子失败, 请刷新');
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
    Provider.of<FeedbackNotifier>(context, listen: false).clearHomePostList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPosts(
        tagId: tagId,
        page: currentPage,
        keyword: keyword,
        onSuccess: (list, page) {
          totalPage = page;
          Provider.of<FeedbackNotifier>(context, listen: false).addHomePosts(list);
          setState(() {
            status = SearchPageStatus.idle;
          });
        },
        onFailure: () {
          ToastProvider.error('校务专区获取帖子失败, 请刷新');
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(tagId);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
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
        ),
        body: Column(
          children: [
            if (status == SearchPageStatus.loading)
              Expanded(child: Center(child: Loading())),
            if (status == SearchPageStatus.idle)
              if (Provider.of<FeedbackNotifier>(context, listen: false)
                      .homePostList
                      .length ==
                  0)
                Expanded(
                  child: Center(
                    child: Text(
                      '未检索到相关问题',
                      style: TextStyle(
                        color: ColorUtil.lightTextColor,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Consumer<FeedbackNotifier>(
                    builder: (BuildContext context, notifier, Widget child) {
                      return SmartRefresher(
                        controller: _refreshController,
                        header: ClassicHeader(),
                        enablePullDown: true,
                        onRefresh: _onRefresh,
                        footer: ClassicFooter(),
                        enablePullUp: true,
                        onLoading: _onLoading,
                        child: CustomScrollView(
                          slivers: [
                            /// The list of posts.
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  print(notifier.homePostList[index].title);
                                  return notifier.homePostList[index]
                                                  .topImgUrl !=
                                              '' &&
                                          notifier.homePostList[index]
                                                  .topImgUrl !=
                                              null
                                      ? PostCard.image(
                                          notifier.homePostList[index],
                                          onContentPressed: () {
                                            Navigator.pushNamed(
                                                context, FeedbackRouter.detail,
                                                arguments: DetailPageArgs(
                                                    notifier
                                                        .homePostList[index],
                                                    index,
                                                    PostOrigin.home));
                                          },
                                          onLikePressed: () {
                                            postHitLike(
                                              id: notifier.homePostList[index].id,
                                              isLiked: notifier.homePostList[index].isLiked,
                                              onSuccess: () {
                                                notifier.changeHomePostLikeState(index);
                                              },
                                              onFailure: () {
                                                ToastProvider.error('校务专区点赞失败，请重试');
                                              },
                                            );
                                          },
                                        )
                                      : PostCard(
                                          notifier.homePostList[index],
                                          onContentPressed: () {
                                            Navigator.pushNamed(
                                                context, FeedbackRouter.detail,
                                                arguments: DetailPageArgs(
                                                    notifier
                                                        .homePostList[index],
                                                    index,
                                                    PostOrigin.home));
                                          },
                                          onLikePressed: () {
                                            postHitLike(
                                              id: notifier.homePostList[index].id,
                                              isLiked: notifier.homePostList[index].isLiked,
                                              onSuccess: () {
                                                notifier.changeHomePostLikeState(index);
                                              },
                                              onFailure: () {
                                                ToastProvider.error('校务专区点赞失败，请重试');
                                              },
                                            );
                                          },
                                        );
                                },
                                childCount: notifier.homePostList.length,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
