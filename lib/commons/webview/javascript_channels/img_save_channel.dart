import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/channel/image_save/image_save.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImgSaveChannel {
  static Future<void> imgSave(JavaScriptMessage message,
      {required String page}) async {
    try {
      final bytes = base64.decode(message.message.split(",")[1]);
      final fileName = "$page${DateTime.now().millisecondsSinceEpoch}.jpg";
      await ImageSave.saveImageFromBytes(bytes, fileName, album: true);
      ToastProvider.success("保存成功");
    } catch (error, stack) {
      Logger.reportError(error, stack);
      ToastProvider.error('图片保存失败');
    }
  }
}
