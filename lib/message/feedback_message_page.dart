import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/reply_detail_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/lake_email.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';
import 'package:we_pei_yang_flutter/message/network/message_service.dart';

import '../commons/widgets/w_button.dart';
import 'model/message_model.dart';
import 'package:badges/badges.dart' as badges;

///枚举MessageType，每个type都是tabView -> list -> item的层次
enum MessageType { like, floor, reply }

extension MessageTypeExtension on MessageType {
  String get name => ['点赞', '评论', '校务回复'][this.index];

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
  List<Widget> wd = [];
  List<Widget> tb = [];

  late TabController _tabController;

  ValueNotifier<int> currentIndex = ValueNotifier(0);
  ValueNotifier<int> refresh = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    wd.clear();
    tb.clear();
    _tabController =
        TabController(length: types.length + 1, vsync: this, initialIndex: 0)
          ..addListener(() {
            ///这个if避免点击tab时回调两次
            ///https://blog.csdn.net/u010960265/article/details/104982299
            if (_tabController.index.toDouble() ==
                _tabController.animation?.value) {
              currentIndex.value = _tabController.index;
            }
          });
    tb = types.map((t) {
      return MessageTab(type: t);
    }).toList();

    wd = types.map((t) {
      switch (t) {
        case MessageType.like:
          return LikeMessagesList();
        case MessageType.floor:
          return FloorMessagesList();
        case MessageType.reply:
          return ReplyMessagesList();
        default:
          return Container();
      }
    }).toList();
    wd.add(LakeEmailPage());
    tb.add(MessageTab(isEmail: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorUtil.whiteFDFE,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            titleSpacing: 0,
            leadingWidth: 50,
            backgroundColor: ColorUtil.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('消息中心',
                style: TextUtil.base.PingFangSC.bold.black2A.sp(18)),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: ColorUtil.bold42TextColor,
                size: 20.w,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                  icon: Image.asset(
                      'assets/images/lake_butt_icons/check-square.png',
                      width: 15.w),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LakeDialogWidget(
                            title: '一键已读：',
                            titleTextStyle: TextUtil
                                .base.normal.black2A.PingFangSC
                                .sp(18)
                                .w600,
                            content: Text('这将清除所有的消息提醒'),
                            cancelText: "取消",
                            confirmTextStyle: TextUtil
                                .base.normal.white.PingFangSC
                                .sp(16)
                                .w600,
                            cancelTextStyle: TextUtil
                                .base.normal.black2A.PingFangSC
                                .sp(16)
                                .w400,
                            confirmText: "确认",
                            cancelFun: () {
                              Navigator.pop(context);
                            },
                            confirmFun: () async {
                              await context
                                  .read<MessageProvider>()
                                  .setAllMessageRead();
                              setState(() {});
                              Navigator.pop(context);
                            },
                            confirmButtonColor: ColorUtil.selectionButtonColor,
                          );
                        });
                  })
            ],
            bottom: PreferredSize(
              preferredSize: Size.infinite,
              child: Theme(
                data: ThemeData(
                  splashColor: ColorUtil.transparent,
                  highlightColor: ColorUtil.transparent,
                ),
                child: TabBar(
                  indicatorWeight: 0,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.only(bottom: 10),
                  labelPadding: EdgeInsets.zero,
                  isScrollable: false,
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  labelColor: ColorUtil.blue2CColor,
                  labelStyle: TextUtil.base.bold.PingFangSC.sp(14),
                  unselectedLabelColor: ColorUtil.black2AColor,
                  unselectedLabelStyle:
                      TextUtil.base.black2A.w500.PingFangSC.sp(14),
                  indicator: CustomIndicator(
                      borderSide:
                          BorderSide(color: ColorUtil.blue2CColor, width: 2)),
                  tabs: tb,
                  onTap: (index) {
                    currentIndex.value = _tabController.index;
                  },
                ),
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: wd));
  }
}

class MessageTab extends StatefulWidget {
  final MessageType? type;
  final bool? isEmail;

  const MessageTab({Key? key, this.type, this.isEmail}) : super(key: key);

