// @dart = 2.12

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

class FeedbackSummaryPage extends WbyWebView {
  const FeedbackSummaryPage({Key? key}) : super(page: "年终总结", key: key);

  @override
  _FeedbackSummaryPageState createState() => _FeedbackSummaryPageState();
}

class _FeedbackSummaryPageState extends WbyWebViewState {
  @override
  Future<String> getInitialUrl(BuildContext context) async {
    final baseUrl = await super.getInitialUrl(context);
    debugPrint(baseUrl);
    final response = await _dio.post("user/login",
        formData: FormData.fromMap({
          "username": CommonPreferences().account.value,
          "password": CommonPreferences().password.value,
        }));
    final token = response.data['data']['token'] ?? "null";
    return baseUrl + "?token=$token";
  }
}

class SummaryDio extends DioAbstract {
  @override
  String get baseUrl => "https://areas.twt.edu.cn/api/";
}

final _dio = SummaryDio();
