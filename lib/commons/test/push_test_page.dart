import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import '../widgets/w_button.dart';

class PushTestPage extends StatefulWidget {
  const PushTestPage({Key? key}) : super(key: key);

  @override
  _PushTestPageState createState() => _PushTestPageState();
}

class _PushTestPageState extends State<PushTestPage> {
  String cid = "unknown";
  String feedbackIntent = "unknown";
  String mailboxIntent = "unknown";
  String summaryIntent = "unknown";
  final qId = TextEditingController();
  final url = TextEditingController();
  final title = TextEditingController();
  final content = TextEditingController();
  final summary = TextEditingController();
  late PushManager manager;

  @override
  Widget build(BuildContext context) {
    manager = context.read<PushManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('推送测试页面'),
      ),
      body: ListView(
        children: [
          ...pushToken,
          ...feedbackPage,
          ...mailboxPage,
          ...summaryPage,
        ],
      ),
    );
  }

  List<Widget> get pushToken {
    return [
      SelectableText(cid),
      WButton(
        onPressed: () async {
          final id = await manager.getCid();
          setState(() {
            cid = id ?? 'null';
          });
        },
        child: const Text('点击获取cid'),
      ),
    ];
  }

  List<Widget> get feedbackPage {
    return [
      SelectableText(feedbackIntent),
      TextField(
        controller: qId,
        decoration: const InputDecoration(hintText: "输入 question_id"),
      ),
      WButton(
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
    ];
  }

  List<Widget> get mailboxPage {
    return [
      SelectableText(mailboxIntent),
      TextField(
        controller: url,
        decoration: const InputDecoration(hintText: "输入 url"),
      ),
      TextField(
        controller: title,
        decoration: const InputDecoration(hintText: "输入 title"),
      ),
      TextField(
        controller: content,
        decoration: const InputDecoration(hintText: "输入 content"),
      ),
      WButton(
        onPressed: () async {
          final intent = await manager.getIntentUri(MailboxIntent(
            url.text,
            title.text,
            content.text,
            DateTime.now().toIso8601String(),
          ));
          setState(() {
            mailboxIntent = intent ?? 'null';
          });
        },
        child: const Text('点击获取mailbox intent'),
      ),
    ];
  }

  List<Widget> get summaryPage {
    return [
      SelectableText(summaryIntent),
      WButton(
        onPressed: () async {
          final intent = await manager.getIntentUri(FeedbackSummaryIntent());
          setState(() {
            summaryIntent =
                "twtstudio://weipeiyang.app/feedback\n" + (intent ?? 'null');
          });
        },
        child: const Text('点击获取校务总结页面跳转'),
      ),
    ];
  }
}
