import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';

class NoticesPage extends WbyWebView {
  NoticesPage({Key key})
      : super(
      page: '部门通知',
      backgroundColor: ColorUtil.backgroundColor,
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