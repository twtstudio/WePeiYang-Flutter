// @dart = 2.12
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

const _channel = MethodChannel('com.twt.service/saveImg');

Future<void> saveImageToAlbum(Uint8List data, String fileName) async {
  try {
    List<Directory>? tempDir = await getExternalStorageDirectories(type: StorageDirectory.pictures);
    if (tempDir == null) {
      ToastProvider.error("找不到对应文件夹");
      return;
    }
    var newImg = File("${tempDir.first.path}/$fileName")..writeAsBytesSync(data);
    await _channel.invokeMethod("savePictureToAlbum", {"path": newImg.absolute.path});
    ToastProvider.success("保存成功");
  } catch (e) {
    ToastProvider.error("保存失败");
  }
}

Future<String> saveImageFromUrl(String url, {String? fileName, bool? album}) async {
  final resultPath =
      await _channel.invokeMethod<String>("savePictureFromUrl", {"url": url, "fileName": fileName, "album": album});
  if (resultPath == null) {
    throw Exception("null result path");
  }
  return resultPath;
}
