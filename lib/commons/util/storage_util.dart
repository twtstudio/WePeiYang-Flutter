import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';

class StorageUtil {
  static late Directory downloadDir;

  static late Directory filesDir;

  static late Directory tempDir;

  static late Directory photoDir;

  static Future<void> init() async {
    downloadDir = Platform.isAndroid
        ? (await getDownloadsDirectory() ??
            (await getExternalStorageDirectories(
                    type: StorageDirectory.downloads))!
                .first)
        : await getApplicationDocumentsDirectory();
    filesDir = await getApplicationSupportDirectory();
    tempDir = await getTemporaryDirectory();
    photoDir = Platform.isAndroid
        ? (await getExternalStorageDirectories(
                type: StorageDirectory.pictures))!
            .first
        : await getApplicationDocumentsDirectory();
  }

  static Future<String> saveTempFile(String filename, Uint8List bytes) async {
    final dir = photoDir;
    final file = await File("${dir.path}/$filename").writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> saveTempFileFromNetwork(String url,
      {String filename = ''}) async {
    final res = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    final dir = tempDir;
    if (filename.isEmpty) {
      filename = Uuid().v1();
    }
    final file = await File("${dir.path}/$filename").writeAsBytes(res.data);
    return file.path;
  }
}