  @override
  _MessageTabState createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  late _FeedbackMessagePageState pageState;
  double _tabPaddingWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pageState = context.findAncestorStateOfType<_FeedbackMessagePageState>()!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmail ?? false) {
      int count = context.select((MessageProvider messageProvider) =>
          messageProvider.getMessageCount(isEmail: true));
      return Tab(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: _tabPaddingWidth),
          count == 0
              ? Text('湖底通知')
              : badges.Badge(
                  child: Text('湖底通知'),
                  badgeContent: Text(
                    count.toString(),
                    style: TextUtil.base.white.sp(8),
                  )),
          SizedBox(width: _tabPaddingWidth),
        ],
      ));
    } else {
      _tabPaddingWidth = MediaQuery.of(context).size.width / 30;
      Widget tab = ValueListenableBuilder(
        valueListenable: pageState.currentIndex,
        builder: (_, int current, __) {
          return Text(widget.type?.name ?? '');
        },
      );

      int count = context.select((MessageProvider messageProvider) =>
          messageProvider.getMessageCount(type: widget.type));
      return Tab(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: _tabPaddingWidth),
          count == 0
              ? tab
              : badges.Badge(
                  child: tab,
                  badgeContent: Text(
                    count.toString(),
                    style: TextUtil.base.white.sp(8),
                  )),
          SizedBox(width: _tabPaddingWidth),
        ],
      ));
    }
  }
}

class LikeMessagesList extends StatefulWidget {
  LikeMessagesList({Key? key}) : super(key: key);

  @override
  _LikeMessagesListState createState() => _LikeMessagesListState();
}

class _LikeMessagesListState extends State<LikeMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<LikeMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
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
            ?.refresh
            .addListener(() => onRefresh(refreshCount: false));
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
            key: Key(items.length.toString()),
            data: items[i],
            onTapDown: () async {
              await MessageService.setLikeMessageRead(
                  items[i].type == 0 ? items[i].post.id : items[i].floor.id,
                  items[i].type, onSuccess: () {
                items.removeAt(i);
                context.read<MessageProvider>().refreshFeedbackCount();
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
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text('加载完成:)');
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

  const LikeMessageItem({Key? key, required this.data, required this.onTapDown})
      : super(key: key);

  @override
  _LikeMessageItemState createState() => _LikeMessageItemState();
}

class _LikeMessageItemState extends State<LikeMessageItem> {
  Post? post;
  bool? success;

  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb/';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FeedbackService.getPostById(
          id: widget.data.type == 0
              ? widget.data.post.id
              : widget.data.floor.postId,
          onResult: (result) {
            post = result;
            success = true;
            setState(() {});
          },
          onFailure: (e) {
            success = false;
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
          '${EnvConfig.QNHD}avatar/beam/20/${widget.data.floor.nickname}',
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
                  '共计 ${widget.data.type == 1 ? widget.data.floor.likeCount : widget.data.post.likeCount}名用户 ',
                  style: TextUtil.base.black00.bold.sp(16).PingFangSC,
                ),
                Text(
                  '为你点赞',
                  style: TextUtil.base.black00.w400.sp(16).PingFangSC,
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              '某时某刻',
              style: TextUtil.base.sp(12).PingFangSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget pointText = Text(
      ' · ',
      style: TextUtil.base.grey6C.w400.PingFangSC.sp(24),
    );

    Widget likeFloorFav = Row(
      children: [
        Text(
          post?.likeCount.toString() ?? '0',
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 点赞',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
        pointText,
        Text(
          post?.commentCount.toString() ?? '0',
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 评论',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
        pointText,
        Text(
          post?.favCount.toString() ?? '0',
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 收藏',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
      ],
    );

    var text = '...'; // success为空代表请求未完成
    if (success == true) text = post!.title;
    if (success == false) text = '这个冒泡淹没在了湖底，找不到了';

    Widget questionItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        color: widget.data.type == 0
            ? ColorUtil.whiteF8Color
            : ColorUtil.whiteFDFE,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextUtil.base.sp(14).PingFangSC.w400.blue363C,
                  ),
                  SizedBox(height: 6.w),
                  likeFloorFav,
                ],
              ),
            ),
            if (post != null && success! && post!.imageUrls.isNotEmpty)
              Image.network(
                baseUrl + post!.imageUrls[0],
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
            color: ColorUtil.whiteF8Color,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.floor.nickname + ': ' + widget.data.floor.content,
                  style: TextUtil.base.sp(14).PingFangSC.w400.blue363C,
                ),
                SizedBox(height: 8.w),
                questionItem,
              ],
            ),
          ));
    }

    Widget messageWrapper = badges.Badge(
      position: badges.BadgePosition.topEnd(end: -2, top: -5),
      badgeContent: Padding(padding: EdgeInsets.all(1)),
      child: questionItem,
    );

    return WButton(
      onPressed: () async {
        await widget.onTapDown.call();

        ///点内部的帖子区域块跳转到帖子
        if (success ?? false) {
          await Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: post,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(color: ColorUtil.whiteFDFE),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              sender,
              SizedBox(height: 8.w),
              messageWrapper,
            ],
          ),
        ),
      ),
    );
  }
}

