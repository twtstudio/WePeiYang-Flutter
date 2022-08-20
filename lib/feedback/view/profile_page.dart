import 'package:flutter/material.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/time_handler.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/profile_dialog.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/refresh_header.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';

import '../feedback_router.dart';
import 'components/post_card.dart';
import 'components/profile_header.dart';

/// Almost the same as [UserPage].
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

enum _CurrentTab {
  myPosts,
}

// extension _CurrentTabb on _CurrentTab {
//   _CurrentTab get change {
//     var next = (this.index + 1) % 2;
//     return _CurrentTab.values[next];
//   }
// }

class _ProfilePageState extends State<ProfilePage> {
  ValueNotifier<_CurrentTab> _currentTab = ValueNotifier(_CurrentTab.myPosts);
  PageController _tabController;
  List<Post> _postList = [];
  MessageProvider messageProvider;
  var _refreshController = RefreshController(initialRefresh: true);
  bool tap = false;
  int currentPage = 1;

  _getMyPosts({Function(List<Post>) onSuccess, Function onFail, int current}) {
    FeedbackService.getMyPosts(
        page: current ?? currentPage,
        page_size: 10,
        onResult: (list) {
          setState(() {
            onSuccess?.call(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail?.call();
        });
  }

  //刷新
  _onRefresh() {
    FeedbackService.getUserInfo(onSuccess: () {
      setState(() {});
    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
    currentPage = 1;
    _refreshController.resetNoData();
    _getMyPosts(onSuccess: (list) {
      _postList = list;
      _refreshController.refreshCompleted();
    }, onFail: () {
      _refreshController.refreshFailed();
    });
  }

//下拉加载
  _onLoading() {
    currentPage++;
    _getMyPosts(onSuccess: (list) {
      if (list.length == 0) {
        _refreshController.loadNoData();
        currentPage--;
      } else {
        _postList.addAll(list);
        _refreshController.loadComplete();
      }
    }, onFail: () {
      currentPage--;
      _refreshController.loadFailed();
    });
  }

  _deletePostOnLongPressed(int index) {
    if (_currentTab.value == _CurrentTab.myPosts)
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
              context.read<MessageProvider>().refreshFeedbackCount();
              setState(() {
                _refreshController.requestRefresh();
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///这两个被拆出去单写会刷新错误..
    ///postList栏，为空时显示无
    var postLists = (ListView.builder(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Widget post = PostCard.simple(
          _postList[index],
          onContentLongPressed: () => _deletePostOnLongPressed(index),
          showBanner: true,
          key: ValueKey(_postList[index].id),
          onContentPressed: () {
            Navigator.pushNamed(
              context,
              FeedbackRouter.detail,
              arguments: _postList[index],
            ).then((p) {
              _refreshController.requestRefresh();
            });
          },
        );
        return post;
      },
      itemCount: _postList.length,
    ));
    var postListShow;
    if (_postList.length.isZero) {
      postListShow = Container(
          height: 200,
          alignment: Alignment.center,
          child: Text("暂无冒泡", style: TextStyle(color: Color(0xff62677b))));
    } else {
      postListShow = Column(
        children: [
          postLists,
          SizedBox(
            height: 20.w,
          )
        ],
      );
    }
//静态header，头像和资料以及appbar
    Widget appBar = SliverToBoxAdapter(
      child: ProfileHeader(
        child: SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Spacer(),
                CustomCard(
                  image: 'assets/images/mymsg.png',
                  text: '消息中心',
                  onPressed: () {
                    Navigator.pushNamed(context, FeedbackRouter.mailbox);
                  },
                ),
                CustomCard(
                  image: 'assets/images/mylike.png',
                  text: '我的点赞',
                  onPressed: () {
                    Navigator.pushNamed(context, FeedbackRouter.mailbox);
                  },
                ),
                CustomCard(
                  image: 'assets/images/myfav.png',
                  text: '我的收藏',
                  onPressed: () {
                    Navigator.pushNamed(context, FeedbackRouter.collection);
                  },
                ),
                Spacer(),
              ],
            ),
          ),
        ),
        date: _postList.isEmpty
            ? "好久"
            : TimeHandler().timeHandler(_postList[0].createAt),
      ),
    );

    var list = ExpandablePageView(
      controller: _tabController,
      children: [
        postListShow,
      ],
    );

    // var list = Container();

    Widget body = CustomScrollView(
      slivers: [
        appBar,
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                color: Colors.white,
                child: list,
              ),
            ],
          ),
        )
      ],
    );

    return Container(
      //改背景色用
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color(0xFF2C7EDF),
                Color(0xFFA6CFFF),
                // 用来挡下面圆角左右的空
                Colors.white
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // 在0.7停止同理
              stops: [0, 0.23, 0.7])),
      child: SmartRefresher(
        physics: BouncingScrollPhysics(),
        controller: _refreshController,
        header: RefreshHeader(),
        footer: ClassicFooter(
          idleText: '没有更多数据了:>',
          idleIcon: Icon(Icons.check),
        ),
        enablePullDown: true,
        onRefresh: _onRefresh,
        enablePullUp: true,
        onLoading: _onLoading,
        child: body,
      ),
    );
  }
}

// class ProfileTabButton extends StatefulWidget {
//   final _CurrentTab type;
//   final VoidCallback onTap;
//   final String text;
//
//   const ProfileTabButton({
//     Key key,
//     this.type,
//     this.onTap,
//     this.text,
//   }) : super(key: key);
//
//   @override
//   _ProfileTabButtonState createState() => _ProfileTabButtonState();
// }
//
// class _ProfileTabButtonState extends State<ProfileTabButton> {
//   @override
//   Widget build(BuildContext context) {
//     var currentType =
//         context.findAncestorStateOfType<_ProfilePageState>()._currentTab;
//
//     return Expanded(
//       flex: 1,
//       child: ValueListenableBuilder(
//         valueListenable: currentType,
//         builder: (_, value, __) => InkWell(
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 2,
//               ),
//               Text(
//                 widget.text,
//                 style: FontManager.YaHeiRegular.copyWith(
//                     height: 1, color: ColorUtil.bold42TextColor),
//               ),
//               SizedBox(height: 5),
//               Container(
//                 decoration: BoxDecoration(
//                     color: value == widget.type
//                         ? ColorUtil.mainColor
//                         : ColorUtil.tagBackgroundColor,
//                     borderRadius: BorderRadius.all(Radius.circular(30))),
//                 width: 30,
//                 height: 4,
//               ),
//             ],
//             mainAxisAlignment: MainAxisAlignment.center,
//           ),
//           onTap: () {
//             if (value == widget.type.change) {
//               currentType.value = widget.type;
//               widget.onTap?.call();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
class CustomCard extends StatelessWidget {
  final String image;
  final String text;
  final Function onPressed;

  const CustomCard({Key key, this.image, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed?.call();
      },
      child: SizedBox(
        width: 125.w,
        height: 90.h,
        child: Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    image,
                    width: 24.w,
                  ),
                ],
              ),
              SizedBox(height: 7.h),
              Text(text,
                  maxLines: 1, style: TextUtil.base.w400.black2A.sp(12).medium),
            ],
          ),
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
  bool get wantKeepAlive => true;
}
