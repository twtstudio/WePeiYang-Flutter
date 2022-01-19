import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_type_switch_bar.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

class FeedbackHomePage extends StatefulWidget {
  FeedbackHomePage({Key key}) : super(key: key);

  @override
  FeedbackHomePageState createState() => FeedbackHomePageState();
}

class FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin {
  FbHomeListModel _listProvider;
  FbTagsProvider _tagsProvider;

  final ScrollController controller = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  onRefresh([AnimationController controller]) {
    FeedbackService.getToken(onResult: (_) {
      _tagsProvider.initTags();
      _listProvider.initPostList(success: () {
        controller?.dispose();
        _refreshController.refreshCompleted();
      }, failure: (_) {
        controller?.stop();
        _refreshController.refreshFailed();
      });
      getClipboardWeKoContents();
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
        success: () {
          _refreshController.loadComplete();
        },
        failure: (e) {
          _refreshController.loadFailed();
        },
      );
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
        if(!Provider.of<MessageProvider>(context, listen: false).feedbackHasViewed.contains(id)){
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
                    Navigator.pushNamed(context, FeedbackRouter.detail, arguments: post);
                    Provider.of<MessageProvider>(context, listen: false).setFeedbackWeKoHasViewed(id);
                  } else {
                    Provider.of<MessageProvider>(context, listen: false).setFeedbackWeKoHasViewed(id);
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
      _listProvider = Provider.of<FbHomeListModel>(context, listen: false);
      _tagsProvider = Provider.of<FbTagsProvider>(context, listen: false);
      _listProvider.checkTokenAndGetPostList(_tagsProvider, failure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
    getClipboardWeKoContents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var searchBar = SearchBar(
      rightWidget: IconButton(
        color: ColorUtil.mainColor,
        icon: FeedbackBadgeWidget(
          type: FeedbackMessageType.home,
          child: Image.asset('lib/feedback/assets/img/profile.png'),
        ),
        onPressed: () => Navigator.pushNamed(context, FeedbackRouter.profile),
      ),
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
                  searchBar,
                  SearchTypeSwitchBar(
                      controller: _refreshController, provider: _listProvider),
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
              padding: EdgeInsets.only(top: WePeiYangApp.paddingTop),
              child: listView,
            ),
            if (status.isLoading) Loading(),
            if (status.isError) HomeErrorContainer(onRefresh),
          ],
        );
      },
    );

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
        child: body,
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
