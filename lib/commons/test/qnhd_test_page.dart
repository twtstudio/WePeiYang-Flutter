// @dart = 2.12

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';

class QsltTestPage extends StatefulWidget {
  const QsltTestPage({Key? key}) : super(key: key);

  @override
  _QsltTestPageState createState() => _QsltTestPageState();
}

class _QsltTestPageState extends State<QsltTestPage> {
  String token = 'null';

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
    return ListView(
      children: [
        SelectableText(token),
        TextButton(
          onPressed: () async {
            final response = await _dio.post("user/login",
                formData: FormData.fromMap({
                  "username": CommonPreferences.account.value,
                  "password": CommonPreferences.password.value,
                }));
            setState(() {
              token = response.data['data']['token'] ?? "null";
            });
          },
          child: const Text('点击获取token'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, FeedbackRouter.summary);
          },
          child: const Text('前往页面'),
        ),
      ],
    );
  }
}

class QNHDSummaryDio extends DioAbstract {
  @override
  String get baseUrl => "https://areas.twt.edu.cn/api/";
}

final _dio = QNHDSummaryDio();
