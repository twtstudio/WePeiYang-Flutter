// @dart = 2.12

import 'dart:io';

import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

// TODO: 只实现了基础功能
class WbyFontLoader {
  static void initFonts({bool test = false}) {
    List<DownloadTask> tasks = [];

    if (test) {
      tasks = [
        DownloadTask(
          url: "https://239what475.github.io/Gilroy-HeavyItalic-8.otf",
          type: DownloadType.font,
        ),
        DownloadTask(
          url: "https://239what475.github.io/NotoSerifSC-Regular.otf",
          type: DownloadType.font,
        ),
        DownloadTask(
          url: "https://239what475.github.io/NotoSerifSC-Black.otf",
          type: DownloadType.font,
        ),
      ];
    }

    DownloadManager.getInstance().downloads(
      tasks,
      download_running: (fileName, progress) {
        // pass
      },
      download_failed: (_, __, reason) {
        // pass
      },
      download_success: (task) async {
        String? family = task.path.split('/').last.split('-').first;
        // 如果截取的family不全由字母组成，则让[loadFontFromList]函数自己解析
        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(family)) family = null;
        final list = await File(task.path).readAsBytes();
        await loadFontFromList(list, fontFamily: family);
      },
      all_success: (paths) async {
        ToastProvider.success("加载字体成功");
      },
      all_complete: (successNum, failedNum) {
        if (failedNum != 0) {
          ToastProvider.error("$successNum种字体加载成功，$failedNum种字体加载失败");
        }
      },
    );
  }
}
