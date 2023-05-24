import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageSave {
  static const _channel = MethodChannel('com.twt.service/saveImg');

  /// 使用数据流保存图片到本地，可选保存到相册
  static Future<String> saveImageFromBytes(
    Uint8List data,
    String name, {
    bool album = false,
  }) async {
    final tempDir =
        await getExternalStorageDirectories(type: StorageDirectory.pictures);
    final img = File("${tempDir!.first.path}/$name")..writeAsBytesSync(data);
    if (album) {
      await _channel.invokeMethod("savePictureToAlbum", {
        "path": img.absolute.path,
      });
    }
    return img.absolute.path;
  }

  /// 使用url保存图片到本地，可选保存到相册
  static Future<String> saveImageFromUrl(
    String url,
    String fileName, {
    bool album = false,
  }) async {
    final resultPath = await _channel.invokeMethod<String>("savePictureFromUrl",
        {"url": url, "fileName": fileName, "album": album});
    return resultPath!;
  }
}
