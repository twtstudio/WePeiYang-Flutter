// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class PushTestPage extends StatefulWidget {
  const PushTestPage({Key? key}) : super(key: key);

  @override
  _PushTestPageState createState() => _PushTestPageState();
}

class _PushTestPageState extends State<PushTestPage> {
  String cid = "unknown";
  String feedbackIntent = "unknown";
  String mailboxIntent = "unknown";
  final qId = TextEditingController();
  final url = TextEditingController();
  final title = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推送测试页面'),
      ),
      body: getCidAndIntent(context),
    );
  }

  Widget getCidAndIntent(BuildContext context) {
    final manager = context.read<PushManager>();
    return ListView(
      children: [
        SelectableText(cid),
        TextButton(
          onPressed: () async {
            final id = await manager.getCid();
            setState(() {
              cid = id ?? 'null';
            });
          },
          child: const Text('点击获取cid'),
        ),
        SelectableText(feedbackIntent),
        TextField(
          controller: qId,
          decoration: const InputDecoration(hintText: "输入 question_id"),
        ),
        TextButton(
          onPressed: () async {
            final id = int.tryParse(qId.text);
            if (id == null) {
              ToastProvider.error("id必须为数字");
            }
            final intent = await manager.getIntentUri(FeedbackIntent(id!));
            setState(() {
              feedbackIntent = intent ?? 'null';
            });
          },
          child: const Text('点击获取feedback intent'),
        ),
        SelectableText(mailboxIntent),
        TextField(
          controller: url,
          decoration: const InputDecoration(hintText: "输入 url"),
        ),
        TextField(
          controller: title,
          decoration: const InputDecoration(hintText: "输入 title"),
        ),
        TextButton(
          onPressed: () async {
            final intent = await manager.getIntentUri(MailboxIntent(url.text, title.text));
            setState(() {
              mailboxIntent = intent ?? 'null';
            });
          },
          child: const Text('点击获取mailbox intent'),
        ),
      ],
    );
  }
}
