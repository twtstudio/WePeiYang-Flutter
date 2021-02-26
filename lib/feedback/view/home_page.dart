import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/color_util.dart';
import 'package:wei_pei_yang_demo/feedback/util/screen_util.dart';
import 'package:wei_pei_yang_demo/feedback/view/components/post_card.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';

class FeedbackHomePage extends StatefulWidget {
  @override
  _FeedbackHomePageState createState() => _FeedbackHomePageState();
}

class _FeedbackHomePageState extends State<FeedbackHomePage> {
  int currentPage = 1, totalPage = 1;

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  _onRefresh() async {
    currentPage = 1;
    Provider.of<FeedbackNotifier>(context, listen: false).clearTagList();
    await Provider.of<FeedbackNotifier>(context, listen: false).getTags();
    Provider.of<FeedbackNotifier>(context, listen: false).clearHomePostList();
    await Provider.of<FeedbackNotifier>(context, listen: false)
        .getPosts('', currentPage);
    totalPage =
        Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (currentPage != totalPage) {
      currentPage++;
      await Provider.of<FeedbackNotifier>(context, listen: false)
          .getPosts('', currentPage);
      totalPage =
          Provider.of<FeedbackNotifier>(context, listen: false).homeTotalPage;
      _refreshController.loadComplete();
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    Provider.of<FeedbackNotifier>(context, listen: false).getMyUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _refreshController,
              header: ClassicHeader(),
              enablePullDown: true,
              onRefresh: _onRefresh,
              footer: ClassicFooter(),
              enablePullUp: true,
              onLoading: _onLoading,
              child: CustomScrollView(
                slivers: [
                  /// Header.
                  SliverPersistentHeader(
                    delegate: HomeHeaderDelegate(
                      child: Padding(
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
                                        borderRadius:
                                            BorderRadius.circular(1080),
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
                                        await _refreshController
                                            .requestRefresh();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              color: ColorUtil.mainColor,
                              icon: Icon(
                                Icons.person_outlined,
                              ),
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
                    ),
                    pinned: false,
                    // TODO: Opacity issue here.
                    floating: false,
                  ),

                  /// The list of posts.
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        print(index);
                        return notifier.homePostList[index].topImgUrl != '' &&
                                notifier.homePostList[index].topImgUrl != null
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
                                  print('like!');
                                  notifier.homePostHitLike(
                                      index,
                                      notifier.homePostList[index].id,
                                      notifier.myUserId);
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
                                  print('like!');
                                  notifier.homePostHitLike(
                                      index,
                                      notifier.homePostList[index].id,
                                      notifier.myUserId);
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
