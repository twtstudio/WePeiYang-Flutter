import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/activity_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/hot_rank_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/urgent_report/base_page.dart';

import '../../../commons/widgets/w_button.dart';

class NSubPage extends StatefulWidget {
  final int index;

  const NSubPage({Key? key, required this.index}) : super(key: key);

  @override
  NSubPageState createState() => NSubPageState(this.index);
}

class NSubPageState extends State<NSubPage> with AutomaticKeepAliveClientMixin {
  int index;
  double _previousOffset = 0;

  NSubPageState(this.index);

  List<String> topText = [
    "正在刷新喵",
  ];

  void getRecTag() {
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (context
            .read<LakeModel>()
            .lakeAreas[index]!
            .refreshController
            .isRefresh &&
        scrollInfo.metrics.pixels >= 2)
      context
          .read<LakeModel>()
          .lakeAreas[index]!
          .refreshController
          .refreshToIdle();
    if (scrollInfo.metrics.pixels <
        12.h + FeedbackHomePageState().searchBarHeight)
      context.read<LakeModel>().onFeedbackOpen();
    if (scrollInfo.metrics.axisDirection == AxisDirection.down &&
        (scrollInfo.metrics.pixels - _previousOffset).abs() >= 20 &&
        scrollInfo.metrics.pixels >= 10 &&
        scrollInfo.metrics.pixels <= scrollInfo.metrics.maxScrollExtent - 10) {
      if (scrollInfo.metrics.pixels <= _previousOffset)
        context.read<LakeModel>().onFeedbackOpen();
      else
        context.read<LakeModel>().onFeedbackClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
    return true;
  }

  String get _getGreetText {
    int hour = DateTime.now().hour;
    if (hour < 5)
      return '晚上好';
    else if (hour >= 5 && hour < 12)
      return '早上好';
    else if (hour >= 12 && hour < 14)
      return '中午好';
    else if (hour >= 12 && hour < 17)
      return '下午好';
    else if (hour >= 17 && hour < 19)
      return '傍晚好';
    else
      return '晚上好';
  }

  onRefresh() async {
    context.read<LakeModel>().lakeAreas[index]?.status = LakePageStatus.loading;
    FeedbackService.getToken(onResult: (_) {
      if (index == 0) context.read<FbHotTagsProvider>().initHotTags();
      getRecTag();
      context.read<LakeModel>().initPostList(index, success: () {
        context
            .read<LakeModel>()
            .lakeAreas[index]
            ?.refreshController
            .refreshCompleted();
      }, failure: (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout)
          context
              .read<LakeModel>()
              .lakeAreas[index]
              ?.refreshController
              .refreshToIdle();
        context
            .read<LakeModel>()
            .lakeAreas[index]
            ?.refreshController
            .refreshFailed();
      });
      context.read<FestivalProvider>().initFestivalList();
      context.read<NoticeProvider>().initNotices();
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
      context
          .read<LakeModel>()
          .lakeAreas[index]
          ?.refreshController
          .refreshFailed();
    });
  }

  _onLoading() {
    context.read<LakeModel>().getNextPage(
      index,
      success: () {
        context
            .read<LakeModel>()
            .lakeAreas[index]
            ?.refreshController
            .loadComplete();
      },
      failure: (e) {
        context
            .read<LakeModel>()
            .lakeAreas[index]
            ?.refreshController
            .loadFailed();
      },
    );
  }

  void listToTop() {
    if (context.read<LakeModel>().lakeAreas[index]!.controller.offset > 1500) {
      context.read<LakeModel>().lakeAreas[index]!.controller.jumpTo(1500);
    }
    context.read<LakeModel>().lakeAreas[index]!.controller.animateTo(-85,
        duration: Duration(milliseconds: 400), curve: Curves.easeOutCirc);
  }