class FloorMessagesList extends StatefulWidget {
  FloorMessagesList({Key? key}) : super(key: key);

  @override
  _FloorMessagesListState createState() => _FloorMessagesListState();
}

class _FloorMessagesListState extends State<FloorMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<FloorMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
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
                  setState(() {});
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
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text('加载完成:)');
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

  const FloorMessageItem(
      {Key? key, required this.data, required this.onTapDown})
      : super(key: key);

  @override
  _FloorMessageItemState createState() => _FloorMessageItemState();
}

class _FloorMessageItemState extends State<FloorMessageItem> {
  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb/';

  @override
  Widget build(BuildContext context) {
    Widget sender = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          child: widget.data.floor.avatar == ''
              ? SvgPicture.network(
                  '${EnvConfig.QNHD}avatar/beam/20/${widget.data.floor.nickname}',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  baseUrl + '${widget.data.floor.avatar}',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
        ),
        SizedBox(width: 6.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 0.3.sw),
                  child: Text(
                    widget.data.floor.nickname + ' ',
                    style: TextUtil.base.black00.bold.sp(16).PingFangSC,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  widget.data.type == 0 ? '回复了你的冒泡' : '回复了你的评论',
                  style: TextUtil.base.black00.w400.sp(16).PingFangSC,
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              DateTime.now().difference(widget.data.floor.createAt!).inDays >= 1
                  ? widget.data.floor.createAt!
                      .toLocal()
                      .toIso8601String()
                      .replaceRange(10, 11, ' ')
                      .substring(0, 19)
                  : DateTime.now()
                      .difference(widget.data.floor.createAt!)
                      .dayHourMinuteSecondFormatted(),
              style: TextUtil.base.sp(12).PingFangSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget pointText = Text(
      ' · ',
      style: TextUtil.base.grey6C.w400.PingFangSC.sp(24),
    );

    Widget likeFloorFav = Row(
      children: [
        Text(
          widget.data.post.likeCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 点赞',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.commentCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 评论',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.favCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 收藏',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
      ],
    );

    Widget questionItem = WButton(
      onPressed: () async {
        await Navigator.pushNamed(
          context,
          FeedbackRouter.detail,
          arguments: widget.data.post,
        ).then((_) {
          MessageService.setPostFloorMessageRead(widget.data.post.id);
          context.read<MessageProvider>().refreshFeedbackCount();
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          color: widget.data.type == 0
              ? ColorUtil.whiteF8Color
              : ColorUtil.whiteFDFE,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextUtil.base.sp(14).PingFangSC.w400.blue363C,
                  ),
                  SizedBox(height: 6.w),
                  likeFloorFav,
                ],
              ),
            ),
            if (widget.data.post.imageUrls.length != 0)
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
            color: ColorUtil.whiteF8Color,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.toFloor!.nickname +
                      ': ' +
                      widget.data.toFloor!.content,
                  style: TextUtil.base.sp(14).PingFangSC.w400.blue363C,
                ),
                SizedBox(height: 8.w),
                questionItem,
              ],
            ),
          ));
    }

    Widget? messageWrapper;
    if (!widget.data.isRead) {
      messageWrapper = badges.Badge(
        position: badges.BadgePosition.topEnd(end: -2, top: -5),
        badgeContent: Padding(padding: EdgeInsets.all(1)),
        child: questionItem,
      );
    }

    return WButton(
      onPressed: () async {
        await widget.onTapDown.call();
        if (widget.data.type == 0) {
          await Navigator.pushNamed(
            context,
            FeedbackRouter.commentDetail,
            arguments: ReplyDetailPageArgs(
                widget.data.floor, widget.data.post.uid,
                isMessage: true),
          ).then((_) {
            context.read<MessageProvider>().refreshFeedbackCount();
          });
        } else {
          widget.data.floor.subTo == 0
              ? await FeedbackService.getFloorById(
                  id: widget.data.floor.id,
                  onResult: (subToFloor) {
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.commentDetail,
                      arguments: ReplyDetailPageArgs(
                          subToFloor, widget.data.post.uid,
                          isMessage: true),
                    ).then((_) {
                      context.read<MessageProvider>().refreshFeedbackCount();
                    });
                  },
                  onFailure: (e) {
                    ToastProvider.error(e.error.toString());
                  })
              : await FeedbackService.getFloorById(
                  id: widget.data.floor.subTo,
                  onResult: (subToFloor) {
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.commentDetail,
                      arguments: ReplyDetailPageArgs(
                          subToFloor, widget.data.post.uid,
                          isMessage: true),
                    ).then((_) {
                      context.read<MessageProvider>().refreshFeedbackCount();
                    });
                  },
                  onFailure: (e) {
                    ToastProvider.error(e.error.toString());
                  });
        }
      },
      child: Container(
        decoration: BoxDecoration(color: ColorUtil.whiteFDFE),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sender,
              SizedBox(height: 7.w),
              if (widget.data.floor.content != '')
                Text(
                  widget.data.floor.content,
                  style: TextUtil.base.sp(14).PingFangSC.w400.black00,
                ),
              if (widget.data.floor.imageUrl != '')
                Text(
                  '[图片]',
                  style: TextUtil.base.sp(14).PingFangSC.w400.black00,
                ),
              SizedBox(height: 8.w),
              messageWrapper ?? questionItem,
            ],
          ),
        ),
      ),
    );
  }
}

