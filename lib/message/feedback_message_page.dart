import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/feedback/view/detail_page.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';

import 'message_center.dart';

enum MessageType {
  favor,
  contain,
  reply,
}

extension MessageTypeExtension on MessageType {
  String get name => ['点赞', '评论', '官方回复'][this.index];

  List<MessageType> get others {
    List<MessageType> result = [];
    MessageType.values.forEach((element) {
      if (element != this) result.add(element);
    });
    return result;
  }

  String get action {
    switch (this) {
      case MessageType.favor:
        return "点赞了问题";
      case MessageType.contain:
        return "评论了问题";
      case MessageType.reply:
        return "回复了问题";
      default:
        return "";
    }
  }

  refreshMessageCount(List<int> messages, MessageTypes model) {
    List<MapEntry<MessageType, int>> result = [];
    MessageType.values.forEach((element) {
      result.add(
          MapEntry(element, messages.where((m) => m == element.index).length));
    });
    model.setCount(result[0].value, result[1].value, result[2].value);
  }

  int getMessageCount(MessageTypes model) {
    switch (this) {
      case MessageType.favor:
        return model.favorCount;
      case MessageType.contain:
        return model.containCount;
      case MessageType.reply:
        return model.replyCount;
      default:
        return 0;
    }
  }
}

class FeedbackMessagePage extends StatefulWidget {
  @override
  _FeedbackMessagePageState createState() => _FeedbackMessagePageState();
}

class _FeedbackMessagePageState extends State<FeedbackMessagePage> {
  final List<MessageType> types = MessageType.values;

  TabController _tabController;

