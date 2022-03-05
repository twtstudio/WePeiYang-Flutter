import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_router.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/service/images.dart';
import 'package:we_pei_yang_flutter/lounge/ui/widget/loading.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'message_service.dart';

class UserMailboxPage extends StatefulWidget {
  @override
  _UserMailboxPageState createState() => _UserMailboxPageState();
}

class _UserMailboxPageState extends State<UserMailboxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f7f8),
      appBar: AppBar(
          title: Text(S.current.message,
              style: FontManager.YaHeiRegular.copyWith(
                  fontSize: 16,
                  color: Color.fromRGBO(36, 43, 69, 1),
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          )),
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
      _messages = await getUserMails(0);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_messages == null) {
      return Center(child: Text("waiting"));
    }
    return ListView.builder(
      itemCount: _messages.mails.length,
      itemBuilder: (_, i) {
        return MailItem(data: _messages.mails[i]);
      },
    );
  }
}

class MailItem extends StatefulWidget {
  final UserMail data;

  const MailItem({Key key, this.data}) : super(key: key);

  @override
  _MailItemState createState() => _MailItemState();
}

class _MailItemState extends State<MailItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: GestureDetector(
        onTapUp: (_) {
          Navigator.pushNamed(
            context,
            MessageRouter.mailPage,
            arguments: widget.data,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: Color.fromARGB(64, 236, 237, 239),
                  offset: Offset.zero,
                  spreadRadius: 3),
            ],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.title,
                style: TextStyle(
                    color: Color(0xff363c54),
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              SizedBox(height: 10),
              Text(
                widget.data.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xff363c54), fontSize: 13),
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
                    style: TextStyle(color: Color(0xff414650), fontSize: 11),
                  ),
                  Spacer(),
                  Text(
                    widget.data.time
                        .replaceRange(10, 11, ' ')
                        .substring(0, 19),
                    style: TextStyle(color: Color(0xffb1b2be), fontSize: 11),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MailPage extends StatelessWidget {
  final UserMail data;

  const MailPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f7f8),
      appBar: AppBar(
        title: Text('通知',
            style: FontManager.YaHeiRegular.copyWith(
                fontSize: 16, color: Color.fromRGBO(36, 43, 69, 1))),
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
              child: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(53, 59, 84, 1), size: 32),
              onTap: () => Navigator.pop(context)),
        ),
      ),
      body: data.url != null && data.url != ''
          ? _HtmlMailContent(data: data)
          : _TextMailContent(data: data),
    );
  }
}

class _HtmlMailContent extends StatefulWidget {
  final UserMail data;

  const _HtmlMailContent({Key key, this.data}) : super(key: key);

  @override
  _HtmlMailContentState createState() => _HtmlMailContentState();
}

class _HtmlMailContentState extends State<_HtmlMailContent> {
  double opacity = 0.0;
  bool loadSuccess = true;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (loadSuccess) {
      result = Stack(
        alignment: Alignment.center,
        children: [
          Visibility(visible: showLoading, child: Loading()),
          Opacity(
            opacity: opacity,
            child: WebView(
              initialUrl: widget.data.url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (_) {
                setState(() {
                  showLoading = false;
                  opacity = 1.0;
                });
              },
              onProgress: (_) {
                setState(() {
                  showLoading = true;
                });
              },
              onWebResourceError: (WebResourceError error) {
                ToastProvider.error('加载遇到了错误');
                setState(() {
                  showLoading = false;
                  loadSuccess = false;
                });
              },
            ),
          ),
        ],
      );
    } else {
      result = _TextMailContent(data: widget.data);
    }
    return result;
  }
}

class _TextMailContent extends StatelessWidget {
  final UserMail data;

  const _TextMailContent({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(data.time).toLocal()),
          style: TextStyle(fontSize: 12, color: Color(0xff62677b)),
        )
      ],
    );

    final content = Row(
      children: [
        Expanded(
          child: Text(
            data.content,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: Color.fromARGB(64, 236, 237, 239),
                  offset: Offset.zero,
                  spreadRadius: 3),
            ],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    data.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              content,
              SizedBox(height: 16),
              time,
            ],
          ),
        ),
      ),
    );
  }
}