  @override
  void initState() {
    if (index == 0) {
      context.read<FbHotTagsProvider>().initHotTags();
      context.read<FestivalProvider>().initFestivalList();
      context.read<NoticeProvider>().initNotices();
    }
    context.read<LakeModel>().fillLakeAreaAndInitPostList(
        index, RefreshController(), ScrollController());
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var status =
        context.select((LakeModel model) => model.lakeAreas[index]!.status);

    if (status == LakePageStatus.idle)
      return NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller:
              context.read<LakeModel>().lakeAreas[index]!.refreshController,
          header: ClassicHeader(
            height: 5.h,
            completeDuration: Duration(milliseconds: 300),
            idleText: '下拉以刷新 (乀*･ω･)乀',
            releaseText: '下拉以刷新',
            refreshingText: topText[Random().nextInt(topText.length)],
            completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
            failedText: '刷新失败（；´д｀）ゞ',
          ),
          cacheExtent: 11,
          enablePullDown: true,
          onRefresh: onRefresh,
          footer: ClassicFooter(
            idleText: '下拉以刷新',
            noDataText: '无数据',
            loadingText: '加载中，请稍等  ;P',
            failedText: '加载失败（；´д｀）ゞ',
          ),
          enablePullUp: true,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: context.read<LakeModel>().lakeAreas[index]!.controller,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: context.select((LakeModel model) => index == 0
                ? model.lakeAreas[index]!.dataList.values.toList().length + 3
                : model.lakeAreas[index]!.dataList.values.toList().length + 2),
            itemBuilder: (context, ind) {
              return Builder(builder: (context) {
                if (ind == 0)
                  return Container(
                    height: 35.h,
                    margin: EdgeInsets.only(
                        top: 12.h + FeedbackHomePageState().searchBarHeight,
                        left: 14.w,
                        right: 14.w),
                    padding: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        color: ColorUtil.blue2CColor.withAlpha(12)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 12),
                          context.read<NoticeProvider>().noticeList.length > 0
                              ? WButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg_pics/lake_butt_icons/la_ba.svg",
                                        width: 20,
                                      ),
                                      SizedBox(width: 6),
                                      SizedBox(
                                          height: 20,
                                          width: WePeiYangApp.screenWidth - 83,
                                          child: context
                                                      .read<NoticeProvider>()
                                                      .noticeList
                                                      .length >
                                                  1
                                              ? TextScroller(
                                                  stepOffset: 500,
                                                  duration:
                                                      Duration(seconds: 20),
                                                  paddingLeft: 0.0,
                                                  children: List.generate(
                                                    context
                                                        .read<NoticeProvider>()
                                                        .noticeList
                                                        .length,
                                                    (index) => Text(
                                                        '· ${context.read<NoticeProvider>().noticeList[index].title.length > 21 ? context.read<NoticeProvider>().noticeList[index].title.replaceAll('\n', ' ').substring(0, 20) + '...' : context.read<NoticeProvider>().noticeList[index].title.replaceAll('\n', ' ')}           ',
                                                        style: TextUtil
                                                            .base
                                                            .blue2C
                                                            .w400
                                                            .NotoSansSC
                                                            .sp(15)),
                                                  ),
                                                )
                                              : Text(
                                                  '${context.read<NoticeProvider>().noticeList[0].title.length > 21 ? context.read<NoticeProvider>().noticeList[0].title.replaceAll('\n', ' ').substring(0, 20) + '...' : context.read<NoticeProvider>().noticeList[0].title.replaceAll('\n', ' ')}',
                                                  style: TextUtil.base.blue2C
                                                      .w400.NotoSansSC
                                                      .sp(15))),
                                    ],
                                  ),
                                  onPressed: () => Navigator.pushNamed(
                                      context, HomeRouter.notice),
                                )
                              : WButton(
                                  child: SizedBox(
                                    width: WePeiYangApp.screenWidth - 83,
                                    child: Text(
                                      '${_getGreetText}, ${CommonPreferences.lakeNickname.value == '无昵称' ? '微友' : CommonPreferences.lakeNickname.value.toString()}',
                                      style: TextUtil
                                          .base.blue2C.w600.NotoSansSC
                                          .sp(16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pushNamed(
                                      context, HomeRouter.notice),
                                ),
                          Spacer()
                        ]),
                  );
                ind--;
                if (index == 0 && ind == 0) return HotCard();
                if (index != 0 && ind == 0) return SizedBox(height: 10.h);
                ind--;
                if (ind == 0 &&
                    context.read<FestivalProvider>().nonePopupList.length > 0)
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: ActivityCard(1.sw - 40.w),
                  );
                ind--;
                if (ind == 0)
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        WButton(
                          onPressed: () {
                            setState(() {
                              context.read<LakeModel>().sortSeq = 1;
                              listToTop();
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 14.h, 5.w, 6.h),
                            child: Text('默认排序',
                                style: context.read<LakeModel>().sortSeq != 0
                                    ? TextUtil.base.blue2C.w600.sp(14)
                                    : TextUtil.base.black2A.w400.sp(14)),
                          ),
                        ),
                        WButton(
                          onPressed: () {
                            setState(() {
                              context.read<LakeModel>().sortSeq = 0;
                              listToTop();
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5.w, 14.h, 10.w, 6.h),
                            child: Text('最新发帖',
                                style: context.read<LakeModel>().sortSeq != 0
                                    ? TextUtil.base.black2A.w400.sp(14)
                                    : TextUtil.base.blue2C.w600.sp(14)),
                          ),
                        ),
                      ]);
                ind--;
                final post = context
                    .read<LakeModel>()
                    .lakeAreas[index]!
                    .dataList
                    .values
                    .toList()[ind];
                return PostCardNormal(post);
              });
            },
          ),
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      );
    else if (status == LakePageStatus.unload)
      return SizedBox();
    else if (status == LakePageStatus.error)
      return HomeErrorContainer(onRefresh, true, index);
    else
      return LoadingPageWidget(index, onRefresh);
  }
}

