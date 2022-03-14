import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';

class NSubPage extends StatefulWidget {
  final int index;
  final int total;

  const NSubPage({Key key, this.index, this.total}) : super(key: key);

  @override
  _NSubPageState createState() => _NSubPageState(this.index);
}

class _NSubPageState extends State<NSubPage>
    with AutomaticKeepAliveClientMixin {
  int index;
  FbHomeListModel _listProvider;
  FbDepartmentsProvider _tagsProvider;
  FbHotTagsProvider _hotTagsProvider;
  FbHomePageStatus _homePageStatus;

  _NSubPageState(this.index);

  bool _initialRefresh;

  List<RefreshController> _refreshController;
  List<ScrollController> _controller;

  getHotList() {
    _hotTagsProvider.initHotTags(success: () {
      _refreshController[index].refreshCompleted();
    }, failure: (e) {
      ToastProvider.error(e.error.toString());
      _refreshController[index].refreshFailed();
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
      context.read<TabNotifier>().initTabList();
      //getRecTag();
      if (index == 2) getHotList();
      print('ehgfcuagvjsdhcgvaudsfcsesvffdfgrgvrgrfgvrgv');
      print(index);
      _listProvider.initPostList(index, success: () {
        _refreshController[index].refreshCompleted();
      }, failure: (_) {
        controller?.stop();
        _refreshController[index].refreshFailed();
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
      controller?.stop();
      _refreshController[index].refreshFailed();
    });
  }

  _onLoading() {
    if (_listProvider == null ? true : _listProvider.isLastPage) {
      _refreshController[index].loadNoData();
    } else {
      _listProvider.getNextPage(
        index,
        success: () {
          _refreshController[index].loadComplete();
        },
        failure: (e) {
          _refreshController[index].loadFailed();
        },
      );
    }
  }

  void listToTop() {
    if (_controller[index].offset > 1500) {
      _controller[index].jumpTo(1500);
    }
    _controller[index].animateTo(-85,
        duration: Duration(milliseconds: 400), curve: Curves.easeOutCirc);
  }

  @override
  void initState() {
    _tagsProvider = Provider.of<FbDepartmentsProvider>(context, listen: false);
    _refreshController = List.filled(widget.total, RefreshController());
    _controller = List.filled(widget.total, ScrollController());
    context
        .read<FbHomeListModel>()
        .checkTokenAndGetPostList(_tagsProvider, index, success: () {
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
    if (_initialRefresh ?? false) {
      if (_controller[index].hasClients) listToTop();
      _initialRefresh = false;
    }
    super.build(context);
    return Selector<FbHomeStatusNotifier, FbHomePageStatus>(
        selector: (BuildContext context, FbHomeStatusNotifier notifier) {
            if (index >= notifier.status.length) {
              for (int i = notifier.status.length; i < index; i++)
                notifier.status.add(FbHomePageStatus.unload);
              notifier.status.add(FbHomePageStatus.idle);
            }
          return notifier.status[index];
        },
        builder: (_, status, __) {
          _homePageStatus = status;
          if (status == FbHomePageStatus.idle)
            return Consumer<FbHomeListModel>(builder: (_, model, __) {
              return NotificationListener<ScrollNotification>(
                child: SmartRefresher(
                  physics: BouncingScrollPhysics(),
                  controller: _refreshController[index],
                  header: ClassicHeader(
                    completeDuration: Duration(milliseconds: 300),
                  ),
                  enablePullDown: true,
                  onRefresh: onRefresh,
                  footer: ClassicFooter(),
                  enablePullUp: !model.isLastPage,
                  onLoading: _onLoading,
                  child: ListView.builder(
                    controller: _controller[index],
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: model.list == null
                        ? 0
                        : model.list[index].values.toList().length,
                    itemBuilder: (context, ind) {
                      final post = model.list[index].values.toList()[ind];
                      return Container(
                          color: Color.fromRGBO(index * 50, 100, 100, 1),
                          padding: EdgeInsets.all(3),
                          child: PostCard.simple(post, key: ValueKey(post.id)));
                    },
                  ),
                ),
                // onNotification: (ScrollNotification scrollInfo) =>
                //     _onScrollNotification(scrollInfo),
              );
            });
          else if (status == FbHomePageStatus.loading)
            return Loading();
          else if (status == FbHomePageStatus.unload)
            return SizedBox();
          else
            return HomeErrorContainer(onRefresh, true);
        });
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
              _listProvider.initPostList(2, success: () {
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
