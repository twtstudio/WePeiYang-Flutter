// @dart = 2.12

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathUtil {
  static late Directory downloadDir;

  static Future<void> init() async {
    downloadDir =
        (await getExternalStorageDirectories(type: StorageDirectory.downloads))!
            .first;
  }
}