class LoadingPageWidget extends StatefulWidget {
  final int index;
  final void Function() onPressed;

  LoadingPageWidget(this.index, this.onPressed);

  @override
  _LoadingPageWidgetState createState() => _LoadingPageWidgetState();
}

class _LoadingPageWidgetState extends State<LoadingPageWidget>
    with SingleTickerProviderStateMixin {
  bool isOpa = false;
  bool showBtn = false;
  late final Timer _timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    isOpa = true;
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      count++;
      if (isOpa)
        isOpa = false;
      else
        isOpa = true;
      if (count > 50) {
        setState(() {
          showBtn = true;
        });
        _timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showBtn
        ? HomeErrorContainer(widget.onPressed, true, widget.index)
        : Stack(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 8,
                itemBuilder: (context, ind) {
                  return Builder(builder: (context) {
                    if (ind == 0)
                      return Container(
                        height: 35.h,
                        margin:
                            EdgeInsets.only(top: 14.h, left: 14.w, right: 14.w),
                        padding: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            color: ColorUtil.blue2CColor.withAlpha(12)),
                      );
                    ind--;
                    if (widget.index == 0 && ind == 0)
                      return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: ColorUtil.black26,
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          height: 160.h);
                    if (widget.index != 0 && ind == 0)
                      return SizedBox(height: 10.h);
                    ind--;
                    if (ind == 0 &&
                        context.read<FestivalProvider>().nonePopupList.length >
                            0)
                      return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: ColorUtil.black26,
                          ),
                          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          height: 0.32 * WePeiYangApp.screenWidth);
                    ind--;
                    if (ind == 0) return SizedBox(height: 20.h);
                    ind--;
                    return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: ColorUtil.black26,
                        ),
                        margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                        height: 160.h);
                  });
                },
              ),
              AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 1.sw,
                  height: 1.sh,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isOpa ? ColorUtil.black12Color : ColorUtil.black76Color,
                        !isOpa ? ColorUtil.black32Color : ColorUtil.black90Color,
                      ],
                    ),
                  ),
                  child: Center(child: Loading()))
            ],
          );
  }
}

class HomeErrorContainer extends StatefulWidget {
  final void Function() onPressed;
  final bool networkFailPageUsage;
  final int index;

  HomeErrorContainer(this.onPressed, this.networkFailPageUsage, this.index);

  @override
  _HomeErrorContainerState createState() => _HomeErrorContainerState();
}

class _HomeErrorContainerState extends State<HomeErrorContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  late final LakeModel _listProvider;
  late final FbDepartmentsProvider _tagsProvider;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurveTween(curve: Curves.easeInOutCubic).animate(controller);
    _listProvider = Provider.of<LakeModel>(context, listen: false);
    _tagsProvider = Provider.of<FbDepartmentsProvider>(context, listen: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var errorImg = WpyPic('assets/images/lake_butt_icons/monkie.png',
        height: 160, width: 160);

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
      backgroundColor: ColorUtil.whiteFFColor,
      foregroundColor: ColorUtil.mainColor,
      onPressed: () {
        FeedbackService.getToken(
            forceRefresh: true,
            onResult: (_) {
              _tagsProvider.initDepartments();
              _listProvider.initPostList(widget.index, success: () {
                widget.onPressed;
              }, failure: (_) {
                controller.reset();
                ToastProvider.error('刷新失败');
              });
            },
            onFailure: (e) {
              controller.reset();
              ToastProvider.error('刷新失败');
            });
        if (!controller.isAnimating) {
          controller.repeat();
          widget.onPressed.call();
        }
      },
      mini: true,
    );

    var paddingBox = SizedBox(height: WePeiYangApp.screenHeight / 8);

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 120.h),
          errorImg,
          SizedBox(height: 20.h),
          errorText,
          paddingBox,
          widget.networkFailPageUsage ? retryButton : SizedBox(),
        ],
      ),
    );
  }
}
