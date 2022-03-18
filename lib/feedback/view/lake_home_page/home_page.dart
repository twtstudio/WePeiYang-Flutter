import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/first_in_lake_dialog.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tab.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/normal_sub_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';

import '../search_result_page.dart';

class FeedbackHomePage extends StatefulWidget {
  FeedbackHomePage({Key key}) : super(key: key);

  @override
  FeedbackHomePageState createState() => FeedbackHomePageState();
}

class FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<bool> shouldBeInitialized;
  final fbKey = new GlobalKey<FbTagsWrapState>();

  List<WPYTab> tabList;

  ///根据tab的index得到对应type
  ///
  final postTypeNotifier = ValueNotifier(int);

  bool scroll = false;

  bool initializeRefresh = false;

  bool canSee = false;

  /// nestedScrollView 展示 appbar
  _onFeedbackOpen() {
    if (!scroll && context.read<LakeModel>().nController.offset != 0) {
      scroll = true;
      context
          .read<LakeModel>()
          .nController
          .animateTo(0,
              duration: Duration(milliseconds: 200), curve: Curves.decelerate)
          .then((value) => scroll = false);
    }
  }

  ///初次进入湖底的告示
  firstInLake() async {
    final checkedNotifier = ValueNotifier(true);
    if (CommonPreferences().isFirstLogin.value) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return FirstInLakeDialog(checkedNotifier: checkedNotifier);
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      firstInLake();
    });
    context.read<LakeModel>().checkTokenAndGetTabList();
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
    context.read<LakeModel>().nController = new ScrollController();

    getClipboardWeKoContents();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void listToTop() {
    if (context
            .read<LakeModel>()
            .lakeAreas[context
                .read<LakeModel>()
                .lakeTabList[context.read<LakeModel>().tabController.index]]
            .controller
            .offset >
        1500) {
      context
          .read<LakeModel>()
          .lakeAreas[context
              .read<LakeModel>()
              .lakeTabList[context.read<LakeModel>().tabController.index]]
          .controller
          .jumpTo(1500);
    }
    context
        .read<LakeModel>()
        .lakeAreas[context
            .read<LakeModel>()
            .lakeTabList[context.read<LakeModel>().tabController.index]]
        .controller
        .animateTo(-85,
            duration: Duration(milliseconds: 400), curve: Curves.easeOutCirc);
  }

  _onFeedbackTapped() {
    if (!context.read<LakeModel>().tabController.indexIsChanging) {
      if (canSee) {
        _onFeedbackOpen();
        fbKey.currentState.tap();
        setState(() {
          canSee = false;
        });
      } else {
        _onFeedbackOpen();
        fbKey.currentState.tap();
        setState(() {
          canSee = true;
        });
      }
    }
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
    if (initializeRefresh == true) {
      context
          .read<LakeModel>()
          .lakeAreas[context
          .read<LakeModel>()
          .lakeTabList[context.read<LakeModel>().tabController.index]]
          .controller
          .animateTo(-85,
          duration: Duration(milliseconds: 1000), curve: Curves.easeOutCirc);
      initializeRefresh = false;
    }

    var searchBar = InkWell(
      onTap: () => Navigator.pushNamed(context, FeedbackRouter.search),
      child: Container(
        height: 30.w,
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

    return SafeArea(
      child: NestedScrollView(
          controller: context.read<LakeModel>().nController,
          physics: BouncingScrollPhysics(),
          floatHeaderSlivers: false,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            scroll = false;
            return <Widget>[
              SliverAppBar(
                toolbarHeight: 48,
                backgroundColor: Colors.white,
                titleSpacing: 0,
                leading: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () =>
                      Navigator.pushNamed(context, FeedbackRouter.profile),
                  child: Center(
                    child: FeedbackBadgeWidget(
                      child: ImageIcon(
                          AssetImage("assets/images/lake_butt_icons/box.png"),
                          size: 23,
                          color: ColorUtil.boldTag54),
                    ),
                  ),
                ),
                title: searchBar,
                actions: [
                  Hero(
                    tag: "addNewPost",
                    child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/lake_butt_icons/add_post.png")))),
                        onTap: () {
                          initializeRefresh = true;
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
                    color: ColorUtil.whiteFDFE,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 4),
                          Expanded(
                            child: Selector<LakeModel, List<WPYTab>>(selector:
                                (BuildContext context, LakeModel lakeModel) {
                              return lakeModel.lakeTabList;
                            }, builder: (_, lakeTabList, __) {
                              return context
                                          .read<LakeModel>()
                                          .lakeTabList
                                          .length ==
                                      0
                                  ? InkWell(
                                      onTap: () => context
                                          .read<LakeModel>()
                                          .checkTokenAndGetTabList(),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text('点击重新加载分区',
                                            style: TextUtil.base.mainColor.w400
                                                .sp(16)),
                                      ))
                                  : TabBar(
                                      indicatorPadding:
                                          EdgeInsets.only(bottom: 2),
                                      labelPadding: EdgeInsets.only(bottom: 3),
                                      isScrollable: true,
                                      physics: BouncingScrollPhysics(),
                                      controller: context
                                          .read<LakeModel>()
                                          .tabController,
                                      labelColor: ColorUtil.black2AColor,
                                      labelStyle: TextUtil
                                          .base.black2A.w600.NotoSansSC
                                          .sp(18),
                                      unselectedLabelColor:
                                          ColorUtil.lightTextColor,
                                      unselectedLabelStyle: TextUtil
                                          .base.greyB2.w600.NotoSansSC
                                          .sp(18),
                                      indicator: CustomIndicator(
                                          borderSide: BorderSide(
                                              color: ColorUtil.mainColor,
                                              width: 2)),
                                      tabs: List<Widget>.generate(
                                          lakeTabList == null
                                              ? 1
                                              : lakeTabList.length,
                                          (index) => DaTab(
                                              text:
                                                  lakeTabList[index].shortname,
                                              withDropDownButton:
                                                  lakeTabList[index].name ==
                                                      '校务专区')),
                                      onTap: (index) {
                                        if (lakeTabList[index].name == '校务专区') {
                                          _onFeedbackTapped();
                                        }
                                      },
                                    );
                            }),
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
                              context.read<LakeModel>().sortSeq = value;
                              listToTop();
                            },
                            itemBuilder: (context) {
                              return <PopupMenuEntry<int>>[
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Text(
                                    '时间排序',
                                    style:
                                        context.read<LakeModel>().sortSeq == 1
                                            ? TextUtil.base.mainColor.w200
                                            : TextUtil.base.mainColor.w600,
                                  ),
                                ),
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: Text(
                                    '动态排序',
                                    style: context.read<LakeModel>().sortSeq !=
                                            null
                                        ? context.read<LakeModel>().sortSeq == 1
                                            ? TextUtil.base.mainColor.w600
                                            : TextUtil.base.mainColor.w200
                                        : TextUtil.base.mainColor.w200,
                                  ),
                                ),
                              ];
                            },
                          ),
                          SizedBox(width: 17)
                        ]),
                  )))
            ];
          },
          body: Stack(
            children: [
              Selector<LakeModel, List<WPYTab>>(
                  selector: (BuildContext context, LakeModel lakeModel) {
                return lakeModel.lakeTabList;
              }, builder: (_, lakeTabList, __) {
                if (!context.read<LakeModel>().tabControllerLoaded) {
                  context.read<LakeModel>().tabController =
                      TabController(length: lakeTabList.length, vsync: this)
                        ..addListener(() {
                          if (context
                                  .read<LakeModel>()
                                  .tabController
                                  .index
                                  .toDouble() ==
                              context
                                  .read<LakeModel>()
                                  .tabController
                                  .animation
                                  .value) {
                            int canMove = -1;
                            context
                                .read<LakeModel>()
                                .lakeTabList
                                .forEach((element) {
                              if (element.name == '校务专区') canMove = element.id;
                            });
                            if (context.read<LakeModel>().tabController.index !=
                                    canMove &&
                                canSee) _onFeedbackTapped();
                          }
                        });
                }
                int cacheNum = 0;
                return ExtendedTabBarView(
                    cacheExtent: cacheNum,
                    controller: context.read<LakeModel>().tabController,
                    children: List<Widget>.generate(
                        lakeTabList == null ? 1 : lakeTabList.length,
                        (ind) => NSubPage(
                              wpyTab: lakeTabList[ind],
                            )));
              }),
              Visibility(
                child: InkWell(
                    onTap: () {
                      if (canSee) _onFeedbackTapped();
                    },
                    child: FbTagsWrap(key: fbKey)),
                maintainState: true,
                visible: canSee,
              ),
            ],
          )),
    );
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
    // var paint = Paint()
    //   ..color = Colors.transparent
    //   ..strokeWidth = 12.0
    //   ..style = PaintingStyle.stroke
    //   ..strokeJoin = StrokeJoin.round;
    // var w = rect.width;
    // var tang = Paint()
    //   ..isAntiAlias = true
    //   ..strokeCap = StrokeCap.square
    //   ..color = Colors.white
    //   ..strokeWidth = 5;
    // //var h = rect.height;
    // canvas.drawLine(Offset(0, 5), Offset(w / 2, 5), paint);
    // canvas.drawLine(Offset(w - 20, 5), Offset(w - 15, -5), tang);
    // canvas.drawLine(Offset(w - 15, -5), Offset(w - 10, 5), tang);
    // canvas.drawLine(Offset(w - 10, 5), Offset(w, 5), paint);
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

