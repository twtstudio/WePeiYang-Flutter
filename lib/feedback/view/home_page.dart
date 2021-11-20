import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

class FeedbackHomePage extends StatefulWidget {
  @override
  _FeedbackHomePageState createState() => _FeedbackHomePageState();
}

class _FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin {
  FbHomeListModel _listProvider;
  FbTagsProvider _tagsProvider;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _onRefresh([AnimationController controller]) {
    FeedbackService.getToken(onResult: (_) {
      _tagsProvider.initTags();
      _listProvider.initPostList(success: () {
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
      _tagsProvider.initTags();
      _listProvider.checkTokenAndGetPostList(failure: (e) {
        ToastProvider.error(e.error.toString());
      });
    });
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
        onRefresh: _onRefresh,
        footer: ClassicFooter(),
        enablePullUp: !model.isLastPage,
        onLoading: _onLoading,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: model.homeList.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return searchBar;
            } else if (index == 1) {
              return SearchTypeSwitchBar(
                  controller: _refreshController, provider: _listProvider);
            }
            index -= 2;
            final post = model.homeList[index];
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
            if (status.isError) HomeErrorContainer(_onRefresh),
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
