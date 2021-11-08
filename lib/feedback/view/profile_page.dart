import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/profile_dialog.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/message_model.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';

import 'components/post_card.dart';
import 'components/profile_header.dart';

/// Almost the same as [UserPage].
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

enum _CurrentTab {
  myPosts,
  myCollect,
}

extension _CurrentTabb on _CurrentTab {
  _CurrentTab get change {
    var next = (this.index + 1) % 2;
    return _CurrentTab.values[next];
  }

  FeedbackMessageType get messageType {
    switch (this.index) {
      case 0:
        return FeedbackMessageType.detail_post;
      case 1:
        return FeedbackMessageType.detail_favourite;
      default:
        return FeedbackMessageType.detail_post;
    }
  }
}

extension PostListSortExtension on List<Post> {
  List<Post> sortWithMessage(List<MessageDataItem> list) {
    if (list == null) return this;
    List<Post> match = [];
    List<int> ids = list.map((e) => e.questionId).toList();
    List<Post> base = [...this];
    this.forEach((element) {
      if (ids.contains(element.id)) {
        match.add(element);
        base.remove(element);
      }
    });
    match.sort((a, b) => a.updatedTime.compareTo(b.updatedTime) * (-1));
    base.sort((a, b) => a.updatedTime.compareTo(b.updatedTime) * (-1));
    return [...match, ...base];
  }

  List<Post> sortNormal() =>
      this..sort((a, b) => a.updatedTime.compareTo(b.updatedTime) * (-1));
}

class _ProfilePageState extends State<ProfilePage> {
  ValueNotifier<_CurrentTab> _currentTab = ValueNotifier(_CurrentTab.myPosts);
  PageController _tabController;
  bool tap = false;

  @override
  void initState() {
    super.initState();
    _tabController = PageController(
      initialPage: 0,
    )..addListener(() {
        var absPosition = (_tabController.page - _currentTab.value.index).abs();
        if (absPosition > 0.5 && !tap) {
          _currentTab.value = _CurrentTab.values[_tabController.page.round()];
        }
      });
    _currentTab.addListener(() {
      tap = true;
      switch (_currentTab.value) {
        case _CurrentTab.myPosts:
          _tabController
              .animateToPage(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              )
              .then((value) => tap = false);
          break;
        case _CurrentTab.myCollect:
          _tabController
              .animateToPage(
                1,
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              )
              .then((value) => tap = false);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myPost = ProfileTabButton(
      type: _CurrentTab.myPosts,
      img: 'lib/feedback/assets/img/my_post.png',
      text: S.current.feedback_my_post,
    );

    var myFavor = ProfileTabButton(
      type: _CurrentTab.myCollect,
      img: 'lib/feedback/assets/img/my_favorite.png',
      text: S.current.feedback_my_favorite,
    );

    Widget tabs = Container(
      height: 140,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [myPost, myFavor],
          ),
        ),
      ),
    );

    Widget appBar = SliverToBoxAdapter(
      child: ProfileHeader(
        child: SliverToBoxAdapter(
          child: tabs,
        ),
      ),
    );

    var list = ExpandablePageView(
      controller: _tabController,
      children: [
        _PostList(key: PageStorageKey(0), type: _CurrentTab.myPosts),
        _PostList(key: PageStorageKey(1), type: _CurrentTab.myCollect)
      ],
    );

    // var list = Container();

    Widget body = ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: CustomScrollView(
        slivers: [
          appBar,
          SliverToBoxAdapter(child: SizedBox(height: 5)),
          SliverToBoxAdapter(child: list),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 247, 1.0),
      body: DefaultTextStyle(
        style: FontManager.YaHeiRegular,
        child: body,
      ),
    );
  }
}

class _PostList extends StatefulWidget {
  final _CurrentTab type;

