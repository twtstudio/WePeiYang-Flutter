// @dart = 2.12
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class WbyFontLoader {
  static void initFonts({bool hint = false}) {
    List<DownloadTask> tasks = [
      DownloadTask(
        url: 'https://upgrade.twt.edu.cn/font/noto',
        type: DownloadType.font,
      ),
      DownloadTask(
        url: 'https://upgrade.twt.edu.cn/font/ping',
        type: DownloadType.font,
      ),
    ];

    if (hint) ToastProvider.running('下载字体文件中...');
    if (Platform.isAndroid) {
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
          if (hint) ToastProvider.success('加载字体成功');
        },
        all_complete: (successNum, failedNum) {
          if (hint && failedNum != 0) {
            ToastProvider.error('$successNum种字体加载成功，$failedNum种字体加载失败');
          }
        },
      );
    } else if (Platform.isIOS) {
      if (tasks.isEmpty) {
        if (hint) ToastProvider.success('加载字体成功');
        return;
      }
      List<DownloadTask> taskToDownload = [];

      final dio = Dio();
      // 构建任务
      tasks.forEach((element) {
        // 看看存不存在
        final f = File(element.path);
        if (f.existsSync()) {
          // 直接load
          Future.sync(() async {
            final data = await f.readAsBytes();
            await loadFontFromList(data);
          });
          return;
        }
        // 文件夹
        final dir = Directory(p.dirname(element.path));
        // 如果不存在就新建
        if (!dir.existsSync()) dir.createSync();
        taskToDownload.add(element);
      });
      try {
        Future.sync(() async {
          var res = await Future.wait(taskToDownload.map((e) => dio.get(e.url,
              options: Options(responseType: ResponseType.bytes))));
          for (var i = 0; i < res.length; i++) {
            File(taskToDownload[i].path)..writeAsBytesSync(res[i].data);
            await loadFontFromList(res[i].data);
          }
        });
      } catch (e, s) {
        print('llogg');
        Logger.reportError(e, s);
      }
    }
  }
}
