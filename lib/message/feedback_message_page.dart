import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/lounge/provider/provider_widget.dart';

import 'message_center.dart';

enum MessageType {
  favor,
  contain,
  reply,
}

extension MessageTypeExtension on MessageType {
  String get name => ['点赞', '评论', '回复'][this.index];

  List<MessageType> get others {
    List<MessageType> result = [];
    MessageType.values.forEach((element) {
      if (element != this) result.add(element);
    });
    return result;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: types.length,
      vsync: ScrollableState(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageTypes(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppBar(
              titleSpacing: 0,
              leadingWidth: 30,
              brightness: Brightness.light,
              elevation: 0,
              title: Text(
                "收件箱",
                style: TextStyle(color: Colors.red),
              ),
              leading: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 30,
                  color: Color(0XFF62677B),
                ),
              ),
              bottom: TabBar(
                tabs: types.map((t) {
                  return MessageTab(type: t);
                }).toList(),
                controller: _tabController,
                indicatorColor: Colors.red,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.black,
                indicatorWeight: 3.0,
                // labelStyle: TextStyle(height: 1),
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
    return Consumer<MessageTypes>(builder: (_, model, __) {
      var count = widget.type.getMessageCount(model);
      if (count.isZero) {
        return Text(widget.type.name);
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
            child: Text(widget.type.name),
          ),
        );
      }
    });
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

  void _onRefresh() async {
    // monitor network fetch
    try {
      var result = await MessageRepository.getDetailMessages(0);
      items.clear();
      items.addAll(
          result.data.where((element) => element.type == widget.type.index));
      var messages = result.data.map((e) => e.type).toList();
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

  void _onLoading() async {
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
      var messages = list.data.map((e) => e.type).toList();
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
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) {
          print(i);
          return MessageItem(data: items[i]);
        },
        itemExtent: 100.0,
        itemCount: items.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MessageItem extends StatelessWidget {
  final FeedbackMessageItem data;

  const MessageItem({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3),
            color: Colors.greenAccent),
        child: Center(
          child: Text(
            data.json.toString(),
            style: TextStyle(fontSize: 7),
          ),
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
