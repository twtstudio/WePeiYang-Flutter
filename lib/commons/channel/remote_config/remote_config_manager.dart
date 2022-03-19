// @dart = 2.12

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class RemoteConfig extends ChangeNotifier {
  static const _channel = MethodChannel('com.twt.service/cloud_config');
  Map<String, WebViewConfig> webViews = {};
  VersionData? latestVersionData;

  Future<void> getRemoteConfig() async {
    void getWebViewsSuccess(List<Map>? configs) {
      final values = configs?.map((c) => WebViewConfig.fromJson(c)) ?? [];
      final keys = values.map((e) => e.page);
      webViews = Map.fromIterables(keys, values);
    }

    void getWebViewsFailure(error, stack) {
      // TODO
    }

    await _channel
        .invokeListMethod<Map>('getWebViews')
        .then(getWebViewsSuccess)
        .catchError(getWebViewsFailure);

    void getLatestVersionSuccess(String? json) {
      if(json != null){
        final data = jsonDecode(json) as Map;
        latestVersionData = VersionData.fromJson(data);
      }
    }

    void getLatestVersionFailure(error, stack) {
      // TODO
    }

    await _channel
        .invokeMethod<String>('latest_version_data')
        .then(getLatestVersionSuccess)
        .catchError(getLatestVersionFailure);

    notifyListeners();
  }
}
