import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/search_bar.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';

class FeedbackHomePage extends StatefulWidget {
  @override
  _FeedbackHomePageState createState() => _FeedbackHomePageState();
}

enum FeedbackHomePageStatus {
  loading,
  idle,
  error,
}

class _FeedbackHomePageState extends State<FeedbackHomePage>
    with AutomaticKeepAliveClientMixin {
  int currentPage = 1, _totalPage = 1;
  FeedbackHomePageStatus status;

  // search bar position
  List<Post> _postList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _onRefresh([AnimationController controller]) {
    currentPage = 1;
    FeedbackService.getToken(onResult: (_) {
      Provider.of<FbTagsProvider>(context, listen: false).initTags();
      _initPostList(onSuccess: () {
        controller?.dispose();
        _refreshController.refreshCompleted();
      }, onError: () {
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
    if (currentPage != _totalPage) {
      currentPage++;
      FeedbackService.getPosts(
        tagId: '',
        page: currentPage,
        onSuccess: (list, page) {
          _totalPage = page;
          _postList.addAll(list);
          _refreshController.loadComplete();
          setState(() {});
        },
        onFailure: (_) {
          _refreshController.loadFailed();
        },
      );
    } else {
      _refreshController.loadNoData();
    }
  }

  _initPostList({Function onSuccess, Function onError}) {
    FeedbackService.getPosts(
      tagId: '',
      page: '1',
      onSuccess: (postList, totalPage) {
        _postList.clear();
        _postList.addAll(postList);
        print(postList.first.toJson());
        _totalPage = totalPage;
        onSuccess?.call();
        setState(() {
          status = FeedbackHomePageStatus.idle;
        });
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        onError?.call();
        setState(() {
          status = FeedbackHomePageStatus.error;
        });
      },
    );
  }

  _checkTokenAndGetPostList() async {
    if (CommonPreferences().feedbackToken.value == "") {
      await FeedbackService.getToken(
        onResult: (token) {
          CommonPreferences().feedbackToken.value = token;
          _initPostList();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          setState(() {
            status = FeedbackHomePageStatus.error;
          });
        },
      );
    } else {
      _initPostList();
    }
  }

  @override
  void initState() {
    currentPage = 1;
    status = FeedbackHomePageStatus.loading;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<FbTagsProvider>(context, listen: false).initTags();
      _checkTokenAndGetPostList();
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
        onPressed: () {
          Navigator.pushNamed(
            context,
            FeedbackRouter.profile,
          );
        },
      ),
      tapField: () {
        Navigator.pushNamed(context, FeedbackRouter.search);
      },
    );

    var listView = SmartRefresher(
      physics: BouncingScrollPhysics(),
      controller: _refreshController,
      header: ClassicHeader(),
      enablePullDown: true,
      onRefresh: _onRefresh,
      footer: ClassicFooter(),
      enablePullUp: currentPage != _totalPage,
      onLoading: _onLoading,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return searchBar;
          }
          index--;
          return PostCard.simple(_postList[index]);
        },
        itemCount: _postList.length,
      ),
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
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: WePeiYangApp.paddingTop),
              child: listView,
            ),
            if (status == FeedbackHomePageStatus.loading) Loading(),
            if (status == FeedbackHomePageStatus.error)
              HomeErrorContainer(_onRefresh),
          ],
        ),
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
