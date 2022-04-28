// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

class LakeEmailPage extends WbyWebView {
  LakeEmailPage({Key? key})
      : super(
      page: '湖底通知',
      backgroundColor: Colors.white,
      fullPage: true,
      key: key);

  @override
  _FestivalPageState createState() => _FestivalPageState();
}

class _FestivalPageState extends WbyWebViewState {
  _FestivalPageState();

  @override
  Future<String> getInitialUrl(BuildContext context) async {
    return 'https://www.zrzz.site:7013/message/#/?token=${CommonPreferences().feedbackToken.value}';
  }
}
