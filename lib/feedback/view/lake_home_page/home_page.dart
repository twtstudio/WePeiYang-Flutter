import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/auth/view/login/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
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
import 'package:we_pei_yang_flutter/home/home_router.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';

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
  FbDepartmentsProvider _tagsProvider;
  FbHotTagsProvider _hotTagsProvider;
  TabController _tabController;
  double _tabPaddingWidth = 0;
  double _previousOffset = 0;
  List<double> _offsets = [2, 2, 2];
  List<bool> shouldBeInitialized;

  bool _initialRefresh;

  ///判断是否为初次登陆
  bool _lakeFirst = true;
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
      if (_swap == 1) getHotList();
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

  _onFeedbackTapped() {
    _onFeedbackOpen();
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

  _onFeedbackOpen() {
    if (!scroll && _nestedController.offset != 0) {
      scroll = true;
      _nestedController
          .animateTo(0,
              duration: Duration(milliseconds: 160), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == 0) _onFeedbackOpen();
    if ((scrollInfo.metrics.pixels - _previousOffset).abs() >= 20 &&
        scrollInfo.metrics.pixels >= 10 &&
        scrollInfo.metrics.pixels <= scrollInfo.metrics.maxScrollExtent - 10) {
      if (scrollInfo.metrics.pixels <= _previousOffset)
        _onFeedbackOpen();
      else
        _onClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
  }

  ///初次进入湖底的告示
  firstInLake() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("firstLogin", _lakeFirst);
    bool firstLogin = pref.getBool("firstLogin");
    final checkedNotifier = ValueNotifier(firstLogin);
    if (firstLogin == true) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DialogWidget(
                title: '同学你好：',
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.w),
                    Text(
                      "经过一段时间的沉寂，我们很高兴能够带着崭新的青年湖底与您相见。\n" +
                          "\n" +
                          "让我来为您简单的介绍一下，原“校务专区”已与其包含的标签“小树洞”分离，成为青年湖底论坛中的两个分区，同时我们也在努力让青年湖底在功能上接近于一个成熟的论坛。\n" +
                          "\n" +
                          "现在它拥有：\n" +
                          "\n" +
                          "点踩、举报；回复评论、带图评论；分享、自定义tag...还有一些细节等待您去自行挖掘。\n" +
                          "\n" +
                          "还有最重要的一点，为了营造良好的社区氛围，这里有一份社区规范待您查看。",
                      style:
                          TextUtil.base.normal.black2A.NotoSansSC.sp(14).w400,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Checkbox(
                        //   value: false,
                        //   onChanged: (_) {
                        //     _lakeFirst =!_lakeFirst;
                        //   },
                        // ),
                        ValueListenableBuilder<bool>(
                            valueListenable: checkedNotifier,
                            builder: (context, type, _) {
                              return GestureDetector(
                                onTap: () {
                                  checkedNotifier.value =
                                      !checkedNotifier.value;
                                },
                                child: Stack(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg_pics/lake_butt_icons/checkedbox_false.svg",
                                      width: 16.w,
                                    ),
                                    if (checkedNotifier.value == false)
                                      Positioned(
                                        top: 3.w,
                                        left: 3.w,
                                        child: SvgPicture.asset(
                                          "assets/svg_pics/lake_butt_icons/check.svg",
                                          width: 10.w,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                        SizedBox(width: 10.w),
                        Text('我已阅读并承诺遵守',
                            style: TextUtil.base.normal.black2A.NotoSansSC
                                .sp(14)
                                .w400),
                        SizedBox(width: 5.w),
                        TextButton(
                            style: ButtonStyle(
                              minimumSize:
                                  MaterialStateProperty.all(Size(1, 1)),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) =>
                                      PrivacyDialog());
                            },
                            child: Text('《青年湖底社区规范》',
                                style: TextUtil.base.normal.NotoSansSC
                                    .sp(14)
                                    .w400
                                    .textButtonBlue))
                      ],
                    )
                  ],
                ),
                cancelText: "返回主页",
                confirmTextStyle:
                    TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                cancelTextStyle:
                    TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                confirmText: "前往湖底",
                cancelFun: () {
                  Navigator.pushNamed(context, HomeRouter.home);
                },
                confirmFun: () {
                  if (checkedNotifier.value == false) {
                    Navigator.pop(context);
                    pref.setBool("firstLogin", checkedNotifier.value);
                  } else {
                    ToastProvider.error('请同意《青年湖底社区规范》');
                  }
                });
          });
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
        if (CommonPreferences().feedbackLastWeCo.value != id) {
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
                    CommonPreferences().feedbackLastWeCo.value = id;
                  } else {
                    CommonPreferences().feedbackLastWeCo.value = id;
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
    _tagsWrapIsShow = false;
    _tagsContainerCanAnimate = true;
    _tagsContainerBackgroundIsShow = false;
    _tagsContainerBackgroundOpacity = 0;
    _refreshController = _refreshController1;
    shouldBeInitialized = [false, true, true, false];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _listProvider = Provider.of<FbHomeListModel>(context, listen: false);
      _hotTagsProvider = Provider.of<FbHotTagsProvider>(context, listen: false);
      _tagsProvider =
          Provider.of<FbDepartmentsProvider>(context, listen: false);
      _listProvider.checkTokenAndGetPostList(_tagsProvider, 2, success: () {
        getRecTag();
      }, failure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        //判断TabBar是否切换
        if (shouldBeInitialized[_tabController.index]) {
          context.read<FbHomeListModel>().addSomeLoading();
          FeedbackService.getToken(onResult: (_) {
            _listProvider.initPostList(swapLister[_tabController.index],
                success: () =>
                    shouldBeInitialized[_tabController.index] = false);
            getRecTag();
            if (_tabController.index == 1) getHotList();
          }, onFailure: (e) {
            ToastProvider.error(e.error.toString());
            context.read<FbHomeListModel>().loadingFailed();
          });
        }

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

    //控制动画速率
    timeDilation = 0.9;
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(390, 844),
        orientation: Orientation.portrait);

    _tabPaddingWidth = MediaQuery.of(context).size.width / 30;

    if (_initialRefresh ?? false) {
      if (_controller.hasClients) listToTop();
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
          Consumer<FbHotTagsProvider>(
              builder: (_, data, __) => Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: WePeiYangApp.screenWidth - 260),
                        child: Text(
                          data.recTag == null
                              ? '搜索发现'
                              : '#${data.recTag.name}#',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle().grey6C.NotoSansSC.w400.sp(15),
                        ),
                      ),
                      Text(
                        data.recTag == null ? '' : '  为你推荐',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle().grey6C.NotoSansSC.w400.sp(15),
                      ),
                    ],
                  )),
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
            itemCount: model.allList[swapLister[1]].length == 0
                ? 0
                : model.allList[swapLister[1]].length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return HotCard();
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

    var tagsWrap = Consumer<FbDepartmentsProvider>(
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
                        '',
                        provider.departmentList[index].id.toString(),
                        '#${provider.departmentList[index].name}',
                        1),
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
                    onTap: _onFeedbackTapped,
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
                                                size: 10,
                                              ),
                                              if (_tabPaddingWidth > 10)
                                                SizedBox(
                                                    width:
                                                        _tabPaddingWidth - 10)
                                            ],
                                          ),
                                          onTap: _onFeedbackTapped,
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(width: _tabPaddingWidth),
                                      Text("游戏"),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 1, bottom: 3),
                                        child: SvgPicture.asset(
                                          'assets/svg_pics/lake_butt_icons/recommended.svg',
                                          width: 12,
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
                          //0-->时间排序，1-->动态排序
                          onSelected: (value) {
                            CommonPreferences().feedbackSearchType.value =
                                value.toString();
                            onRefresh();
                          },
                          itemBuilder: (context) {
                            return <PopupMenuEntry<int>>[
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text(
                                  '时间排序',
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
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

  FbHomeListModel _listProvider;
  FbDepartmentsProvider _tagsProvider;

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
        FeedbackService.getToken(
            forceRefresh: true,
            onResult: (_) {
              _tagsProvider.initDepartments();
              _listProvider.initPostList(2, success: () {}, failure: (_) {});
            },
            onFailure: (e) {});
        if (!controller.isAnimating) {
          controller.repeat();
          widget.onPressed?.call(controller);
        }
      },
      mini: true,
    );

    var paddingBox = SizedBox(height: ScreenUtil.defaultSize.height / 8);

    return SingleChildScrollView(
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
