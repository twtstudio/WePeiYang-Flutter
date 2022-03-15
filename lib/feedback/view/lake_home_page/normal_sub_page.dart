import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/hot_rank_card.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';

class NSubPage extends StatefulWidget {
  final WPYTab wpyTab;

  const NSubPage({Key key, this.wpyTab}) : super(key: key);

  @override
  _NSubPageState createState() => _NSubPageState(this.wpyTab);
}

class _NSubPageState extends State<NSubPage>
    with AutomaticKeepAliveClientMixin {
  WPYTab wpyTab;
  FbDepartmentsProvider _departmentsProvider;
  RefreshController rController = new RefreshController(initialRefresh: false);
  ScrollController sController = new ScrollController();

  _NSubPageState(this.wpyTab);

  getRecTag() {
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  onRefresh([AnimationController controller]) async {
    FeedbackService.getToken(onResult: (_) {
      //_tagsProvider.initDepartments();
      if (wpyTab.name == '青年湖底')
        context.read<FbHotTagsProvider>().initHotTags();
      context.read<LakeModel>().initPostList(wpyTab, success: () {
        context
            .read<LakeModel>()
            .lakeAreas[wpyTab]
            .refreshController
            .refreshCompleted();
      }, failure: (_) {
        controller?.stop();
        context
            .read<LakeModel>()
            .lakeAreas[wpyTab]
            .refreshController
            .refreshFailed();
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
      controller?.stop();
      context
          .read<LakeModel>()
          .lakeAreas[wpyTab]
          .refreshController
          .refreshFailed();
    });
  }

  _onLoading() {
    // if (context
    //     .read<LakeModel>() == null ? true : context
    //     .read<LakeModel>().lakeAreas[wpyTab].isLastPage) {
    //   context
    //       .read<LakeModel>()
    //       .lakeAreas[wpyTab]
    //       .refreshController.loadNoData();
    // } else
    {
      context.read<LakeModel>().getNextPage(
        wpyTab,
        success: () {
          context
              .read<LakeModel>()
              .lakeAreas[wpyTab]
              .refreshController
              .loadComplete();
        },
        failure: (e) {
          context
              .read<LakeModel>()
              .lakeAreas[wpyTab]
              .refreshController
              .loadFailed();
        },
      );
    }
  }

  void listToTop() {
    if (context.read<LakeModel>().lakeAreas[wpyTab].controller.offset > 1500) {
      context.read<LakeModel>().lakeAreas[wpyTab].controller.jumpTo(1500);
    }
    context.read<LakeModel>().lakeAreas[wpyTab].controller.animateTo(-85,
        duration: Duration(milliseconds: 400), curve: Curves.easeOutCirc);
  }

  @override
  void initState() {
    if (wpyTab.name == '青年湖底')
      context.read<FbHotTagsProvider>().initHotTags();
    _departmentsProvider =
        Provider.of<FbDepartmentsProvider>(context, listen: false);
    context.read<LakeModel>().initLakeArea(wpyTab, rController, sController);
    context
        .read<LakeModel>()
        .checkTokenAndGetPostList(_departmentsProvider, wpyTab, success: () {
      getRecTag();
    }, failure: (e) {
      ToastProvider.error(e.error.toString());
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final status =
        context.select((LakeModel model) => model.lakeAreas[wpyTab].status);

    if (status == LakePageStatus.idle)
      return NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: rController,
          header: ClassicHeader(
            completeDuration: Duration(milliseconds: 300),
          ),
          enablePullDown: true,
          onRefresh: onRefresh,
          footer: ClassicFooter(),
          enablePullUp: true,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: sController,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: context.select((LakeModel model) =>
                model.lakeAreas[wpyTab].dataList.values.toList().length),
            itemBuilder: (context, ind) {
              return Builder(builder: (context) {
                if (wpyTab.name == '青年湖底' && ind == 0) {
                  ind--;
                  return HotCard();
                }
                final post = context
                    .read<LakeModel>()
                    .lakeAreas[wpyTab]
                    .dataList
                    .values
                    .toList()[ind];
                return PostCard.simple(post, key: ValueKey(post.id));
              });
            },
          ),
        ),
        // onNotification: (ScrollNotification scrollInfo) =>
        //     _onScrollNotification(scrollInfo),
      );
    else if (status == LakePageStatus.unload)
      return SizedBox();
    else if (status == LakePageStatus.error)
      return HomeErrorContainer(onRefresh, true, wpyTab);
    else
      return Loading();
  }
}

class HomeErrorContainer extends StatefulWidget {
  final void Function(AnimationController) onPressed;
  final bool networkFailPageUsage;
  final WPYTab wpyTab;

  HomeErrorContainer(this.onPressed, this.networkFailPageUsage, this.wpyTab);

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
              _listProvider.initPostList(widget.wpyTab, success: () {
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
