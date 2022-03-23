import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/message/network/message_service.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'model/message_model.dart';

///枚举MessageType，每个type都是tabView -> list -> item的层次
enum MessageType { like, floor, reply, notice }

extension MessageTypeExtension on MessageType {
  String get name => ['点赞', '评论', '校务回复', '湖底通知'][this.index];

  List<MessageType> get others {
    List<MessageType> result = [];
    MessageType.values.forEach((element) {
      if (element != this) result.add(element);
    });
    return result;
  }
}

class FeedbackMessagePage extends StatefulWidget {
  @override
  _FeedbackMessagePageState createState() => _FeedbackMessagePageState();
}

class _FeedbackMessagePageState extends State<FeedbackMessagePage>
    with TickerProviderStateMixin {
  final List<MessageType> types = MessageType.values;

  TabController _tabController;

  ValueNotifier<int> currentIndex = ValueNotifier(0);
  ValueNotifier<int> refresh = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: types.length, vsync: this, initialIndex: 0)
          ..addListener(() {
            ///这个if避免点击tab时回调两次
            ///https://blog.csdn.net/u010960265/article/details/104982299
            if (_tabController.index.toDouble() ==
                _tabController.animation.value) {
              currentIndex.value = _tabController.index;
            }
          });
  }

  onRefresh() {
    context.read<MessageProvider>().refreshFeedbackCount();
    refresh.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f7f8),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          titleSpacing: 0,
          leadingWidth: 25,
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('消息中心',
              style: TextUtil.base.black2A.w500.NotoSansSC.sp(18)),
          leading: IconButton(
            icon: Image.asset('assets/images/lake_butt_icons/back.png',
                width: 14),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [IconButton(
        icon: Image.asset('assets/images/lake_butt_icons/check-square.png',
            width: 15.w),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LakeDialogWidget(
                    title: '一键已读：',
                    titleTextStyle:
                    TextUtil.base.normal.black2A.NotoSansSC.sp(18).w600,
                    content: Text('这将清除所有的消息提醒'),
                    cancelText: "取消",
                    confirmTextStyle:
                    TextUtil.base.normal.white.NotoSansSC.sp(16).w600,
                    cancelTextStyle:
                    TextUtil.base.normal.black2A.NotoSansSC.sp(16).w400,
                    confirmText: "确认",
                    cancelFun: () {
                      Navigator.pop(context);
                    },
                    confirmFun: () async {
                      await context.read<MessageProvider>().setAllMessageRead();
                      setState(() {
                      });
                      Navigator.pop(context);
                    },
                    confirmButtonColor: ColorUtil.selectionButtonColor,
                  );
                });
          })],
          bottom: PreferredSize(
            preferredSize: Size.infinite,
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                indicatorPadding: EdgeInsets.only(bottom: 10),
                labelPadding: EdgeInsets.zero,
                isScrollable: false,
                physics: BouncingScrollPhysics(),
                controller: _tabController,
                labelColor: ColorUtil.black2AColor,
                labelStyle: TextUtil.base.black2A.w500.NotoSansSC.sp(16),
                unselectedLabelColor: ColorUtil.greyB2B6Color,
                unselectedLabelStyle:
                    TextUtil.base.greyB2.w500.NotoSansSC.sp(16),
                indicator: CustomIndicator(
                    borderSide:
                        BorderSide(color: ColorUtil.mainColor, width: 2)),
                tabs: types.map((t) {
                  return MessageTab(type: t);
                }).toList(),
                onTap: (index) {
                  currentIndex.value = _tabController.index;
                },
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: types.map((t) {
          switch (t) {
            case MessageType.like:
              return LikeMessagesList();
            case MessageType.floor:
              return FloorMessagesList();
            case MessageType.reply:
              return ReplyMessagesList();
            case MessageType.notice:
              return NoticeMessagesList();
            default:
              return Container();
          }
        }).toList(),
      ),
    );
  }
}

class MessageTab extends StatefulWidget {
  final MessageType type;

  const MessageTab({Key key, this.type}) : super(key: key);

  @override
  _MessageTabState createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  _FeedbackMessagePageState pageState;
  double _tabPaddingWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pageState = context.findAncestorStateOfType<_FeedbackMessagePageState>();
  }

  @override
  Widget build(BuildContext context) {
    _tabPaddingWidth = MediaQuery.of(context).size.width / 30;
    Widget tab = ValueListenableBuilder(
      valueListenable: pageState.currentIndex,
      builder: (_, int current, __) {
        return Text(
          widget.type.name,
        );
      },
    );

    int count = context.select((MessageProvider messageProvider) =>
        messageProvider.getMessageCount(widget.type));
    return Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: _tabPaddingWidth),
        count == 0
            ? tab
            : Badge(
                child: tab,
                badgeContent: Text(
                  count.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 8),
                )),
        SizedBox(width: _tabPaddingWidth),
      ],
    ));
  }
}

