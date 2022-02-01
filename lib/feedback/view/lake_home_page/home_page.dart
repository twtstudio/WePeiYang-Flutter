import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/hot_rank_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/game_page.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

import '../new_post_page.dart';
import '../search_result_page.dart';

class FeedbackHomePage extends StatefulWidget {
  FeedbackHomePage({Key key}) : super(key: key);

  @override
  FeedbackHomePageState createState() => FeedbackHomePageState();
}

class FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  FbHomeListModel _listProvider;
  FbTagsProvider _tagsProvider;
  FbHotTagsProvider _hotTagsProvider;
  TabController _tabController;
  double _tabPaddingWidth = 0;
  double _previousOffset = 0;
  List<double> _offsets = [2, 2, 2];

  bool _lakeIsLoaded, _feedbackIsLoaded, _initialRefresh;
  bool _tagsContainerCanAnimate,
      _tagsContainerBackgroundIsShow,
      _tagsWrapIsShow;
  double _tagsContainerBackgroundOpacity = 0;

  ///第几个tab,0,1,2,3
  int _swap;

  //请求type
  List swapLister = [2, 0, 1, 3];

  ///根据tab的index得到对应type

  final ScrollController _nestedController = ScrollController();

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

  final postTypeNotifier = ValueNotifier(PostType.lake);

  Widget _mixedListView;
  Widget _lakeListView;
  Widget _feedbackListView;
  Widget _departmentSelectionContainer;

  getHotList() {
    _hotTagsProvider.initHotTags(success: () {
      _refreshController.refreshCompleted();
    }, failure: (e) {
      ToastProvider.error(e.error.toString());
      _refreshController.refreshFailed();
    });
  }

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
    if (_swap == 1)
      getHotList();
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

  _onTapped() {
    _onOpen();
    if (_tagsContainerCanAnimate) {
      if (_tagsWrapIsShow == false)
        setState(() {
          _tagsWrapIsShow = true;
          _tagsContainerBackgroundIsShow = true;
          _tagsContainerBackgroundOpacity = 1.0;
        });
      else
        setState(() {
          _tagsContainerBackgroundOpacity = 0;
          _tagsWrapIsShow = false;
        });
    }
    _tagsContainerCanAnimate = false;
  }

  _offstageTheBackground() {
    _tagsContainerCanAnimate = true;
    if (_tagsContainerBackgroundOpacity < 1) {
      _tagsContainerBackgroundIsShow = false;
      _listProvider.justForGetConcentrate();
    }
  }

  bool scroll = false;

  _onClose() {
    if (!scroll &&
        _nestedController.offset !=
            _nestedController.position.maxScrollExtent) {
      scroll = true;
      _nestedController
          .animateTo(_nestedController.position.maxScrollExtent,
              duration: Duration(milliseconds: 160), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
    if (_refreshController.isRefresh) _refreshController.refreshCompleted();
  }

  _onOpen() {
    if (!scroll && _nestedController.offset != 0) {
      scroll = true;
      _nestedController
          .animateTo(0,
              duration: Duration(milliseconds: 160), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == 0) _onOpen();
    if ((scrollInfo.metrics.pixels - _previousOffset).abs() >= 20 &&
        scrollInfo.metrics.pixels >= 10 &&
        scrollInfo.metrics.pixels <= scrollInfo.metrics.maxScrollExtent - 10) {
      if (scrollInfo.metrics.pixels <= _previousOffset)
        _onOpen();
      else
        _onClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
  }

  ///微口令的识别
  getClipboardWeKoContents() async {
    ClipboardData clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text.trim() != '') {
      String weCo = clipboardData.text.trim();
      RegExp regExp = RegExp(r'(wpy):\/\/(school_project)\/');
      if (regExp.hasMatch(weCo)) {
        var id = RegExp(r'\d{1,}').stringMatch(weCo);
        if (!Provider.of<MessageProvider>(context, listen: false)
            .feedbackHasViewed
            .contains(id)) {
          FeedbackService.getPostById(
              id: int.parse(id),
              onResult: (post) {
                showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return WeKoDialog(
                      post: post,
                      onConfirm: () => Navigator.pop(context, true),
                      onCancel: () => Navigator.pop(context, true),
                    );
                  },
                ).then((confirm) {
                  if (confirm != null && confirm) {
                    Navigator.pushNamed(context, FeedbackRouter.detail,
                        arguments: post);
                    Provider.of<MessageProvider>(context, listen: false)
                        .setFeedbackWeKoHasViewed(id);
                  } else {
                    Provider.of<MessageProvider>(context, listen: false)
                        .setFeedbackWeKoHasViewed(id);
                  }
                });
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              });
        }
      }
    }
  }

  @override
  void initState() {
    _swap = 0;
    _lakeIsLoaded = false;
    _feedbackIsLoaded = false;
    _tagsWrapIsShow = false;
    _tagsContainerCanAnimate = true;
    _tagsContainerBackgroundIsShow = false;
    _tagsContainerBackgroundOpacity = 0;
    _refreshController = _refreshController1;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _listProvider = Provider.of<FbHomeListModel>(context, listen: false);
      _hotTagsProvider = Provider.of<FbHotTagsProvider>(context, listen: false);
      _tagsProvider = Provider.of<FbTagsProvider>(context, listen: false);
      _listProvider.checkTokenAndGetPostList(_tagsProvider, 2, failure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        //判断TabBar是否切换
        switch (_tabController.index) {
          case 0:
            {
              _controller1.jumpTo(_offsets[0]);
              setState(() {
                _refreshController = _refreshController1;
                _controller = _controller1;
                _swap = 0;
                _tagsWrapIsShow = false;
                _tagsContainerBackgroundIsShow = false;
                _tagsContainerBackgroundOpacity = 0;
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
                _tagsWrapIsShow = false;
                _tagsContainerBackgroundIsShow = false;
                _tagsContainerBackgroundOpacity = 0;
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
            setState(() {
              _swap = -1;
              _tagsWrapIsShow = false;
              _tagsContainerBackgroundIsShow = false;
              _tagsContainerBackgroundOpacity = 0;
            });
            break;
        }
      }
    });
    getClipboardWeKoContents();
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

    if (_initialRefresh ?? false) {
      if (_controller.offset != null) listToTop();
      _initialRefresh = false;
    }

    var searchBar = InkWell(
      onTap: () => Navigator.pushNamed(context, FeedbackRouter.search),
      child: Container(
        height: 30,
        margin: EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
            color: ColorUtil.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Row(children: [
          SizedBox(width: 14),
          Icon(
            Icons.search,
            size: 19,
            color: ColorUtil.grey108,
          ),
          SizedBox(width: 12),
          Text(
            '搜索问题',
            style: TextStyle().grey6C.NotoSansSC.w400.sp(16),
          ),
          Spacer()
        ]),
      ),
    );
    _offsets[0] = _controller1.hasClients ? _controller1.offset : 2;
    _offsets[1] = _controller2.hasClients ? _controller2.offset : 2;
    _offsets[2] = _controller3.hasClients ? _controller3.offset : 2;
    _mixedListView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController1,
          header: ClassicHeader(
            completeDuration: Duration(milliseconds: 300),
          ),
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
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      );
    });
    _lakeListView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController2,
          header: ClassicHeader(
            completeDuration: Duration(milliseconds: 300),
          ),
          enablePullDown: true,
          onRefresh: onRefresh,
          footer: ClassicFooter(
            idleIcon: Icon(Icons.check, color: Colors.grey),
            idleText: "你翻到了青年湖底！",
          ),
          enablePullUp: !model.isLastPage,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: _controller2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: model.allList[swapLister[1]].length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return InkWell(onTap: getHotList,child: HotCard());
              index--;
              final post = model.allList[swapLister[1]][index];
              return PostCard.simple(post, key: ValueKey(post.id));
            },
          ),
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      );
    });

    var tagsWrap = Consumer<FbTagsProvider>(
      builder: (_, provider, __) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
          child: Wrap(
            spacing: 6,
            children: List.generate(provider.departmentList.length, (index) {
              return InkResponse(
                radius: 30,
                highlightColor: Colors.transparent,
                child: Chip(
                  backgroundColor: Color.fromRGBO(234, 234, 234, 1),
                  label: Text(provider.departmentList[index].name,
                      style: TextUtil.base.normal.black2A.NotoSansSC.sp(13)),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    FeedbackRouter.searchResult,
                    arguments: SearchResultPageArgs(
                      '',
                      provider.departmentList[index].id.toString(),
                      '#${provider.departmentList[index].name}',
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );

    _departmentSelectionContainer = Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: ColorUtil.white253,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22))),
      child: AnimatedSize(
        curve: Curves.easeOutCirc,
        duration: Duration(milliseconds: 400),
        vsync: this,
        child: Offstage(offstage: !_tagsWrapIsShow, child: tagsWrap),
      ),
    );

    _feedbackListView = Consumer<FbHomeListModel>(builder: (_, model, __) {
      return NotificationListener<ScrollNotification>(
        child: Stack(
          children: [
            SmartRefresher(
              physics: BouncingScrollPhysics(),
              controller: _refreshController3,
              header: ClassicHeader(
                completeDuration: Duration(milliseconds: 300),
              ),
              enablePullDown: true,
              onRefresh: onRefresh,
              footer: ClassicFooter(
                idleIcon: Icon(Icons.check, color: Colors.grey),
                idleText: "只有这么多了",
              ),
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
            ),
            Offstage(
                offstage: !_tagsContainerBackgroundIsShow,
                child: AnimatedOpacity(
                  opacity: _tagsContainerBackgroundOpacity,
                  duration: Duration(milliseconds: 500),
                  onEnd: _offstageTheBackground,
                  child: InkWell(
                    onTap: _onTapped,
                    child: Container(
                      color: Colors.black45,
                    ),
                  ),
                )),
            Offstage(
              offstage: !_tagsContainerBackgroundIsShow,
              child: _departmentSelectionContainer,
            )
          ],
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      );
    });

    return SafeArea(
      child: NestedScrollView(
        controller: _nestedController,
        physics: BouncingScrollPhysics(),
        floatHeaderSlivers: false,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          scroll = false;
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
                        _initialRefresh = true;
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
                    child: Container(
                  color: ColorUtil.white253,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 4),
                        Expanded(
                          child: TabBar(
                              indicatorPadding: EdgeInsets.only(bottom: 2),
                              labelPadding: EdgeInsets.only(bottom: 3),
                              isScrollable: true,
                              physics: BouncingScrollPhysics(),
                              controller: _tabController,
                              labelColor: Color(0xff303c66),
                              labelStyle:
                                  TextUtil.base.black2A.w700.NotoSansSC.sp(18),
                              unselectedLabelColor: ColorUtil.lightTextColor,
                              unselectedLabelStyle:
                                  TextUtil.base.grey6C.w600.NotoSansSC.sp(18),
                              indicator: CustomIndicator(
                                  borderSide: BorderSide(
                                      color: ColorUtil.mainColor, width: 2)),
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
                                  child: _swap == 2
                                      ? InkWell(
                                          child: Row(
                                            children: [
                                              SizedBox(width: _tabPaddingWidth),
                                              Text("校务"),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                size: 12,
                                              )
                                            ],
                                          ),
                                          onTap: _onTapped,
                                        )
                                      : Row(
                                          children: [
                                            SizedBox(width: _tabPaddingWidth),
                                            Text("校务"),
                                            SizedBox(width: _tabPaddingWidth),
                                          ],
                                        ),
                                ),
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(2.0))),
                                        child: Text(
                                          "荐",
                                          style: TextUtil
                                              .base.w400.white.NotoSansSC
                                              .sp(9),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          tooltip: "排序方式",
                          shape: RacTangle(),
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
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text(
                                  '时间排序',
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Text('动态排序'),
                              ),
                            ];
                          },
                        ),
                        SizedBox(width: 17)
                      ]),
                )))
          ];
        },
        body: Consumer<FbHomeStatusNotifier>(
          builder: (_, status, __) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(color: ColorUtil.backgroundColor),
                Padding(
                    padding: EdgeInsets.zero,
                    child: ExtendedTabBarView(
                      controller: _tabController,
                      cacheExtent: 2,
                      children: <Widget>[
                        _mixedListView,
                        _lakeListView,
                        _feedbackListView,
                        GamePage()
                      ],
                    )),
                if (status.isLoading) Loading(),
                if (status.isError) HomeErrorContainer(onRefresh, true),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void listToTop() {
    if (_controller.offset > 1500) _controller.jumpTo(1500);
    _controller.animateTo(-85,
        duration: Duration(milliseconds: 400), curve: Curves.easeOutCirc);
  }
}

