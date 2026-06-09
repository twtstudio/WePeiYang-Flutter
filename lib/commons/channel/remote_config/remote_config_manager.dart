import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';

class RemoteConfig extends ChangeNotifier {
  static const _channel = MethodChannel('com.twt.service/cloud_config');
  Map<String, WebViewConfig> webViews = {};
  Future<void>? _loadFuture;

  Future<void> getRemoteConfig() {
    return _loadFuture ??= _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    try {
      final configs = await _channel.invokeListMethod<Map>('getWebViews');
      final values = configs?.map((c) => WebViewConfig.fromJson(c)) ?? [];
      final keys = values.map((e) => e.page);
      webViews = Map.fromIterables(keys, values);
      notifyListeners();
    } catch (_) {
      // Remote config is optional at startup; keep the local defaults on failure.
    }
  }
}