class LikeMessagesList extends StatefulWidget {
  LikeMessagesList({Key key}) : super(key: key);

  @override
  _LikeMessagesListState createState() => _LikeMessagesListState();
}

class _LikeMessagesListState extends State<LikeMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<LikeMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
    if (widget == null) return;
    // monitor network fetch
    try {
      await MessageService.getLikeMessages(
          page: 1,
          onSuccess: (list, total) {
            items.clear();
            items.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });

      if (mounted) {
        if (refreshCount) {
          context.read<MessageProvider>().refreshFeedbackCount();
        }
        setState(() {});
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  _onLoading() async {
    try {
      await MessageService.getLikeMessages(
          page: (items.length / 20).ceil() + 1,
          onSuccess: (list, total) {
            items.addAll(list);
            if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      if (mounted) setState(() {});
    } catch (e) {
      _refreshController.loadFailed();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MessageService.getLikeMessages(
          page: 1,
          onSuccess: (list, total) {
            items.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      if (mounted) {
        context.read<MessageProvider>().refreshFeedbackCount();
        setState(() {});
        context
            .findAncestorStateOfType<_FeedbackMessagePageState>()
            .refresh
            .addListener(() =>
            onRefresh(
              refreshCount: false,
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    if (_refreshController.isRefresh) {
      child = Center(
        child: Loading(),
      );
    } else if (items.isEmpty) {
      child = Center(
        child: Text("无未读消息"),
      );
    } else {
      child = ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          return LikeMessageItem(
            data: items[i],
            onTapDown: () async {
              await MessageService.setLikeMessageRead(
                  items[i].type == 0 ? items[i].post.id : items[i].floor.id,
                  items[i].type,
                  onSuccess: () {
                    // items.removeAt(i); 会出问题 不能这么搞 目前先刷新处理了
                  }, onFailure: (e) {
                ToastProvider.error(e.error.toString());
              });
            },
          );
        },
        itemCount: items.length,
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(S.current.up_load);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(S.current.load_fail);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(S.current.load_more);
          } else {
            body = Text(S.current.no_more_data);
          }
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LikeMessageItem extends StatefulWidget {
  final LikeMessage data;
  final VoidFutureCallBack onTapDown;

  const LikeMessageItem({Key key, this.data, this.onTapDown}) : super(key: key);

  @override
  _LikeMessageItemState createState() => _LikeMessageItemState();
}

class _LikeMessageItemState extends State<LikeMessageItem> {
  Post post;
  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FeedbackService.getPostById(
          id: widget.data.type == 0 ? widget.data.post.id : widget.data.floor.postId,
          onResult: (result) {
            post = result;
            setState(() {});
          },
          onFailure: (e) {
            post = Post();
            post.title = '这个冒泡淹没在了湖底，找不到了';
            post.id = -1;
            setState(() {});
          });
    });
  }

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => Loading();

  @override
  Widget build(BuildContext context) {
    Widget sender = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.network(
          '${EnvConfig.QNHD}avatar/beam/20/${widget.data.type == 0 ? widget.data.post.id : widget.data.floor.id}+${widget.data.floor.nickname}',
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          placeholderBuilder: defaultPlaceholderBuilder,
        ),
        SizedBox(width: 6.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${S.current.anonymous_user} ',
                  style: TextUtil.base.black00.w500.sp(16).NotoSansSC,
                ),
                Text(
                  '为你点赞',
                  style: TextUtil.base.black00.w400.sp(16).NotoSansSC,
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              '某时某刻',
              style: TextUtil.base.sp(12).NotoSansSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget pointText = Text(
      ' · ',
      style: TextUtil.base.grey6C.w400.NotoSansSC.sp(24),
    );

    Widget likeFloorFav = Row(
      children: [
        Text(
          post == null ? '0' : post.likeCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 点赞',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
        pointText,
        Text(
          post == null ? '0' : post.commentCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 评论',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
        pointText,
        Text(
          post == null ? '0' : post.favCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 收藏',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
      ],
    );

    Widget questionItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        color: widget.data.type == 0
            ? ColorUtil.greyF7F8Color
            : ColorUtil.whiteFDFE,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post == null ? '...' : post.title,
                  maxLines: 2,
                  softWrap: true,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.blue363C,
                ),
                SizedBox(height: 6.w),
                likeFloorFav,
              ],
            ),
            if (widget.data.type == 0 && widget.data.post.imageUrls.isNotEmpty)
              Image.network(
                baseUrl + widget.data.post.imageUrls[0],
                fit: BoxFit.cover,
                height: 50,
                width: 70,
              ),
          ],
        ),
      ),
    );

    if (widget.data.type == 1) {
      questionItem = Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
            color: ColorUtil.greyF7F8Color,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.floor.nickname + ': ' + widget.data.floor.content,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.blue363C,
                ),
                SizedBox(height: 8.w),
                questionItem,
              ],
            ),
          ));
    }

    Widget messageWrapper = Badge(
      position: BadgePosition.topEnd(end: -2, top: -14),
      padding: const EdgeInsets.all(5),
      badgeContent: Text(""),
      child: questionItem,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 2.w, 16.w, 14.w),
      child: GestureDetector(
        onTap: () async {
          await widget.onTapDown?.call();

          ///因为跳转到评论页面其实感觉不太舒服...就先都跳转到帖子了
          if (post.id != -1) {
            await Navigator.pushNamed(
              context,
              FeedbackRouter.detail,
              arguments: post,
            ).then((_) => context
                .findAncestorStateOfType<_FeedbackMessagePageState>()
                .onRefresh());
          }
          // else {
          //   await Navigator.pushNamed(
          //     context,
          //     FeedbackRouter.commentDetail,
          //     arguments: widget.data.floor,
          //   ).then((_) => context
          //       .findAncestorStateOfType<_FeedbackMessagePageState>()
          //       .onRefresh());
          // }
        },
        child: Container(
          decoration: BoxDecoration(
              color: ColorUtil.whiteFDFE,
              borderRadius: BorderRadius.all(Radius.circular(16.w))),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                sender,
                SizedBox(height: 8.w),
                messageWrapper ?? questionItem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FloorMessagesList extends StatefulWidget {
  FloorMessagesList({Key key}) : super(key: key);

  @override
  _FloorMessagesListState createState() => _FloorMessagesListState();
}

class _FloorMessagesListState extends State<FloorMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<FloorMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
    if (widget == null) return;
    // monitor network fetch
    try {
      await MessageService.getFloorMessages(
          page: 1,
          onSuccess: (list, total) {
            items.clear();
            items.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });

      if (mounted) {
        if (refreshCount) {
          context.read<MessageProvider>().refreshFeedbackCount();
        }
        setState(() {});
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  _onLoading() async {
    try {
      await MessageService.getFloorMessages(
          page: (items.length / 20).ceil() + 1,
          onSuccess: (list, total) {
            items.addAll(list);
            if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      if (mounted) setState(() {});
    } catch (e) {
      _refreshController.loadFailed();
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    if (_refreshController.isRefresh) {
      child = Center(
        child: Loading(),
      );
    } else if (items.isEmpty) {
      child = Center(
        child: Text("无未读消息"),
      );
    } else {
      child = ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          return FloorMessageItem(
            data: items[i],
            onTapDown: () async {
              if (!items[i].isRead) {
                await MessageService.setFloorMessageRead(items[i].floor.id,
                    onSuccess: () {
                      items[i].isRead = true;
                      context.read<MessageProvider>().refreshFeedbackCount();
                    }, onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                });
              }
            },
          );
        },
        itemCount: items.length,
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(S.current.up_load);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(S.current.load_fail);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(S.current.load_more);
          } else {
            body = Text(S.current.no_more_data);
          }
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FloorMessageItem extends StatefulWidget {
  final FloorMessage data;
  final VoidFutureCallBack onTapDown;

  const FloorMessageItem({Key key, this.data, this.onTapDown})
      : super(key: key);

  @override
  _FloorMessageItemState createState() => _FloorMessageItemState();
}

class _FloorMessageItemState extends State<FloorMessageItem> {
  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb';

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => Loading();

  @override
  Widget build(BuildContext context) {
    Widget sender = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.network(
          '${EnvConfig.QNHD}avatar/beam/20/${widget.data.post.id}+${widget.data.floor.nickname}',
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          placeholderBuilder: defaultPlaceholderBuilder,
        ),
        SizedBox(width: 6.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.data.floor.nickname + ' ',
                  style: TextUtil.base.black00.w500.sp(16).NotoSansSC,
                ),
                Text(
                  widget.data.type == 0 ? '回复了你的冒泡' : '回复了你的评论',
                  style: TextUtil.base.black00.w400.sp(16).NotoSansSC,
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              DateTime.now().difference(widget.data.floor.createAt).inDays >= 1
                  ? widget.data.floor.createAt
                      .toLocal()
                      .toIso8601String()
                      .replaceRange(10, 11, ' ')
                      .substring(0, 19)
                  : DateTime.now()
                      .difference(widget.data.floor.createAt)
                      .dayHourMinuteSecondFormatted(),
              style: TextUtil.base.sp(12).NotoSansSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget pointText = Text(
      ' · ',
      style: TextUtil.base.grey6C.w400.NotoSansSC.sp(24),
    );

    Widget likeFloorFav = Row(
      children: [
        Text(
          widget.data.post.likeCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 点赞',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.commentCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 评论',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.favCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 收藏',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
      ],
    );

    Widget questionItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        color: widget.data.type == 0
            ? ColorUtil.greyF7F8Color
            : ColorUtil.whiteFDFE,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.post.title,
                  maxLines: 2,
                  softWrap: true,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.blue363C,
                ),
                SizedBox(height: 6.w),
                likeFloorFav,
              ],
            ),
            if (widget.data.post.imageUrls.isNotEmpty)
              Image.network(
                baseUrl + widget.data.post.imageUrls[0],
                fit: BoxFit.cover,
                height: 50,
                width: 70,
              ),
          ],
        ),
      ),
    );

    if (widget.data.type == 1) {
      questionItem = Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
            color: ColorUtil.greyF7F8Color,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.toFloor.nickname +
                      ': ' +
                      widget.data.toFloor.content,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.blue363C,
                ),
                SizedBox(height: 8.w),
                questionItem,
              ],
            ),
          ));
    }

    Widget messageWrapper;
    if (!widget.data.isRead) {
      messageWrapper = Badge(
        position: BadgePosition.topEnd(end: -2, top: -14),
        padding: const EdgeInsets.all(5),
        badgeContent: Text(""),
        child: questionItem,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 2.w, 16.w, 14.w),
      child: GestureDetector(
        onTap: () async {
          await widget.onTapDown?.call();

          ///因为跳转到评论页面其实感觉不太舒服...就先都跳转到帖子了
          // if (widget.data.type == 0) {
          await Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: widget.data.post,
          ).then((_) =>
              context.read<MessageProvider>().refreshFeedbackCount());
          // }
          // else {
          //   await Navigator.pushNamed(
          //     context,
          //     FeedbackRouter.commentDetail,
          //     arguments: widget.data.floor,
          //   ).then((_) => context
          //       .findAncestorStateOfType<_FeedbackMessagePageState>()
          //       .onRefresh());
          // }
        },
        child: Container(
          decoration: BoxDecoration(
              color: ColorUtil.whiteFDFE,
              borderRadius: BorderRadius.all(Radius.circular(16.w))),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sender,
                SizedBox(height: 7.w),
                Text(
                  widget.data.floor.content,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.black00,
                ),
                SizedBox(height: 8.w),
                messageWrapper ?? questionItem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReplyMessagesList extends StatefulWidget {
  ReplyMessagesList({Key key}) : super(key: key);

  @override
  _ReplyMessagesListState createState() => _ReplyMessagesListState();
}

class _ReplyMessagesListState extends State<ReplyMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<ReplyMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
    if (widget == null) return;
    // monitor network fetch
    try {
      await MessageService.getReplyMessages(
          page: 1,
          onSuccess: (list, total) {
            items.clear();
            items.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });

      if (mounted) {
        if (refreshCount) {
          context.read<MessageProvider>().refreshFeedbackCount();
        }
        setState(() {});
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  _onLoading() async {
    try {
      await MessageService.getReplyMessages(
          page: (items.length / 20).ceil() + 1,
          onSuccess: (list, total) {
            items.addAll(list);
            if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      if (mounted) setState(() {});
    } catch (e) {
      _refreshController.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    if (_refreshController.isRefresh) {
      child = Center(
        child: Loading(),
      );
    } else if (items.isEmpty) {
      child = Center(
        child: Text("无未读消息"),
      );
    } else {
      child = ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          return ReplyMessageItem(
            data: items[i],
            onTapDown: () async {
              if (!items[i].isRead) {
                await MessageService.setReplyMessageRead(items[i].reply.id,
                    onSuccess: () {
                      items[i].isRead = true;
                      context.read<MessageProvider>().refreshFeedbackCount();
                      }, onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                });
              }
            },
          );
        },
        itemCount: items.length,
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(S.current.up_load);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(S.current.load_fail);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(S.current.load_more);
          } else {
            body = Text(S.current.no_more_data);
          }
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReplyMessageItem extends StatefulWidget {
  final ReplyMessage data;
  final VoidFutureCallBack onTapDown;

  const ReplyMessageItem({Key key, this.data, this.onTapDown})
      : super(key: key);

  @override
  _ReplyMessageItemState createState() => _ReplyMessageItemState();
}

class _ReplyMessageItemState extends State<ReplyMessageItem> {
  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb';

  @override
  Widget build(BuildContext context) {
    Widget sender = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/school.png',
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        ),
        SizedBox(width: 6.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '官方部门 ',
                  style: TextUtil.base.black00.w500.sp(16).NotoSansSC,
                ),
                Text(
                  '回复了你的问题',
                  style: TextUtil.base.black00.w400.sp(16).NotoSansSC,
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              DateTime.now().difference(widget.data.reply.createdAt).inDays >= 1
                  ? widget.data.reply.createdAt
                      .toLocal()
                      .toIso8601String()
                      .replaceRange(10, 11, ' ')
                      .substring(0, 19)
                  : DateTime.now()
                      .difference(widget.data.reply.createdAt)
                      .dayHourMinuteSecondFormatted(),
              style: TextUtil.base.sp(12).NotoSansSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget pointText = Text(
      ' · ',
      style: TextUtil.base.grey6C.w400.NotoSansSC.sp(24),
    );

    Widget likeFloorFav = Row(
      children: [
        Text(
          widget.data.post.likeCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 点赞',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.commentCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 评论',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.favCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 收藏',
          style: TextUtil.base.grey6C.w400.NotoSansSC.sp(14),
        ),
      ],
    );

    Widget questionItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        color: ColorUtil.greyF7F8Color,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.post.title,
                  maxLines: 2,
                  softWrap: true,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.blue363C,
                ),
                SizedBox(height: 6.w),
                likeFloorFav,
              ],
            ),
            if (widget.data.post.imageUrls.isNotEmpty)
              Image.network(
                baseUrl + widget.data.post.imageUrls[0],
                fit: BoxFit.cover,
                height: 50,
                width: 70,
              ),
          ],
        ),
      ),
    );

    Widget messageWrapper;
    if (!widget.data.isRead) {
      messageWrapper = Badge(
        position: BadgePosition.topEnd(end: -2, top: -14),
        padding: const EdgeInsets.all(5),
        badgeContent: Text(""),
        child: questionItem,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 2.w, 16.w, 14.w),
      child: GestureDetector(
        onTap: () async {
          await widget.onTapDown?.call();

          await Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: widget.data.post,
          ).then((_) =>
              context.read<MessageProvider>().refreshFeedbackCount());
        },
        child: Container(
          decoration: BoxDecoration(
              color: ColorUtil.whiteFDFE,
              borderRadius: BorderRadius.all(Radius.circular(16.w))),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sender,
                SizedBox(height: 7.w),
                Text(
                  widget.data.reply.content,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.black00,
                ),
                SizedBox(height: 8.w),
                messageWrapper ?? questionItem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoticeMessagesList extends StatefulWidget {
  NoticeMessagesList({Key key}) : super(key: key);

  @override
  _NoticeMessagesListState createState() => _NoticeMessagesListState();
}

class _NoticeMessagesListState extends State<NoticeMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<NoticeMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
    if (widget == null) return;
    // monitor network fetch
    try {
      await MessageService.getNoticeMessages(
          page: 1,
          onSuccess: (list, total) {
            items.clear();
            items.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });

      if (mounted) {
        if (refreshCount) {
          context.read<MessageProvider>().refreshFeedbackCount();
        }
        setState(() {});
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  _onLoading() async {
    try {
      await MessageService.getNoticeMessages(
          page: (items.length / 20).ceil() + 1,
          onSuccess: (list, total) {
            items.addAll(list);
            if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      if (mounted) setState(() {});
    } catch (e) {
      _refreshController.loadFailed();
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    if (_refreshController.isRefresh) {
      child = Center(
        child: Loading(),
      );
    } else if (items.isEmpty) {
      child = Center(
        child: Text("无未读消息"),
      );
    } else {
      child = ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          return NoticeMessageItem(
            data: items[i],
            onTapDown: () async {
              if (!items[i].isRead) {
                await MessageService.setNoticeMessageRead(items[i].id,
                    onSuccess: () {
                      items[i].isRead = true;
                      context.read<MessageProvider>().refreshFeedbackCount();
                    }, onFailure: (e) {
                  ToastProvider.error(e.error.toString());
                });
              }
            },
          );
        },
        itemCount: items.length,
      );
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(S.current.up_load);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(S.current.load_fail);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(S.current.load_more);
          } else {
            body = Text(S.current.no_more_data);
          }
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NoticeMessageItem extends StatefulWidget {
  final NoticeMessage data;
  final VoidFutureCallBack onTapDown;

  const NoticeMessageItem({Key key, this.data, this.onTapDown})
      : super(key: key);

  @override
  _NoticeMessageItemState createState() => _NoticeMessageItemState();
}

class _NoticeMessageItemState extends State<NoticeMessageItem> {

  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => Loading();

  @override
  Widget build(BuildContext context) {
    Widget sender = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.network(
          '${EnvConfig.QNHD}avatar/beam/20/${widget.data.id}',
          width: 30,
          height: 30,
          fit: BoxFit.cover,
          placeholderBuilder: defaultPlaceholderBuilder,
        ),
        SizedBox(width: 6.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.data.sender,
                  style: TextUtil.base.black00.w500.sp(16).NotoSansSC,
                ),
                Text(
                  ' 发表了一则通知',
                  style: TextUtil.base.black00.w400.sp(16).NotoSansSC,
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              DateTime.now().difference(widget.data.createdAt).inDays >= 1
                  ? widget.data.createdAt
                      .toLocal()
                      .toIso8601String()
                      .replaceRange(10, 11, ' ')
                      .substring(0, 19)
                  : DateTime.now()
                      .difference(widget.data.createdAt)
                      .dayHourMinuteSecondFormatted(),
              style: TextUtil.base.sp(12).NotoSansSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget noticeItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        color: ColorUtil.greyF7F8Color,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.title,
                  maxLines: 1,
                  softWrap: true,
                  style: TextUtil.base.sp(14).NotoSansSC.w400.blue363C,
                ),
                SizedBox(height: 4.w),
                Text(
                  widget.data.content,
                  maxLines: 2,
                  softWrap: true,
                  style: TextUtil.base.sp(12).NotoSansSC.w400.grey6C,
                )
              ],
            ),
          ],
        ),
      ),
    );

    Widget messageWrapper;
    if (!widget.data.isRead) {
      messageWrapper = Badge(
        position: BadgePosition.topEnd(end: -2, top: -14),
        padding: const EdgeInsets.all(5),
        badgeContent: Text(""),
        child: noticeItem,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 2.w, 16.w, 14.w),
      child: GestureDetector(
        onTap: () async {
          await widget.onTapDown?.call();
          await Navigator.pushNamed(
            context,
            FeedbackRouter.notice,
            arguments: widget.data,
          ).then((_) =>
              context.read<MessageProvider>().refreshFeedbackCount());
        },
        child: Container(
          decoration: BoxDecoration(
              color: ColorUtil.whiteFDFE,
              borderRadius: BorderRadius.all(Radius.circular(16.w))),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sender,
                SizedBox(height: 8.w),
                messageWrapper ?? noticeItem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String get time {
    var reg1 = RegExp(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}");
    var date = reg1.firstMatch(this)?.group(0) ?? "";
    var reg2 = RegExp(r"[0-9]{2}:[0-9]{2}");
    var time = reg2.firstMatch(this)?.group(0) ?? "";
    return "$date  $time";
  }
}

class CustomIndicator extends Decoration {
  const CustomIndicator({
    this.borderSide = const BorderSide(width: 2, color: Colors.white),
    this.insets = EdgeInsets.zero,
  })  : assert(borderSide != null),
        assert(insets != null);

  final BorderSide borderSide;

  final EdgeInsetsGeometry insets;

  @override
  Decoration lerpFrom(Decoration a, double t) {
    if (a is CustomIndicator) {
      return CustomIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration lerpTo(Decoration b, double t) {
    if (b is CustomIndicator) {
      return CustomIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    double wantWidth = 14;
    double cw = (indicator.left + indicator.right) / 2;

    return Rect.fromLTWH(
      cw - wantWidth / 2,
      indicator.bottom - borderSide.width,
      wantWidth,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  final CustomIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    final Rect indicator = decoration
        ._indicatorRectFor(rect, textDirection)
        .deflate(decoration.borderSide.width / 2);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