class FbTagsWrap extends StatefulWidget {
  FbTagsWrap({Key key}) : super(key: key);

  @override
  FbTagsWrapState createState() => FbTagsWrapState();
}

class FbTagsWrapState extends State<FbTagsWrap>
    with SingleTickerProviderStateMixin {
  FbTagsWrapState();

  bool _tagsContainerCanAnimate,
      _tagsContainerBackgroundIsShow,
      _tagsWrapIsShow;
  double _tagsContainerBackgroundOpacity = 0;

  @override
  void initState() {
    _tagsWrapIsShow = false;
    _tagsContainerCanAnimate = true;
    _tagsContainerBackgroundIsShow = false;
    _tagsContainerBackgroundOpacity = 0;
    super.initState();
  }

  _offstageTheBackground() {
    _tagsContainerCanAnimate = true;
    if (_tagsContainerBackgroundOpacity < 1) {
      _tagsContainerBackgroundIsShow = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
    var _departmentSelectionContainer = Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: ColorUtil.whiteFDFE,
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
    return Stack(
      children: [
        Offstage(
            offstage: !_tagsContainerBackgroundIsShow,
            child: AnimatedOpacity(
              opacity: _tagsContainerBackgroundOpacity,
              duration: Duration(milliseconds: 500),
              onEnd: _offstageTheBackground,
              child: Container(
                color: Colors.black45,
              ),
            )),
        Offstage(
          offstage: !_tagsContainerBackgroundIsShow,
          child: _departmentSelectionContainer,
        ),
      ],
    );
  }

  void tap() {
    if (_tagsContainerCanAnimate) _tagsContainerCanAnimate = false;
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
}
