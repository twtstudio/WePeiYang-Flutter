import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:we_pei_yang_flutter/commons/channel/image_save/image_save.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';

class ShareChannel {
  static WebViewChannelConfig config(String page) {
    return WebViewChannelConfig("WbyShareChannel", (message) async {
      try {
        final bytes = base64.decode(message.message.split(",")[1]);
        final fileName = "$page${DateTime.now().millisecondsSinceEpoch}.jpg";
        await ImageSave.saveImageFromBytes(bytes, fileName);
      } catch (_) {}
    });
  }
}