class ReplyMessagesList extends StatefulWidget {
  ReplyMessagesList({Key? key}) : super(key: key);

  @override
  _ReplyMessagesListState createState() => _ReplyMessagesListState();
}

class _ReplyMessagesListState extends State<ReplyMessagesList>
    with AutomaticKeepAliveClientMixin {
  List<ReplyMessage> items = [];
  RefreshController _refreshController = RefreshController(
      initialRefresh: true, initialRefreshStatus: RefreshStatus.refreshing);

  onRefresh({bool refreshCount = true}) async {
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
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text('加载完成:)');
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

  const ReplyMessageItem(
      {Key? key, required this.data, required this.onTapDown})
      : super(key: key);

  @override
  _ReplyMessageItemState createState() => _ReplyMessageItemState();
}

class _ReplyMessageItemState extends State<ReplyMessageItem> {
  final String baseUrl = '${EnvConfig.QNHDPIC}download/thumb/';

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
                  style: TextUtil.base.black00.bold.sp(16).PingFangSC,
                ),
                Text(
                  '回复了你的问题',
                  style: TextUtil.base.black00.w400.sp(16).PingFangSC,
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
              style: TextUtil.base.sp(12).PingFangSC.w400.grey6C,
            ),
          ],
        ),
      ],
    );

    Widget pointText = Text(
      ' · ',
      style: TextUtil.base.grey6C.w400.PingFangSC.sp(24),
    );

    Widget likeFloorFav = Row(
      children: [
        Text(
          widget.data.post.likeCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 点赞',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.commentCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 评论',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
        pointText,
        Text(
          widget.data.post.favCount.toString(),
          style: TextUtil.base.grey6C.w400.ProductSans.sp(14),
        ),
        Text(
          ' 收藏',
          style: TextUtil.base.grey6C.w400.PingFangSC.sp(14),
        ),
      ],
    );

    Widget questionItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        color: ColorUtil.whiteF8Color,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextUtil.base.sp(14).PingFangSC.w400.blue363C,
                  ),
                  SizedBox(height: 6.w),
                  likeFloorFav,
                ],
              ),
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

    Widget? messageWrapper;
    if (!widget.data.isRead) {
      messageWrapper = badges.Badge(
        position: badges.BadgePosition.topEnd(end: -2, top: -5),
        badgeContent: Padding(padding: EdgeInsets.all(1)),
        child: questionItem,
      );
    }

    return WButton(
      onPressed: () async {
        await widget.onTapDown.call();
        await Navigator.pushNamed(
          context,
          FeedbackRouter.detail,
          arguments: widget.data.post,
        ).then((_) => context.read<MessageProvider>().refreshFeedbackCount());
      },
      child: Container(
        decoration: BoxDecoration(color: ColorUtil.whiteFDFE),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sender,
              SizedBox(height: 7.w),
              Text(
                widget.data.reply.content,
                style: TextUtil.base.sp(14).PingFangSC.w400.black00,
              ),
              SizedBox(height: 8.w),
              messageWrapper ?? questionItem,
            ],
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
    this.left = false,
    this.borderSide = const BorderSide(width: 2, color: ColorUtil.whiteFFColor),
    this.insets = EdgeInsets.zero,
  });

  final bool left;

  final BorderSide borderSide;

  final EdgeInsetsGeometry insets;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is CustomIndicator) {
      return CustomIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is CustomIndicator) {
      return CustomIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    double wantWidth = left ? 30 : 32;
    double cw = (indicator.left + indicator.right) / 2;

    return Rect.fromLTWH(
      left ? indicator.left : cw - wantWidth / 2,
      left
          ? indicator.bottom - borderSide.width - 4
          : indicator.bottom - borderSide.width,
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
  _UnderlinePainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  final CustomIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null && configuration.textDirection != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration
        ._indicatorRectFor(rect, textDirection)
        .deflate(decoration.borderSide.width / 2);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
