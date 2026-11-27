import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/platform/ohos.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickedImage {
  const PickedImage._(this._readFile);

  final Future<File?> Function() _readFile;

  Future<File?> get file => _readFile();
}

class ImageSave {
  static const _channel = MethodChannel('com.twt.service/saveImg');

  static Future<List<PickedImage>?> pickImages(
    BuildContext context, {
    required AssetPickerConfig pickerConfig,
  }) async {
    if (isOhos) {
      final paths = await _channel.invokeListMethod<String>(
        'pickImages',
        {'limit': pickerConfig.maxAssets},
      );
      return paths == null || paths.isEmpty
          ? null
          : [for (final path in paths) PickedImage._(() async => File(path))];
    }
    final assets =
        await AssetPicker.pickAssets(context, pickerConfig: pickerConfig);
    return assets?.map((asset) => PickedImage._(() => asset.file)).toList();
  }

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
