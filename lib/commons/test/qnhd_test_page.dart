import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';

import '../widgets/w_button.dart';

class QsltTestPage extends StatefulWidget {
  const QsltTestPage({super.key});

  @override
  State<QsltTestPage> createState() => _QsltTestPageState();
}

class _QsltTestPageState extends State<QsltTestPage> {
  String _token = 'null';
  bool _loading = false;

  Future<void> _getToken() async {
    setState(() => _loading = true);
    try {
      final response = await _dio.post('user/login', data: FormData.fromMap({
        'username': CommonPreferences.account.value,
        'password': CommonPreferences.password.value,
      }));
      setState(() => _token = response.data['data']['token']?.toString() ?? 'null');
    } catch (e) {
      ToastProvider.error('获取失败: $e');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(title: const Text('青年湖底测试')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: SelectableText(
              _token,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: WButton(
              onPressed: _loading ? null : _getToken,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('获取 Token'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: WButton(
              onPressed: () => Navigator.pushNamed(context, FeedbackRouter.summary),
              child: const Text('前往页面'),
            ),
          ),
        ],
      ),
    );
  }
}

class QNHDSummaryDio extends DioAbstract {
  @override
  String get baseUrl => 'https://areas.twt.edu.cn/api/';
}

final _dio = QNHDSummaryDio();