class RacTangle extends ShapeBorder {
  @override
  // ignore: missing_return
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return null;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(10)));
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    var paint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    var w = rect.width;
    var tang = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..color = Colors.white
      ..strokeWidth = 5;
    //var h = rect.height;
    canvas.drawLine(Offset(0, 5), Offset(w / 2, 5), paint);
    canvas.drawLine(Offset(w - 20, 5), Offset(w - 15, -5), tang);
    canvas.drawLine(Offset(w - 15, -5), Offset(w - 10, 5), tang);
    canvas.drawLine(Offset(w - 10, 5), Offset(w, 5), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return null;
  }

  @override
  EdgeInsetsGeometry get dimensions => null;
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
  double get maxExtent => 32;

  @override
  double get minExtent => 32;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class HomeErrorContainer extends StatefulWidget {
  final void Function(AnimationController) onPressed;
  final bool networkFailPageUsage;

  HomeErrorContainer(this.onPressed, this.networkFailPageUsage);

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
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurveTween(curve: Curves.easeInOutCubic).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    var errorImg = SvgPicture.asset('assets/svg_pics/network_failed.svg');

    var errorText = Text(
        widget.networkFailPageUsage ? '错误！请重试' : '啊哦，没有找到相关消息... \n 要不然换一个试试？',
        style: TextUtil.base.black2A.NotoSansSC.w600.sp(16));

    var retryButton = FloatingActionButton(
      child: RotationTransition(
        alignment: Alignment.center,
        turns: animation,
        child: Icon(Icons.refresh),
      ),
      elevation: 4,
      heroTag: 'error_btn',
      backgroundColor: Colors.white,
      foregroundColor: ColorUtil.mainColor,
      onPressed: () {
        if (!controller.isAnimating) {
          controller.repeat();
          widget.onPressed?.call(controller);
        }
      },
      mini: true,
    );

    var paddingBox = SizedBox(height: ScreenUtil.defaultSize.height / 5);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          errorImg,
          errorText,
          paddingBox,
          widget.networkFailPageUsage ? retryButton : SizedBox(),
        ],
      ),
    );
  }
}
