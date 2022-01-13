// @dart = 2.12

import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:we_pei_yang_flutter/commons/download/download_item.dart';
import 'package:we_pei_yang_flutter/commons/download/download_manager.dart';

// TODO: 只实现了基础功能
class WbyFontLoader {
  static void initFonts() {
    final tasks = [
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-Bold.otf",
        fileName: "SourceHanSansCN-Bold.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-ExtraLight.otf",
        fileName: "SourceHanSansCN-ExtraLight.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-Heavy.otf",
        fileName: "SourceHanSansCN-Heavy.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-Light.otf",
        fileName: "SourceHanSansCN-Light.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-Medium.otf",
        fileName: "SourceHanSansCN-Medium.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-Normal.otf",
        fileName: "SourceHanSansCN-Normal.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
      DownloadItem(
        url: "https://239what475.github.io/SourceHanSansCN-Regular.otf",
        fileName: "SourceHanSansCN-Regular.otf",
        showNotification: false,
        type: DownloadType.font,
      ),
    ];

    DownloadManager.getInstance().downloads(
      tasks,
      error: (message) {
        // 如果出现一种字体无法下载，就不加载字体，先保存好下载完的字体，在下次打开应用时重试，或在用户手动点击时重试
      },
      success: (task) async {
        // 保存好下载的字体，如果在下载界面，就更改ui
      },
      running: (fileName, progress) {
        // 如果当前在下载界面，就更改ui
      },
      allSuccess: (paths) async {
        // final fontLoader = FontLoader("source han sans");
        for(String path in paths){
          debugPrint("font path : $path");
          final list = await File(path).readAsBytes();
          loadFontFromList(list,fontFamily:"source han sans ${path.split("-").last.split(".").first}");
        }
        for(String path in paths){
          final list = await File(path).readAsBytes();
          loadFontFromList(list,fontFamily:"source han sans");
        }
        // await fontLoader.load();
        // final list = await File(paths[0]).readAsBytes();
        // loadFontFromList(list,fontFamily:"source han sans ");
        debugPrint('load font success');
      },
    );
  }

  static Future<ByteData> readFont(String path) async {
    final fontFile = File(path);
    ByteData byteData = (await fontFile.readAsBytes()).buffer.asByteData();
    return byteData;
  }
}