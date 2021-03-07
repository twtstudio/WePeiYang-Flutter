import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/post_card.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/loading.dart';

class FeedbackHomePage extends StatefulWidget {
  @override
  _FeedbackHomePageState createState() => _FeedbackHomePageState();
}

enum FeedbackHomePageStatus {
  loading,
  idle,
  error,
}

class _FeedbackHomePageState extends State<FeedbackHomePage> {
  int currentPage = 1, totalPage = 1;
  FeedbackHomePageStatus status;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _onRefresh() {
    setState(() {
      status = FeedbackHomePageStatus.loading;
    });
    currentPage = 1;
    Provider.of<FeedbackNotifier>(context, listen: false).initHomePostList(() {
      setState(() {
        status = FeedbackHomePageStatus.idle;
      });
    });
    totalPage =
        Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
    _refreshController.refreshCompleted();
  }

  // TODO: Add onError handler here.
  _onLoading() {
    if (currentPage != totalPage) {
      currentPage++;
      Provider.of<FeedbackNotifier>(context, listen: false)
          .getPosts('', currentPage, onSuccess: () {
        totalPage =
            Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
        _refreshController.loadComplete();
      }, onError: () {
        _refreshController.loadFailed();
      });
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    currentPage = 1;
    status = FeedbackHomePageStatus.loading;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FeedbackNotifier>(context, listen: false)
          .initHomePostList(() {
        setState(() {
          status = FeedbackHomePageStatus.idle;
        });
      });
      totalPage =
          Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('!!!!!!setState!!!!!!');
    return Scaffold(
      /// Click and jump to NewPostPage.
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorUtil.mainColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, FeedbackRouter.newPost);
        },
      ),
      body: Padding(
        padding: EdgeInsets.only(top: ScreenUtil.paddingTop),
        child: Consumer<FeedbackNotifier>(
          builder: (BuildContext context, notifier, Widget child) {
            return SmartRefresher(
              physics: BouncingScrollPhysics(),
              controller: _refreshController,
              header: ClassicHeader(),
              enablePullDown: true,
              onRefresh: _onRefresh,
              footer: ClassicFooter(),
              enablePullUp: currentPage != totalPage,
              onLoading: _onLoading,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(1080),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: '搜索问题',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(1080),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    fillColor:
                                        ColorUtil.searchBarBackgroundColor,
                                    filled: true,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: ColorUtil.mainColor,
                                    ),
                                  ),
                                  enabled: false,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, FeedbackRouter.search)
                                      .then((value) async {
                                    if (value == true) {
                                      notifier.clearHomePostList();
                                      _onRefresh();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            color: ColorUtil.mainColor,
                            icon: Image.asset(
                                'lib/feedback/assets/img/profile.png'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                FeedbackRouter.profile,
                              );
                            },
                          )
                        ],
                      ),
                    ),

                    if (status == FeedbackHomePageStatus.loading)
                      Container(
                        padding: EdgeInsets.only(
                            top: ScreenUtil.screenHeight / 2 -
                                ScreenUtil.paddingTop -
                                AppBar().preferredSize.height),
                        child: Loading(),
                      ),

                    /// The list of posts.
                    if (status == FeedbackHomePageStatus.idle)
                      MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return notifier.homePostList[index].topImgUrl !=
                                        '' &&
                                    notifier.homePostList[index].topImgUrl !=
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
                          itemCount: notifier.homePostList.length,
                        ),
                      )
                  ],
                ),
              ),
              // child: CustomScrollView(
              //   slivers: [
              //
              //     /// Header.
              //     SliverPersistentHeader(
              //       delegate: HomeHeaderDelegate(
              //           child:
              //       ),
              //       pinned: false,
              //       // TODO: Opacity issue here.
              //       floating: false,
              //     ),
              //
              //
              //   ],
              // ),
            );
          },
        ),
      ),
    );
  }
}

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  HomeHeaderDelegate({@required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => AppBar().preferredSize.height;

  @override
  double get minExtent => AppBar().preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
