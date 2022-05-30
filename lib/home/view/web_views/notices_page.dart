import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

class NoticesPage extends WbyWebView {
  NoticesPage({Key key})
      : super(
      page: '通知',
      backgroundColor: Colors.white,
      fullPage: false,
      key: key);

  @override
  _NoticesPageState createState() => _NoticesPageState();
}

class _NoticesPageState extends WbyWebViewState {
  _NoticesPageState();

  @override
  Future<String> getInitialUrl(BuildContext context) async {
    return 'pamaforce.xyz:12000/#/?type=department&token=${CommonPreferences().lakeToken.value}';
  }
}