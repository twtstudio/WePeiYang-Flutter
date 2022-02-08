// @dart = 2.12

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/channels/image_save.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

const _shareChannel = MethodChannel("com.twt.service/share");

Future<void> shareImgFromUrlToQQ(String url) async {
  try {
    final path = await saveImageFromUrl(url, album: false);
    await _shareChannel.invokeMethod("shareImgToQQ", {"path": path});
  } catch (e) {
    ToastProvider.error(e.toString());
  }
}