  const _PostList({Key key, this.type}) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<_PostList> {
  List<Post> _postList = [];
  MessageProvider messageProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      messageProvider = Provider.of<MessageProvider>(context, listen: false);
      switch (widget.type) {
        case _CurrentTab.myPosts:
          _initMyPosts();
          break;
        case _CurrentTab.myCollect:
          _initMyCollects();
          break;
      }
    });
  }

  _initMyPosts() {
    FeedbackService.getMyPosts(onResult: (list) {
      setState(() {
        _addPostList(list);
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  _initMyCollects() {
    FeedbackService.getFavoritePosts(onResult: (list) {
      setState(() {
        _addPostList(list);
      });
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  _addPostList(List<Post> list) {
    var sortList = messageProvider.feedbackQs == null
        ? list.sortNormal()
        : list.sortWithMessage(messageProvider.feedbackQs);
    _postList = sortList;
  }

  _deletePostOnLongPressed(int index) {
    if (widget.type == _CurrentTab.myPosts)
      showDialog<bool>(
        context: context,
        builder: (context) => ProfileDialog(
          post: _postList[index],
          onConfirm: () => Navigator.pop(context, true),
          onCancel: () => Navigator.pop(context, false),
        ),
      ).then((confirm) {
        if (confirm) {
          FeedbackService.deletePost(
            id: _postList[index].id,
            onSuccess: () {
              _postList.removeAt(index);
              ToastProvider.success(S.current.feedback_delete_success);
              Provider.of<MessageProvider>(context, listen: false)
                  .refreshFeedbackCount();
              setState(() {
                _postList = List.from(_postList);
              });
            },
            onFailure: (e) {
              ToastProvider.error(e.error.toString());
            },
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_postList.length.isZero) {
      child = Container(
          height: 200,
          alignment: Alignment.center,
          child: Text("暂无提问", style: TextStyle(color: Color(0xff62677b))));
    } else {
      child = ListView.builder(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Widget post = PostCard.simple(
            _postList[index],
            onContentLongPressed: () => _deletePostOnLongPressed(index),
            showBanner: true,
            key: ValueKey(_postList[index].id),
          );
          return post;
        },
        itemCount: _postList.length,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .findAncestorStateOfType<_SizeReportingWidgetState>()
          ._notifySize();
    });
    return child;
  }
}

class ProfileTabButton extends StatefulWidget {
  final _CurrentTab type;
  final VoidCallback onTap;
  final String text;
  final String img;

  const ProfileTabButton({Key key, this.type, this.onTap, this.text, this.img})
      : super(key: key);

  @override
  _ProfileTabButtonState createState() => _ProfileTabButtonState();
}

class _ProfileTabButtonState extends State<ProfileTabButton> {
  @override
  Widget build(BuildContext context) {
    var currentType =
        context.findAncestorStateOfType<_ProfilePageState>()._currentTab;

    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: currentType,
        builder: (_, value, __) => InkWell(
          child: Column(
            children: [
              FeedbackBadgeWidget(
                type: widget.type.messageType,
                child: Image.asset(widget.img, height: 30),
              ),
              SizedBox(height: 5),
              Text(
                widget.text,
                style: FontManager.YaHeiRegular.copyWith(
                    height: 1, color: ColorUtil.lightTextColor),
              ),
              SizedBox(height: 5),
              ClipOval(
                child: Container(
                  width: 5,
                  height: 5,
                  color:
                      value == widget.type ? ColorUtil.mainColor : Colors.white,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          onTap: () {
            if (value == widget.type.change) {
              currentType.value = widget.type;
              widget.onTap?.call();
            }
          },
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return GlowingOverscrollIndicator(
      child: child,
      showLeading: false,
      showTrailing: true,
      color: Color(0XFF62677B),
      axisDirection: AxisDirection.down,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const ExpandablePageView({
    Key key,
    @required this.children,
    this.controller,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView>
    with TickerProviderStateMixin {
  PageController _pageController;
  List<double> _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = widget.controller ?? PageController() //
      ..addListener(() {
        final _newPage = _pageController.page.round();
        if (_currentPage != _newPage) {
          widget.onPageChanged?.call(_newPage);
          setState(() => _currentPage = _newPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: _heights[0], end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView(
        controller: _pageController,
        children: _sizeReportingChildren,
      ),
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap() //
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            //needed, so that parent won't impose its constraints on the children, thus skewing the measurement results.
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) =>
                  setState(() => _heights[index] = size?.height ?? 0),
              child: child,
            ),
          ),
        ),
      )
      .values
      .toList();
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key key,
    @required this.child,
    @required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget>
    with AutomaticKeepAliveClientMixin {
  Size _oldSize;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    final size = context?.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
