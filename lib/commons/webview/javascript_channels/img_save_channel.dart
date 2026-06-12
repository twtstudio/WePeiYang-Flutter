import 'dart:convert';
import 'package:we_pei_yang_flutter/commons/channel/image_save/image_save.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/config/webview.dart';

class ImgSaveChannel {
  static WebViewChannelConfig config(String page) {
    return WebViewChannelConfig("WbyImgSaveChannel", (message) async {
      try {
        final bytes = base64.decode(message.message.split(",")[1]);
        final fileName = "$page${DateTime.now().microsecondsSinceEpoch}.jpg";
        await ImageSave.saveImageFromBytes(bytes, fileName, album: true);
      } catch (_) {}
    });
  }
}
