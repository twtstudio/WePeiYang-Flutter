// @dart = 2.12

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/webview/javascript_channels/img_save_channel.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class HaitangPage extends WbyWebView {
  const HaitangPage({Key? key})
      : super(
            page: "海棠季抽卡",
            backgroundColor: const Color.fromRGBO(221, 182, 190, 1.0),
            fullPage: true,
            key: key);

  @override
  _HaitangPageState createState() => _HaitangPageState();
}

class _HaitangPageState extends WbyWebViewState {
  @override
  Future<String> getInitialUrl(BuildContext context) async {
    print(CommonPreferences().token.value);
    return "http://192.168.1.103:8080/#/?token=${CommonPreferences().token.value}";
  }
}
