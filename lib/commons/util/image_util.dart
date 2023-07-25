import 'dart:io';
import 'dart:typed_data';

import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';

class ImageUtil {
  static Future<String> saveBytes(String filename, Uint8List bytes) async {
    final dir = StorageUtil.photoDir;
    final img = await File("${dir.path}/$filename").writeAsBytes(bytes);
    return img.path;
  }
}
