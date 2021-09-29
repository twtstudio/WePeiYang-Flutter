import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/detail_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

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
    Provider.of<FeedbackNotifier>(context, listen: false).initHomePostList(
      (page) {
        setState(() {
          totalPage = page;
          status = FeedbackHomePageStatus.idle;
          _refreshController.refreshCompleted();
        });
      },
      () {
        setState(() {
          status = FeedbackHomePageStatus.error;
        });
      },
    );
  }

  _onLoading() {
    if (currentPage != totalPage) {
      currentPage++;
      FeedbackService.getPosts(
        tagId: '',
        page: currentPage,
        onSuccess: (list, page) {
          totalPage = page;
          Provider.of<FeedbackNotifier>(context, listen: false)
              .addHomePosts(list);
          _refreshController.loadComplete();
        },
        onFailure: (_) {
          _refreshController.loadFailed();
        },
      );
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    currentPage = 1;
    status = FeedbackHomePageStatus.loading;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<FeedbackNotifier>(context, listen: false)
          .initHomePostList(
        (page) {
          if (mounted) {
            setState(() {
              totalPage = page;
              status = FeedbackHomePageStatus.idle;
            });
          }
        },
        () {
          if (mounted) {
            setState(() {
              status = FeedbackHomePageStatus.error;
            });
          }
        },
      );
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<MessageProvider>(context, listen: false)
          .refreshFeedbackCount();
    });
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
      body: DefaultTextStyle(
        style: FontManager.YaHeiRegular,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: WePeiYangApp.paddingTop),
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
                                          hintText: S.current.feedback_search,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(1080),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          fillColor: ColorUtil
                                              .searchBarBackgroundColor,
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
                                  icon: FeedbackBadgeWidget(
                                    type: FeedbackMessageType.home,
                                    child: Image.asset(
                                        'lib/feedback/assets/img/profile.png'),
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

                          /// The list of posts.
                          if (status == FeedbackHomePageStatus.idle)
                            MediaQuery.removePadding(
                              removeTop: true,
                              context: context,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
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
                                            FeedbackService.postHitLike(
                                              id: notifier
                                                  .homePostList[index].id,
                                              isLiked: notifier
                                                  .homePostList[index].isLiked,
                                              onSuccess: () {
                                                notifier
                                                    .changeHomePostLikeState(
                                                        index);
                                              },
                                              onFailure: (e) {
                                                ToastProvider.error(e.error.toString());
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
                                            FeedbackService.postHitLike(
                                              id: notifier
                                                  .homePostList[index].id,
                                              isLiked: notifier
                                                  .homePostList[index].isLiked,
                                              onSuccess: () {
                                                notifier
                                                    .changeHomePostLikeState(
                                                        index);
                                              },
                                              onFailure: (e) {
                                                ToastProvider.error(e.error.toString());
                                              },
                                            );
                                          },
                                        );
                                },
                                itemCount: notifier.homePostList.length,
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (status == FeedbackHomePageStatus.loading)
              Positioned(
                child: Loading(),
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
              ),
            if (status == FeedbackHomePageStatus.error)
              Positioned(
                child: HomeErrorContainer(_onRefresh),
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
              ),
          ],
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
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class HomeErrorContainer extends StatelessWidget {
  final void Function() onPressed;

  HomeErrorContainer(this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'lib/feedback/assets/img/error.png',
              height: 192,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            S.current.feedback_error,
            style: FontManager.YaHeiRegular.copyWith(
              color: ColorUtil.lightTextColor,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            child: Icon(Icons.refresh),
            heroTag: 'error_btn',
            backgroundColor: ColorUtil.mainColor,
            onPressed: onPressed,
            mini: true,
          ),
        ],
      ),
    );
  }
}
