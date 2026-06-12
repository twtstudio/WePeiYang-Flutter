import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import '../widgets/w_button.dart';

class PushTestPage extends StatefulWidget {
  const PushTestPage({super.key});

  @override
  State<PushTestPage> createState() => _PushTestPageState();
}

class _PushTestPageState extends State<PushTestPage> {
  String _cid = 'unknown';
  String _feedbackIntent = 'unknown';
  String _mailboxIntent = 'unknown';
  String _summaryIntent = 'unknown';

  final _qIdCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  late final PushManager _manager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _manager = context.read<PushManager>();
  }

  Future<void> _getCid() async {
    try {
      _cid = await _manager.getCid() ?? 'null';
    } catch (e) {
      _cid = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _getFeedbackIntent() async {
    final id = int.tryParse(_qIdCtrl.text);
    if (id == null) {
      ToastProvider.error('id 必须为数字');
      return;
    }
    try {
      _feedbackIntent = await _manager.getIntentUri(FeedbackIntent(id)) ?? 'null';
    } catch (e) {
      _feedbackIntent = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _getMailboxIntent() async {
    try {
      _mailboxIntent = await _manager.getIntentUri(MailboxIntent(
        _urlCtrl.text, _titleCtrl.text, _contentCtrl.text, DateTime.now().toIso8601String(),
      )) ?? 'null';
    } catch (e) {
      _mailboxIntent = 'Error: $e';
    }
    setState(() {});
  }

  Future<void> _getSummaryIntent() async {
    try {
      final intent = await _manager.getIntentUri(FeedbackSummaryIntent());
      _summaryIntent = 'twtstudio://weipeiyang.app/feedback\n${intent ?? 'null'}';
    } catch (e) {
      _summaryIntent = 'Error: $e';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _qIdCtrl.dispose();
    _urlCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(title: const Text('推送测试')),
      body: ListView(
        children: [
          _section('CID', _cid, _getCid),
          _section('Feedback Intent', _feedbackIntent, _getFeedbackIntent, children: [
            _input(_qIdCtrl, 'question_id'),
          ]),
          _section('Mailbox Intent', _mailboxIntent, _getMailboxIntent, children: [
            _input(_urlCtrl, 'URL'),
            _input(_titleCtrl, 'Title'),
            _input(_contentCtrl, 'Content'),
          ]),
          _section('Summary Intent', _summaryIntent, _getSummaryIntent),
        ],
      ),
    );
  }

  Widget _section(String title, String value, VoidCallback onTap, {List<Widget> children = const []}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WpyTheme.of(context).get(WpyColorKey.basicTextColor))),
            const SizedBox(height: 8),
            SelectableText(value, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor))),
            if (children.isNotEmpty) ...[const SizedBox(height: 8), ...children],
            const SizedBox(height: 8),
            Center(child: WButton(onPressed: onTap, child: Text('获取'))),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
      ),
    );
  }
}
