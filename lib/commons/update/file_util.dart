// @dart = 2.12

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';

class FileUtil {
  static Future<void> deleteOriginalFile() async {
    final dir =
        (await getExternalStorageDirectories(type: StorageDirectory.downloads))
            ?.first;
    final apkDir = Directory(dir!.path + Platform.pathSeparator + 'apk');
    final currentVersionCode = await UpdateUtil.getVersionCode();
    if (apkDir.existsSync()) {
      for (var file in apkDir.listSync()) {
        final name = file.path.split(Platform.pathSeparator).last;
        debugPrint('current file: ' + name);
        final list = name.split('-');
        if (name.endsWith('.apk') && list.length == 3) {
          final versionCode = int.tryParse(list[1]) ?? 0;
          if (versionCode < currentVersionCode) {
            file.delete();
          }
        }
      }
    }
  }
}
