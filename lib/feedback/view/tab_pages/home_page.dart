import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart';
import 'package:we_pei_yang_flutter/feedback/view/tab_pages/pages/game_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';

class FeedbackHomePage extends StatefulWidget {
  FeedbackHomePage({Key key}) : super(key: key);

  @override
  FeedbackHomePageState createState() => FeedbackHomePageState();
}

class FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  FbHomeListModel _listProvider;
  FbTagsProvider _tagsProvider;
  TabController _tabController;
  double _tabPaddingWidth = 0;
  List<double> _offsets = [2, 2, 2];

  bool _lakeIsLoaded, _feedbackIsLoaded;

  ///第几个tab
  int _swap;

  //请求type
  List swapLister = [2, 0, 1, 3];

  ///根据tab的index得到对应type

  final ScrollController _controller1 = ScrollController();
  final ScrollController _controller2 = ScrollController();
  final ScrollController _controller3 = ScrollController();
  ScrollController _controller = ScrollController();

  RefreshController _refreshController1 =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController3 =
      RefreshController(initialRefresh: false);
  RefreshController _refreshController;

  Widget _mixedListView;
  Widget _lakeListView;
  Widget _feedbackListView;

  onRefresh([AnimationController controller]) {
    FeedbackService.getToken(onResult: (_) {
      _tagsProvider.initDepartments();
      _listProvider.initPostList(swapLister[_swap], success: () {
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
        swapLister[_swap],
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
    _swap = 0;
    _lakeIsLoaded = false;
    _feedbackIsLoaded = false;
    _refreshController = _refreshController1;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _listProvider = Provider.of<FbHomeListModel>(context, listen: false);
      _tagsProvider = Provider.of<FbTagsProvider>(context, listen: false);
      _listProvider.checkTokenAndGetPostList(_tagsProvider, 2, failure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        //判断TabBar是否切换
        print(_tabController.index);
        switch (_tabController.index) {
          case 0:
            {
              _controller1.jumpTo(_offsets[0]);
              setState(() {
                _refreshController = _refreshController1;
                _controller = _controller1;
                _swap = 0;
              });
            }
            break;
          case 1:
            {
              _controller2.jumpTo(_offsets[1]);
              setState(() {
                _refreshController = _refreshController2;
                _controller = _controller2;
                _swap = 1;
                if (_lakeIsLoaded == false) {
                  _controller2.animateTo(-85,
                      curve: Curves.decelerate,
                      duration: Duration(milliseconds: 500));
                  _lakeIsLoaded = true;
                }
              });
            }
            break;
          case 2:
            {
              _controller3.jumpTo(_offsets[2]);
              setState(() {
                _refreshController = _refreshController3;
                _controller = _controller3;
                _swap = 2;
              });
              if (_feedbackIsLoaded == false) {
                _controller3.animateTo(-85,
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 500));
                _feedbackIsLoaded = true;
              }
            }
            break;
          default:
            break;
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(390, 844),
        orientation: Orientation.portrait);
    _tabPaddingWidth = MediaQuery.of(context).size.width / 30;
    var searchBar = SearchBar(
      tapField: () => Navigator.pushNamed(context, FeedbackRouter.search),
    );
    _offsets[0] = _controller1.hasClients ? _controller1.offset : 2;
    _offsets[1] = _controller2.hasClients ? _controller2.offset : 2;
    _offsets[2] = _controller3.hasClients ? _controller3.offset : 2;
    _mixedListView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController1,
        header: ClassicHeader(),
        enablePullDown: true,
        onRefresh: onRefresh,
        footer: ClassicFooter(),
        enablePullUp: !model.isLastPage,
        onLoading: _onLoading,
        child: ListView.builder(
          controller: _controller1,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: model.allList[swapLister[0]].length,
          itemBuilder: (context, index) {
            final post = model.allList[swapLister[0]][index];
            return PostCard.simple(post, key: ValueKey(post.id));
          },
        ),
      );
    });
    _lakeListView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController2,
        header: ClassicHeader(),
        enablePullDown: true,
        onRefresh: onRefresh,
        footer: ClassicFooter(),
        enablePullUp: !model.isLastPage,
        onLoading: _onLoading,
        child: ListView.builder(
          controller: _controller2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: model.allList[swapLister[1]].length,
          itemBuilder: (context, index) {
            final post = model.allList[swapLister[1]][index];
            return PostCard.simple(post, key: ValueKey(post.id));
          },
        ),
      );
    });
    _feedbackListView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController3,
        header: ClassicHeader(),
        enablePullDown: true,
        onRefresh: onRefresh,
        footer: ClassicFooter(),
        enablePullUp: !model.isLastPage,
        onLoading: _onLoading,
        child: ListView.builder(
          controller: _controller3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: model.allList[swapLister[2]].length,
          itemBuilder: (context, index) {
            final post = model.allList[swapLister[2]][index];
            return PostCard.simple(post, key: ValueKey(post.id));
          },
        ),
      );
    });

    var _mixedBody = Consumer<FbHomeStatusNotifier>(
      builder: (_, status, __) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: _mixedListView,
            ),
            if (status.isLoading) Loading(),
            if (status.isError) HomeErrorContainer(onRefresh),
          ],
        );
      },
    );

    var _lakeBody = Consumer<FbHomeStatusNotifier>(
      builder: (_, status, __) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: _lakeListView,
            ),
            if (status.isLoading) Loading(),
            if (status.isError) HomeErrorContainer(onRefresh),
          ],
        );
      },
    );

    var _feedbackBody = Consumer<FbHomeStatusNotifier>(
      builder: (_, status, __) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: _feedbackListView,
            ),
            if (status.isLoading) Loading(),
            if (status.isError) HomeErrorContainer(onRefresh),
          ],
        );
      },
    );

    return SafeArea(
      child: NestedScrollView(
          physics: BouncingScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                toolbarHeight: 48,
                backgroundColor: ColorUtil.white253,
                titleSpacing: 0,
                leading: IconButton(
                    icon: ImageIcon(
                        AssetImage("assets/images/lake_butt_icons/box.png"),
                        size: 28,
                        color: ColorUtil.boldTag54),
                    onPressed: () =>
                        Navigator.pushNamed(context, FeedbackRouter.profile)),
                title: searchBar,
                actions: [
                  Hero(
                    tag: "addNewPost",
                    child: InkWell(
                        highlightColor: Colors.transparent,
                        child: Container(
                            height: 27,
                            width: 27,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/lake_butt_icons/add_post.png")))),
                        onTap: () {
                          Navigator.pushNamed(context, FeedbackRouter.newPost);
                        }),
                  ),
                  SizedBox(width: 15)
                ],
              ),
              SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: HomeHeaderDelegate(
                    child: PreferredSize(
                      preferredSize: Size(double.infinity, 30),
                      child: Container(
                        color: ColorUtil.white253,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 4),
                              Expanded(
                                child: TabBar(
                                    indicatorPadding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.zero,
                                    isScrollable: true,
                                    physics: BouncingScrollPhysics(),
                                    controller: _tabController,
                                    labelColor: Color(0xff303c66),
                                    labelStyle: TextUtil
                                        .base.black2A.w700.NotoSansSC
                                        .sp(18),
                                    unselectedLabelColor:
                                        ColorUtil.lightTextColor,
                                    unselectedLabelStyle: TextUtil
                                        .base.grey6C.w600.NotoSansSC
                                        .sp(18),
                                    indicator: CustomIndicator(
                                        borderSide: BorderSide(
                                            color: ColorUtil.mainColor,
                                            width: 2)),
                                    tabs: [
                                      Tab(
                                          child: Row(
                                        children: [
                                          SizedBox(width: _tabPaddingWidth),
                                          Text("全部"),
                                          SizedBox(width: _tabPaddingWidth),
                                        ],
                                      )),
                                      Tab(
                                          child: Row(
                                        children: [
                                          SizedBox(width: _tabPaddingWidth),
                                          Text("湖底"),
                                          SizedBox(width: _tabPaddingWidth),
                                        ],
                                      )),
                                      Tab(
                                          child: Row(
                                        children: [
                                          SizedBox(width: _tabPaddingWidth),
                                          Text("校务"),
                                          SizedBox(width: _tabPaddingWidth),
                                        ],
                                      )),
                                      Tab(
                                        child: Row(
                                          children: [
                                            SizedBox(width: _tabPaddingWidth),
                                            Text("游戏"),
                                            Container(
                                              width: 13,
                                              height: 13,
                                              padding: EdgeInsets.only(left: 2.2),
                                              decoration: BoxDecoration(
                                                color: ColorUtil.boldTag54,
                                                borderRadius: BorderRadius.all(Radius.circular(2.0))
                                              ),
                                              child: Text("荐",style: TextUtil.base.w400.white.NotoSansSC.sp(9),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                              PopupMenuButton(
                                padding: EdgeInsets.zero,
                                tooltip: "排序方式",
                                child: Image(
                                  height: ScreenUtil().setHeight(25),
                                  width: ScreenUtil().setWidth(25),
                                  image: AssetImage(
                                      "assets/images/lake_butt_icons/menu.png"),
                                ),
                                //1-->时间排序，2-->动态排序
                                onSelected: (value) {},
                                itemBuilder: (context) {
                                  return <PopupMenuEntry<int>>[
                                    CheckedPopupMenuItem<int>(
                                      value: 1,
                                      child: Text(
                                        '时间排序',
                                        style: TextStyle(
                                            color: ColorUtil.lightTextColor),
                                      ),
                                    ),
                                    CheckedPopupMenuItem<int>(
                                      value: 2,
                                      child: Text('动态排序'),
                                    ),
                                  ];
                                },
                              ),
                              SizedBox(width: 17)
                            ]),
                      ),
                    ),
                    //backgroundColor: ColorUtil.backgroundColor,
                    //elevation: 0,
                  ))
            ];
          },
          body: ExtendedTabBarView(
            controller: _tabController,
            cacheExtent: 2,
            children: <Widget>[
              _mixedBody,
              _lakeBody,
              _feedbackBody,
              GamePage(),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void listToTop() {
    if (_controller.offset > 1500) _controller.jumpTo(1500);
    _controller.animateTo(-85,
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
  double get maxExtent => 30;

  @override
  double get minExtent => 30;

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
