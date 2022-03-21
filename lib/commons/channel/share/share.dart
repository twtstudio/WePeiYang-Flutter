// @dart = 2.12

import 'package:flutter/services.dart';

class ShareManager {
  static const _shareChannel = MethodChannel("com.twt.service/share");

  static Future<void> shareImgToQQ(String path) async {
    await _shareChannel.invokeMethod("shareImgToQQ", {"path": path});
  }
}
