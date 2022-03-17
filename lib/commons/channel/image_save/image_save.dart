// @dart = 2.12
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageSave {
  static const _channel = MethodChannel('com.twt.service/saveImg');

  static Future<String> saveImageToAlbum(Uint8List data, String name) async {
    final tempDir =
        await getExternalStorageDirectories(type: StorageDirectory.pictures);
    final img = File("${tempDir!.first.path}/$name")..writeAsBytesSync(data);
    await _channel
        .invokeMethod("savePictureToAlbum", {"path": img.absolute.path});
    return img.absolute.path;
  }

  static Future<String> saveImageFromUrl(
    String url, {
    String? fileName,
    bool? album,
  }) async {
    final resultPath = await _channel.invokeMethod<String>("savePictureFromUrl",
        {"url": url, "fileName": fileName, "album": album});
    return resultPath!;
  }
}
