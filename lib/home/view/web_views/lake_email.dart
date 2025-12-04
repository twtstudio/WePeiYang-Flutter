import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

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
    // 获取token
    var token = await LakeTokenManager().token;

    // 检查是否合格
    if (token == null || token.isEmpty) {
      debugPrint("Error：Token 不存在");
      //如果验证错误可以检查是否需要回到主页登录
      // return 'https://qnhd.twt.edu.cn/login';
      return ''; //
    }

    // Debug 使用
    String finalUrl =
        'https://qnhd.twt.edu.cn/message/#/?type=default&token=$token';
    debugPrint("URL WebView: $finalUrl");

    return finalUrl;

    // ///测试qpi，正式为https://www.qnhd.twt.edu.cn/message/#/?type=default&token=${CommonPreferences.lakeToken.value}
    // return 'https://qnhd.twt.edu.cn/message/#/?type=default&token=${await LakeTokenManager().token}';
  }
}
