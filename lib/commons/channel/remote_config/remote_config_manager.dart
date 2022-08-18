// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';

class RemoteConfig extends ChangeNotifier {
  static const _channel = MethodChannel('com.twt.service/cloud_config');
  Map<String, WebViewConfig> webViews = {};

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

    notifyListeners();
  }
}