  ValueNotifier<int> currentIndex = ValueNotifier(2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: types.length,
      vsync: ScrollableState(),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _tabController.animateTo(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageTypes(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppBar(
              titleSpacing: 0,
              leadingWidth: 30,
              brightness: Brightness.light,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "校务消息",
                style: TextStyle(
                  color: Color(0xff303c66),
                  fontSize: 16,
                ),
              ),
              leading: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Color(0XFF62677B),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    tabs: types.map((t) {
                      return MessageTab(type: t);
                    }).toList(),
                    controller: _tabController,
                    onTap: (index) {
                      debugPrint("tap $index");
                      currentIndex.value = _tabController.index;
                    },
                    indicator: CustomIndicator(
                      borderSide: BorderSide(
                        width: 3.5,
                        color: Color(0xff303c66),
                      ),
                    ),
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    isScrollable: true,
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.black,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: types.map((t) {
            return MessagesList(type: t);
          }).toList(),
        ),
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
  @override
  Widget build(BuildContext context) {
    Widget tab = ValueListenableBuilder(
      valueListenable: context
          .findAncestorStateOfType<_FeedbackMessagePageState>()
          .currentIndex,
      builder: (_, int current, __) {
        debugPrint("tap current : $current current type ${widget.type.index}");
        return Text(
          widget.type.name,
          style: TextStyle(
            color: current == widget.type.index
                ? Color(0xff303c66)
                : Color(0xffb1b2be),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Consumer<MessageTypes>(builder: (_, model, __) {
        var count = widget.type.getMessageCount(model);
        if (count.isZero) {
          return tab;
        } else {
          return Center(
            child: Badge(
              badgeContent: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                ),
              ),
              child: tab,
            ),
          );
        }
      }),
    );
  }
}

class MessagesList extends StatefulWidget {
  final MessageType type;

  const MessagesList({Key key, this.type}) : super(key: key);

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList>
    with AutomaticKeepAliveClientMixin {
  List<FeedbackMessageItem> items = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  onRefresh() async {
    // monitor network fetch
    try {
      var result = await MessageRepository.getDetailMessages(0);
      items.clear();
      items.addAll(
          result.data.where((element) => element.type == widget.type.index));
      var messages = result.data
          .where((element) => element.visible == 1)
          .map((e) => e.type)
          .toList();
      var model = Provider.of<MessageTypes>(context, listen: false);
      widget.type.refreshMessageCount(messages, model);
      if (mounted) setState(() {});
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
    // if failed,use refreshFailed()
    // _refreshController.refreshCompleted();
  }

  _onLoading() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    debugPrint("type ${widget.type.name}");
    try {
      var result =
          await MessageRepository.getDetailMessages(items.length ~/ 10 + 2);
      items.addAll(
          result.data.where((element) => element.type == widget.type.index));
      if (mounted) setState(() {});
      if (result.data.isEmpty) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    } catch (e) {
      _refreshController.loadFailed();
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
  }

  @override
  void initState() {
    super.initState();
    debugPrint(widget.type.index.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var list = await MessageRepository.getDetailMessages(0);
      items.addAll(list.data.where((element) {
        debugPrint((element.type).toString());
        return element.type == widget.type.index;
      }));
      var messages = list.data
          .where((element) => element.visible == 1)
          .map((e) => e.type)
          .toList();
      var model = Provider.of<MessageTypes>(context, listen: false);
      widget.type.refreshMessageCount(messages, model);
      debugPrint('item length : ${items.length}');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("上拉加载");
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("加载失败！点击重试！");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("松手,加载更多!");
          } else {
            body = Text("没有更多数据了!");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: _onLoading,
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          print(i);
          return MessageItem(
            data: items[i],
            onTapDown: () async {
              // await MessageRepository.setQuestionRead(items[i].post.id);
              await onRefresh();
            },
            type: widget.type,
          );
        },
        separatorBuilder: (_, __) => Divider(
          indent: 20,
          endIndent: 20,
          thickness: 1,
          height: 3,
          color: Color(0xffacaeba),
        ),
        itemCount: items.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MessageItem extends StatelessWidget {
  final FeedbackMessageItem data;
  final VoidCallback onTapDown;
  final MessageType type;

  const MessageItem({Key key, this.data, this.onTapDown, this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget sender;
    switch (type) {
      case MessageType.reply:
        sender = Container(
          height: 20,
          width: (data.comment.adminName?.length ?? 3) * 17.0,
          child: Center(
            child: Text(
              "${data.comment.adminName ?? "学工部"}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
          decoration: BoxDecoration(
              color: Color(0xff596385),
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle),
        );
        break;
      default:
        sender = Row(
          children: [
            Image.asset(
              'assets/images/user_back.png',
              height: 20,
            ),
            SizedBox(width: 10),
            Text(
              "${data.comment.userName ?? "匿名用户"}",
              style: TextStyle(
                color: Color(0xff434650),
                fontSize: 9,
              ),
            ),
          ],
        );
    }

    Widget title = Row(
      children: [
        sender,
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            type.action,
            style: TextStyle(
              color: Color(0xff434650),
              fontSize: 9,
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        Text(
          data.updatedAt?.time ?? "",
          style: TextStyle(
            color: Color(0xffb1b2be),
            fontSize: 9,
          ),
        ),
      ],
    );

    Widget questionItem = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(7),
        color: Colors.green,
        boxShadow: [
          BoxShadow(
              blurRadius: 5,
              color: Color.fromARGB(64, 236, 237, 239),
              offset: Offset(0, 0),
              spreadRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.post.title,
                    maxLines: 2,
                    softWrap: true,
                    style: TextStyle(
                      color: Color(0xff363c54),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (data.post.topImgUrl != null)
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Image.network(
                      data.post.topImgUrl,
                      height: 30,
                    ),
                  ),
              ],
            ),
            if (data.comment != null)
              Divider(
                thickness: 1,
                height: 10,
                color: Color(0xffacaeba),
              ),
            if (data.comment != null)
              Text(
                data.comment.content ?? "",
                maxLines: 2,
                softWrap: true,
                style: TextStyle(
                  color: Color(0xff363c54),
                  fontSize: 13,
                ),
              ),
            Row(
              children: [
                Image.asset(
                  "assets/images/account/comment.png",
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 10),
                  child: Text(
                    data.post.commentCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xffb1b2be),
                    ),
                  ),
                ),
                Image.asset(
                  "assets/images/account/thumb_up.png",
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 10),
                  child: Text(
                    data.post.likeCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xffb1b2be),
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                Builder(
                  builder: (_) {
                    var isSolved = data.post.isSolved == 1;
                    return Text(
                      isSolved ? "已回复" : "未回复",
                      style: TextStyle(
                          color:
                              isSolved ? Color(0xff434650) : Color(0xffb1b2be),
                          fontSize: 10),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );

    Widget messageWrapper;

    if (data.visible == 1) {
      messageWrapper = ClipRect(
        child: Banner(
          message: "未读",
          location: BannerLocation.topEnd,
          child: questionItem,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
      child: GestureDetector(
        onTapDown: (_) => onTapDown?.call(),
        onTapUp: (_) {
          Navigator.pushNamed(
            context,
            FeedbackRouter.detail,
            arguments: DetailPageArgs(data.post, 0, PostOrigin.mailbox),
          ).then((_) => context
              .findAncestorStateOfType<_MessagesListState>()
              .onRefresh());
        },
        child: Column(
          children: [
            title,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: messageWrapper ?? questionItem,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTypes extends ChangeNotifier {
  var favorCount = 0;
  var containCount = 0;
  var replyCount = 0;

  setCount(int f, int c, int r) {
    favorCount = f;
    containCount = c;
    replyCount = r;
    debugPrint("setCount $f , $c ,$r");
    notifyListeners();
  }
}

extension IntExtension on int {
  bool get isZero => this == 0;
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
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
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
        .deflate(decoration.borderSide.width / 2.0);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
