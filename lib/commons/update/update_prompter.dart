import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/download/download_item.dart';
import 'package:we_pei_yang_flutter/commons/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/install_util..dart';
import 'package:we_pei_yang_flutter/commons/update/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';

typedef InstallCallback = Function(String filePath);

// TODO: 写法有问题
class UpdatePrompter {
  final Version updateEntity;

  UpdateDialog _dialog;

  UpdatePrompter({@required this.updateEntity});

  void show(Version version) async {
    if (_dialog != null && _dialog.isShowing) {
      return;
    }
    final fileName =
        "${updateEntity.version}-${updateEntity.versionCode}wby.apk";
    final downloadDirectories =
        await getExternalStorageDirectories(type: StorageDirectory.downloads);
    for (var directory in downloadDirectories) {
      final list = directory.listSync().map((e) => e.path);
      if (list.where((e) => e.endsWith(fileName)).isNotEmpty) {
        _dialog = UpdateDialog.showInstall(
          WePeiYangApp.navigatorState.currentState.overlay.context,
          onInstall: onInstall,
          version: version,
        );
        return;
      }

    }

    _dialog = UpdateDialog.showUpdate(
      WePeiYangApp.navigatorState.currentState.overlay.context,
      onUpdate: onUpdate,
      onInstall: onInstall,
      version: version,
    );
  }

  Future<void> onUpdate() async {
    if (Platform.isIOS) return;
    _dialog.update(0);
    final apk = "${updateEntity.version}-${updateEntity.versionCode}wby.apk";

    DownloadManager.getInstance().download(
      DownloadItem(
        url: updateEntity.path,
        fileName: apk,
        title: '微北洋',
        showNotification: true,
        type: DownloadType.apk,
      ),
      error: (message) {
        ToastProvider.error("下载失败: $message");
        _dialog.dismiss();
      },
      success: (task) async {
        if (task.fileName == apk) {
          _dialog.update(1.0);
          ToastProvider.success("下载成功");
          await Future.delayed(const Duration(seconds: 1));
          _dialog.dismiss();
          InstallUtil.install(task.fileName);
        }
      },
      running: (task, progress) {
        if (task.fileName == apk) {
          _dialog.update(progress);
        }
      },
    );
  }

  Future<void> onInstall() async {
    _dialog.update(1);
    final fileName =
        "${updateEntity.version}-${updateEntity.versionCode}wby.apk";
    InstallUtil.install(fileName);
  }
}
