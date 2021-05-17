import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/message/message_center.dart';
import 'package:wei_pei_yang_demo/message/user_mail_webview_dialog.dart';

class UserMailboxPage extends StatefulWidget {
  @override
  _UserMailboxPageState createState() => _UserMailboxPageState();
}

class _UserMailboxPageState extends State<UserMailboxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f7f8),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          titleSpacing: 0,
          leadingWidth: 50,
          brightness: Brightness.light,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '消息',
            style: TextStyle(
              color: Color(0xff242b45),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          leading: FlatButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Color(0XFF62677B),
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      body: UserMailList(),
    );
  }
}

class UserMailList extends StatefulWidget {
  @override
  _UserMailListState createState() => _UserMailListState();
}

class _UserMailListState extends State<UserMailList> {
  UserMessages _messages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _messages = await MessageRepository.getUserMails(0);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_messages == null) {
      return Center(
        child: Text("waiting"),
      );
    }
    return ListView.builder(
      itemBuilder: (c, i) {
        print(i);
        return MailItem(
          data: _messages.mails[i],
        );
      },
      // itemExtent: 170,
      itemCount: _messages.mails.length,
    );
  }
}

// class UserMailList extends StatefulWidget {
//   @override
//   _UserMailListState createState() => _UserMailListState();
// }
//
// class _UserMailListState extends State<UserMailList> {
//   List<UserMail> mails = [];
//   RefreshController _refreshController =
//       RefreshController(initialRefresh: false);
//
//   onRefresh() async {
//     // monitor network fetch
//     try {
//       var result = await MessageRepository.getUserMails(0);
//       mails.clear();
//       mails.addAll(result);
//       if (mounted) setState(() {});
//       _refreshController.refreshCompleted();
//     } catch (e) {
//       _refreshController.refreshFailed();
//     }
//     // if failed,use refreshFailed()
//     // _refreshController.refreshCompleted();
//   }
//
//   _onLoading() async {
//     // monitor network fetch
//     // await Future.delayed(Duration(milliseconds: 1000));
//     try {
//       var result = await MessageRepository.getUserMails(mails.length ~/ 10 + 2);
//       mails.addAll(result);
//       if (mounted) setState(() {});
//       _refreshController.loadComplete();
//     } catch (e) {
//       _refreshController.loadFailed();
//     }
//
//     // if failed,use loadFailed(),if no data return,use LoadNodata()
//     // items.add((items.length + 1).toString());
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       var list = await MessageRepository.getUserMails(0);
//       mails.addAll(list);
//       setState(() {});
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SmartRefresher(
//       enablePullDown: true,
//       enablePullUp: true,
//       header: WaterDropHeader(),
//       footer: CustomFooter(
//         builder: (BuildContext context, LoadStatus mode) {
//           Widget body;
//           if (mode == LoadStatus.idle) {
//             body = Text(S.current.up_load);
//           } else if (mode == LoadStatus.loading) {
//             body = CupertinoActivityIndicator();
//           } else if (mode == LoadStatus.failed) {
//             body = Text(S.current.load_fail);
//           } else if (mode == LoadStatus.canLoading) {
//             body = Text(S.current.load_more);
//           } else {
//             body = Text(S.current.no_more_data);
//           }
//           return Container(
//             height: 55.0,
//             child: Center(child: body),
//           );
//         },
//       ),
//       controller: _refreshController,
//       onRefresh: onRefresh,
//       onLoading: _onLoading,
//       child: ListView.builder(
//         itemBuilder: (c, i) {
//           print(i);
//           return MailItem(
//             data: mails[i],
//             onTapDown: () async {
//               // await MessageRepository.setQuestionRead(items[i].post.id);
//               await onRefresh();
//             },
//           );
//         },
//         // itemExtent: 170,
//         itemCount: mails.length,
//       ),
//     );
//   }
// }

class MailItem extends StatefulWidget {
  final UserMail data;
  final VoidCallback onTapDown;

  const MailItem({Key key, this.data, this.onTapDown}) : super(key: key);

  @override
  _MailItemState createState() => _MailItemState();
}

class _MailItemState extends State<MailItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: GestureDetector(
        onTapUp: (_) => showDialog(
            context: context, builder: (_) => UserMailDialog(widget.data.url)),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: Color.fromARGB(64, 236, 237, 239),
                  offset: Offset(0, 0),
                  spreadRadius: 3),
            ],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.title,
                  style: TextStyle(
                    color: Color(0xff363c54),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.data.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff363c54),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image(
                      image: AssetImage(Images.cloud),
                      width: 17,
                      color: Colors.black,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "twt",
                      style: TextStyle(
                        color: Color(0xff414650),
                        fontSize: 11,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Text(
                      widget.data.time,
                      style: TextStyle(
                        color: Color(0xffb1b2be),
                        fontSize: 11,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserMessages {
  int code;
  String message;
  List<UserMail> mails;

  UserMessages.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) return;
    this.code = json['error_code'];
    this.message = json['message'];
    this.mails = [
      ...(json["result"] as List ?? [])
          .map((e) => UserMail.fromJson(e))
          .toList()
    ];
  }
}

class UserMail {
  String title;
  String content;
  String time;
  String url;
  int id;

  UserMail.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) return;
    this.title = json['title'] ?? "";
    this.content = json['content'] ?? "";
    var t = json['createdAt'] ?? "";
    this.time = reg1.firstMatch(t)?.group(0) ?? "";
    this.url = "https://www.baidu.com";
    this.id = json["id"] ?? 0;
  }
}

final reg1 = RegExp(r"^[0-9]{4}-[0-9]{2}-[0-9]{2}");
