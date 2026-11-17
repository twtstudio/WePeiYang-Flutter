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
    tempDir = await _appTempDir();
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

  /// 应用自己的临时目录。
  ///
  /// Android/iOS 的临时目录是应用沙盒内的，直接使用即可；
  /// 桌面端（Linux 为 /tmp，Windows 为 %TEMP%）是全系统共享目录，
  /// 必须用独立子目录，否则统计/清理缓存时会扫描甚至删除其他程序的文件。
  static Future<Directory> _appTempDir() async {
    final tmp = await getTemporaryDirectory();
    if (Platform.isAndroid || Platform.isIOS) return tmp;
    final dir =
        Directory('${tmp.path}${Platform.pathSeparator}we_pei_yang_flutter');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// 统计临时缓存目录中文件的总字节数
  static Future<int> getTemporaryCacheSize() async {
    final cacheDir = await _appTempDir();
    if (!await cacheDir.exists()) return 0;

    var totalBytes = 0;
    await for (final entity
        in cacheDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes;
  }

  /// 清除应用临时缓存。返回false表示有文件正在使用，未能完全清除。
  static Future<bool> clearTemporaryCache() async {
    final cacheDir = await _appTempDir();
    if (!await cacheDir.exists()) return true;

    var cleared = true;
    await for (final entity in cacheDir.list(followLinks: false)) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {
        cleared = false;
      }
    }
    return cleared;
  }
}
