import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';

class FeedbackHomePage extends StatefulWidget {
  FeedbackHomePage({Key key}) : super(key: key);

  @override
  FeedbackHomePageState createState() => FeedbackHomePageState();
}

class FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin {
  FbHomeListModel _listProvider;
  FbTagsProvider _tagsProvider;
  TabController _tabController;
  double tabPaddingWidth = 0;

  final typeList = [2, 0, 1, 2];

  ///根据tab的index得到对应type

  final ScrollController controller = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  onRefresh([AnimationController controller]) {
    FeedbackService.getToken(onResult: (_) {
      _tagsProvider.initDepartments();
      _listProvider.initPostList(typeList[0], success: () {
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

  _onLoading({int type = 2}) {
    if (_listProvider.isLastPage) {
      _refreshController.loadNoData();
    } else {
      _listProvider.getNextPage(
        type,
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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _listProvider = Provider.of<FbHomeListModel>(context, listen: false);
      _tagsProvider = Provider.of<FbTagsProvider>(context, listen: false);
      _listProvider.checkTokenAndGetPostList(typeList[0], _tagsProvider,
          failure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    tabPaddingWidth = MediaQuery.of(context).size.width / 30;
    var searchBar = SearchBar(
      tapField: () => Navigator.pushNamed(context, FeedbackRouter.search),
    );

    var listView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController,
        header: ClassicHeader(),
        enablePullDown: true,
        onRefresh: onRefresh,
        footer: ClassicFooter(),
        enablePullUp: !model.isLastPage,
        onLoading: _onLoading,
        child: ListView.builder(
          controller: controller,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: model.homeList.length,
          itemBuilder: (context, index) {
            final post = model.homeList[index];
            if (index == 0) {
              return Column(
                children: [
                  // searchBar,
                  // SearchTypeSwitchBar(
                  //     controller: _refreshController, provider: _listProvider),
                  PostCard.simple(post, key: ValueKey(post.id))
                ],
              );
            }
            return PostCard.simple(post, key: ValueKey(post.id));
          },
        ),
      );
    });

    var body = Consumer<FbHomeStatusNotifier>(
      builder: (_, status, __) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: listView,
            ),
            if (status.isLoading) Loading(),
            if (status.isError) HomeErrorContainer(onRefresh),
          ],
        );
      },
    );

    return SafeArea(
      child: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: NestedScrollView(
          physics: BouncingScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverPersistentHeader(
                    delegate: HomeHeaderDelegate(
                        //islucency: true,
                        child: PreferredSize(
                            preferredSize: Size.fromHeight(60),
                            child: Row(
                              children: [
                                SizedBox(width: 5),
                                IconButton(
                                    icon: Icon(Icons.all_inbox,
                                        color: ColorUtil.mainColor),
                                    onPressed: () => Navigator.pushNamed(
                                        context, FeedbackRouter.profile)),
                                Expanded(child: searchBar),
                                Hero(
                                  tag: "addNewPost",
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                ColorUtil.mainColor),
                                        shape: MaterialStateProperty.all(
                                            CircleBorder(
                                                side: BorderSide(
                                          width: 0.0,
                                          style: BorderStyle.none,
                                        ))), //圆角弧度
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, FeedbackRouter.newPost);
                                      },
                                      child: Icon(Icons.add),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15)
                              ],
                            )))),
                SliverPersistentHeader(
                    floating: true,
                    pinned: true,
                    delegate: HomeHeaderDelegate(
                      //islucency: false,
                      child: PreferredSize(
                        preferredSize: Size(double.infinity, 30),
                        child: Container(
                          color: ColorUtil.backgroundColor,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TabBar(
                                      indicatorPadding: EdgeInsets.zero,
                                      labelPadding: EdgeInsets.zero,
                                      isScrollable: true,
                                      physics: BouncingScrollPhysics(),
                                      controller: _tabController,
                                      labelColor: Color(0xff303c66),
                                      labelStyle:
                                          FontManager.YaHeiRegular.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff303c66),
                                        fontSize: 16,
                                      ),
                                      unselectedLabelColor:
                                          ColorUtil.lightTextColor,
                                      unselectedLabelStyle:
                                          FontManager.YaHeiRegular.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff303c66),
                                        fontSize: 16,
                                      ),
                                      indicator: CustomIndicator(
                                          borderSide: BorderSide(
                                              color: ColorUtil.mainColor,
                                              width: 2)),
                                      tabs: [
                                        Tab(
                                            child: Row(
                                          children: [
                                            SizedBox(width: tabPaddingWidth),
                                            Text("全部"),
                                            SizedBox(width: tabPaddingWidth),
                                          ],
                                        )),
                                        Tab(
                                            child: Row(
                                          children: [
                                            SizedBox(width: tabPaddingWidth),
                                            Text("湖底"),
                                            SizedBox(width: tabPaddingWidth),
                                          ],
                                        )),
                                        Tab(
                                            child: Row(
                                          children: [
                                            SizedBox(width: tabPaddingWidth),
                                            Text("校务"),
                                            SizedBox(width: tabPaddingWidth),
                                          ],
                                        )),
                                        Tab(
                                          child: Row(
                                            children: [
                                              SizedBox(width: tabPaddingWidth),
                                              Text("游戏"),
                                              Icon(
                                                  Icons
                                                      .assignment_turned_in_rounded,
                                                  size: 14)
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.add_to_photos_sharp,
                                      color: ColorUtil.mainColor,
                                    ),
                                    onPressed: () {}),
                                SizedBox(width: 8)
                              ]),
                        ),
                      ),
                      //backgroundColor: ColorUtil.backgroundColor,
                      //elevation: 0,
                    ))
              ];
            },

            /// Click and jump to NewPostPage.
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: ColorUtil.mainColor,
            //   child: Icon(Icons.add),
            //   onPressed: () {
            //     Navigator.pushNamed(context, FeedbackRouter.newPost);
            //   },
            // ),
            body: TabBarView(
              children: <Widget>[body, Text("湖底"), Text("校务"), Text("呦西")],
            )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void listToTop() {
    if (controller.offset > 1500) controller.jumpTo(1500);
    controller.animateTo(-85,
        duration: Duration(milliseconds: 1000), curve: Curves.fastOutSlowIn);
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

class HomeErrorContainer extends StatefulWidget {
  final void Function(AnimationController) onPressed;

  HomeErrorContainer(this.onPressed);

  @override
  _HomeErrorContainerState createState() => _HomeErrorContainerState();
}

class _HomeErrorContainerState extends State<HomeErrorContainer>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    var errorImg = Image.asset(
      'lib/feedback/assets/img/error.png',
      height: 192,
      fit: BoxFit.cover,
    );

    var errorText = Text(
      S.current.feedback_error,
      style: FontManager.YaHeiRegular.copyWith(
        color: ColorUtil.lightTextColor,
      ),
    );

    var retryButton = FloatingActionButton(
      child: RotationTransition(
        alignment: Alignment.center,
        turns: animation,
        child: Icon(Icons.refresh),
      ),
      heroTag: 'error_btn',
      backgroundColor: ColorUtil.mainColor,
      onPressed: () {
        if (!controller.isAnimating) {
          controller.repeat();
          widget.onPressed?.call(controller);
        }
      },
      mini: true,
    );

    var paddingBox = SizedBox(height: 16);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          errorImg,
          paddingBox,
          errorText,
          paddingBox,
          retryButton,
        ],
      ),
    );
  }
}
