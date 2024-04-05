import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

class NoticesPage extends WbyWebView {
  NoticesPage({Key? key, required BuildContext context})
      : super(
            page: '部门通知',
            backgroundColor: WpyColorKey.secondaryBackgroundColor,
            fullPage: false,
            key: key);

  @override
  _NoticesPageState createState() => _NoticesPageState();
}

class _NoticesPageState extends WbyWebViewState {
  _NoticesPageState();

  @override
  Future<String> getInitialUrl(BuildContext context) async {
    ///测试qpi，正式为
    return 'https://qnhd.twt.edu.cn/message/#/?type=department&token=${await LakeTokenManager().token}';
    // return 'pamaforce.xyz:12000/#/?type=department&token=${CommonPreferences().lakeToken.value}';
  }
}
