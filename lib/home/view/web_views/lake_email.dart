import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class LakeEmailPage extends WbyWebView {
  LakeEmailPage({Key? key, required BuildContext context})
      : super(
            page: '湖底通知',
            backgroundColor: WpyColorKey.primaryBackgroundColor,
            fullPage: true,
            key: key);

  @override
  _FestivalPageState createState() => _FestivalPageState();
}

class _FestivalPageState extends WbyWebViewState {
  _FestivalPageState();

  @override
  Future<String> getInitialUrl(BuildContext context) async {
    ///测试qpi，正式为https://www.qnhd.twt.edu.cn/message/#/?type=default&token=${CommonPreferences.lakeToken.value}
    return 'https://qnhd.twt.edu.cn/message/#/?type=default&token=${await FeedbackService.lakeToken}';
  }
}
