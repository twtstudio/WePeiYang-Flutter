// @dart = 2.12

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

// TODO: 只实现了基础功能
class WbyFontLoader {
  static void initFonts() {
    final tasks = [
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-Black.otf",
        type: DownloadType.font,
      ),
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-Bold.otf",
        type: DownloadType.font,
      ),
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-ExtraLight.otf",
        type: DownloadType.font,
      ),
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-Light.otf",
        type: DownloadType.font,
      ),
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-Medium.otf",
        type: DownloadType.font,
      ),
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-Regular.otf",
        type: DownloadType.font,
      ),
      DownloadTask(
        url: "https://239what475.github.io/NotoSerifSC-SemiBold.otf",
        type: DownloadType.font,
      ),
    ];

    DownloadManager.getInstance().downloads(
      tasks,
      download_failed: (_, __, reason) {
        // 如果出现一种字体无法下载，就不加载字体，先保存好下载完的字体，在下次打开应用时重试，或在用户手动点击时重试
      },
      download_success: (task) async {
        // 保存好下载的字体，如果在下载界面，就更改ui
      },
      download_running: (fileName, progress) {
        // 如果当前在下载界面，就更改ui
      },
      all_success: (paths) async {
        ToastProvider.success("下载字体成功");
        // final fontLoader = FontLoader("source han sans");
        // for(String path in paths){
        //   debugPrint("font path : $path");
        //   final list = await File(path).readAsBytes();
        //   loadFontFromList(list,fontFamily:"source han sans ${path.split("-").last.split(".").first}");
        // }
        for (String path in paths) {
          final list = await File(path).readAsBytes();
          loadFontFromList(list, fontFamily: NotoSerifSC);
        }
        // await fontLoader.load();
        // final list = await File(paths[0]).readAsBytes();
        // loadFontFromList(list,fontFamily:"source han sans ");
        debugPrint('load font success');
      },
    );
  }

  static final String NotoSerifSC = "NotoSerifSC";
}
