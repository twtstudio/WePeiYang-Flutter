import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/hot_rank_card.dart';
import 'package:we_pei_yang_flutter/main.dart';

class NSubPage extends StatefulWidget {
  final int index;

  const NSubPage({Key key, this.index}) : super(key: key);

  @override
  NSubPageState createState() => NSubPageState(this.index);
}

class NSubPageState extends State<NSubPage> with AutomaticKeepAliveClientMixin {
  int index;
  FbDepartmentsProvider _departmentsProvider;
  double _previousOffset = 0;

  NSubPageState(this.index);
  List<String> topText = [
    "当我在刷新时，我很火大",
    "我学不完啊啊啊啊啊啊啊",
    "仙客来根雕",
    "（^_^）你作业写完了吗",
    "OvO昆",
  ];
  void getRecTag() {
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (context
            .read<LakeModel>()
            .lakeAreas[index]
            .refreshController
            .isRefresh &&
        scrollInfo.metrics.pixels >= 2)
      context
          .read<LakeModel>()
          .lakeAreas[index]
          .refreshController
          .refreshToIdle();
    if (scrollInfo.metrics.pixels == 0)
      context.read<LakeModel>().onFeedbackOpen();
    if ((scrollInfo.metrics.pixels - _previousOffset).abs() >= 20 &&
        scrollInfo.metrics.pixels >= 10 &&
        scrollInfo.metrics.pixels <= scrollInfo.metrics.maxScrollExtent - 10) {
      if (scrollInfo.metrics.pixels <= _previousOffset)
        context.read<LakeModel>().onFeedbackOpen();
      else
        context.read<LakeModel>().onClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
  }

  onRefresh([AnimationController controller]) async {
    FeedbackService.getToken(onResult: (_) {
      context.read<LakeModel>().getClipboardWeKoContents(context);
      if (index == 0) context.read<FbHotTagsProvider>().initHotTags();
      getRecTag();
      context.read<LakeModel>().initPostList(index, success: () {
        setState(() {});
        context
            .read<LakeModel>()
            .lakeAreas[index]
            .refreshController
            .refreshCompleted();
      }, failure: (e) {
        if (e.type == DioErrorType.connectTimeout ||
            e.type == DioErrorType.receiveTimeout ||
            e.type == DioErrorType.sendTimeout)
          context
              .read<LakeModel>()
              .lakeAreas[index]
              .refreshController
              .refreshToIdle();
        controller?.stop();
        context
            .read<LakeModel>()
            .lakeAreas[index]
            .refreshController
            .refreshFailed();
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
      controller?.stop();
      context
          .read<LakeModel>()
          .lakeAreas[index]
          .refreshController
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
            .refreshController
            .loadComplete();
      },
      failure: (e) {
        context
            .read<LakeModel>()
            .lakeAreas[index]
            .refreshController
            .loadFailed();
      },
    );
  }

  void listToTop() {
    if (context.read<LakeModel>().lakeAreas[index].controller.offset > 1500) {
      context.read<LakeModel>().lakeAreas[index].controller.jumpTo(1500);
    }
    context.read<LakeModel>().lakeAreas[index].controller.animateTo(-85,
        duration: Duration(milliseconds: 400), curve: Curves.easeOutCirc);
  }

  @override
  void initState() {
    _departmentsProvider =
        Provider.of<FbDepartmentsProvider>(context, listen: false);
    context.read<LakeModel>().fillLakeArea(
        index, RefreshController(initialRefresh: false), ScrollController());
    context.read<LakeModel>().checkTokenAndGetPostList(
        _departmentsProvider, index, context.read<LakeModel>().sortSeq ?? 0,
        success: () {}, failure: (e) {
      ToastProvider.error(e.error.toString());
    });
    if (index == 0) context.read<FbHotTagsProvider>().initHotTags();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final status =
        context.select((LakeModel model) => model.lakeAreas[index].status);

    if (status == LakePageStatus.idle)
      return NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller:
              context.read<LakeModel>().lakeAreas[index].refreshController,
          header: ClassicHeader(
            completeDuration: Duration(milliseconds: 300),
            idleText: '下拉以刷新 (乀*･ω･)乀',
            releaseText: '下拉以刷新',
            refreshingText: topText[Random().nextInt(topText.length)],
            completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
            failedText: '刷新失败（；´д｀）ゞ',
          ),
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
            controller: context.read<LakeModel>().lakeAreas[index].controller,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: context.select((LakeModel model) =>
                model.lakeAreas[index].dataList.values.toList().length),
            itemBuilder: (context, ind) {
              return Builder(builder: (context) {
                if (index == 0 && ind == 0) {
                  return HotCard();
                }
                if (index == 0) ind--;
                if (ind == 0)
                  return Container(
                    margin: EdgeInsets.fromLTRB(14, 14, 12, 4),
                    padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 10.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('您现在使用的不是稳定版本，请在检查更新可用后更新最新版本',
                            style:
                                TextUtil.base.w500.NotoSansSC.sp(18).black2A),
                        SizedBox(height: 6),
                        Text('【维护公告】\n目前服务器证书正在升级，微北洋服务可能有不稳定的情况，我们将在恢复后通知大家。',
                            style: TextUtil.base.NotoSansSC.w400
                                .sp(16)
                                .black2A
                                .h(1.4))
                      ],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromRGBO(255, 243, 243, 1.0),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 1.6,
                            color: Colors.black26,
                            offset: Offset(0, 0),
                            spreadRadius: -0.8),
                      ],
                    ),
                  );
                ind--;
                final post = context
                    .read<LakeModel>()
                    .lakeAreas[index]
                    .dataList
                    .values
                    .toList()[ind];
                return PostCard.simple(post, key: ValueKey(post.id));
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
      return Loading();
  }
}

class HomeErrorContainer extends StatefulWidget {
  final void Function(AnimationController) onPressed;
  final bool networkFailPageUsage;
  final int index;

  HomeErrorContainer(this.onPressed, this.networkFailPageUsage, this.index);

  @override
  _HomeErrorContainerState createState() => _HomeErrorContainerState();
}

class _HomeErrorContainerState extends State<HomeErrorContainer>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  LakeModel _listProvider;
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
          widget.onPressed?.call(controller);
        }
      },
      mini: true,
    );

    var paddingBox = SizedBox(height: WePeiYangApp.screenHeight / 8);

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
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
