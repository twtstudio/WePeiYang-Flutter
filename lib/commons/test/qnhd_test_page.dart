// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/push/push_manager.dart';

class QNHDTestPage extends StatefulWidget {
  const QNHDTestPage({Key? key}) : super(key: key);

  @override
  _QNHDTestPageState createState() => _QNHDTestPageState();
}

class _QNHDTestPageState extends State<QNHDTestPage> {
  String token = "unknown";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('青年湖底测试页面'),
      ),
      body: getToken(context),
    );
  }

  Widget getToken(BuildContext context) {
    final manager = context.read<PushManager>();
    return ListView(
      children: [
        SelectableText(token),
        TextButton(
          onPressed: () {
            setState(() {
              token = CommonPreferences().feedbackToken.value;
            });
          },
          child: const Text('点击获取token'),
        ),
      ],
    );
  }
}
