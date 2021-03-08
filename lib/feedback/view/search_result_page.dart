import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
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
    Provider.of<FeedbackNotifier>(context, listen: false)
        .getPosts(tagId, currentPage, keyword: keyword, onSuccess: () {
      totalPage =
          Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
      _refreshController.refreshCompleted();
    });
  }

  _onLoading() {
    if (currentPage != totalPage) {
      currentPage++;
      Provider.of<FeedbackNotifier>(context, listen: false)
          .getPosts(tagId, currentPage, keyword: keyword, onSuccess: () {
        totalPage =
            Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
        _refreshController.loadComplete();
      });
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    status = SearchPageStatus.loading;
    currentPage = 1;
    print(tagId);
    print('init');
    Provider.of<FeedbackNotifier>(context, listen: false).clearHomePostList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false)
          .getPosts(tagId, currentPage, keyword: keyword, onSuccess: () {
        totalPage =
            Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
        setState(() {
          status = SearchPageStatus.idle;
        });
      });
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
                                return notifier.homePostList[index].topImgUrl !=
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
                                                  notifier.homePostList[index],
                                                  index,
                                                  PostOrigin.home));
                                        },
                                        onLikePressed: () {
                                          notifier.homePostHitLike(index,
                                              notifier.homePostList[index].id);
                                        },
                                      )
                                    : PostCard(
                                        notifier.homePostList[index],
                                        onContentPressed: () {
                                          Navigator.pushNamed(
                                              context, FeedbackRouter.detail,
                                              arguments: DetailPageArgs(
                                                  notifier.homePostList[index],
                                                  index,
                                                  PostOrigin.home));
                                        },
                                        onLikePressed: () {
                                          notifier.homePostHitLike(index,
                                              notifier.homePostList[index].id);
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
