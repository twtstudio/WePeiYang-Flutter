// @dart = 2.12

import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/channel/image_save/image_save.dart';
import 'package:we_pei_yang_flutter/commons/channel/share/share.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShareChannel implements JavascriptChannel {
  final String page;
  final bool album;

  ShareChannel(this.page, {this.album = false});

  Future<void> shareImg(JavascriptMessage message) async {
    try {
      final bytes = base64.decode(message.message.split(",")[1]);
      final fileName = "$page${DateTime.now().millisecondsSinceEpoch}.jpg";
      await ImageSave.saveImageFromBytes(
        bytes,
        fileName,
        album: album,
      ).then((path) async {
        await ShareManager.shareImgToQQ(path);
      });
    } catch (error, stack) {
      Logger.reportError(error, stack);
      ToastProvider.error('分享失败');
    }
  }

  @override
  String get name => "WbyShareChannel";

  @override
  get onMessageReceived => shareImg;
}
