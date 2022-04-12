// @dart = 2.12

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_listener.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/path_util.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_apk_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_install_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_progress_dialog.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'dialog/update_hotfix_dialog.dart';
import 'dialog/util.dart';
import 'file_util.dart';
import 'hotfix_util.dart';
import 'update_service.dart';
import 'update_util.dart';
import 'version_data.dart';

part 'update_listener.dart';

/// 版本更新管理
class UpdateManager extends UpdateStatusListener {
  late Version _version;
  bool showDialog = false;

  /// 手动调用检查更新，[showToast]表示是否弹出检查更新或失败的提示。
  Future<void> checkUpdate({bool show = false}) async {
    showDialog = show;
    switch (status) {
      case UpdateStatus.idle:
        // 无事发生就检查更新
        setGetVersion();
        // 删除原来的（不是当前版本的）apk和so
        await FileUtil.deleteOriginalFile().catchError((error, stack) {
          // TODO
        });

        // 获取最新版本
        final v = await UpdateService.latestVersion;

        if (v == null) {
          setIdle();
          if (showDialog) SmartDialog.showToast("检查更新失败");
          return;
        }

        _version = v;

        final localVersionCode = await UpdateUtil.getVersionCode();
        debugPrint("localVersionCode  $localVersionCode");
        debugPrint("remoteVersionCode ${v.versionCode}");

        if (v.versionCode <= localVersionCode) {
          setIdle();
          if (showDialog) SmartDialog.showToast('已是最新版本');
        } else {
          // _updateApp();
          final localVersion = await UpdateUtil.getVersionCode();
          if (localVersion < _version.flutterFixCode) {
            // 安卓端进行了更改，只能通过下载新的安装包更新
            _updateWithApk();
          } else {
            // 则代表可以通过热修复更新 也可以通过下载新的安装包更新
            // 自动更新，下载完成后再弹对话框
            _hotfix();
          }
        }
        break;
      case UpdateStatus.getVersion:
        // 正在请求检查更新接口，弹窗告诉他不要急
        ToastProvider.running("正在请求最新版本信息");
        break;
      case UpdateStatus.download:
        // 既然正在下载就显示进度
        _showProgressDialog();
        break;
      case UpdateStatus.load:
        ToastProvider.running("正在加载更新");
        break;
    }
  }

  void _hotfix() => hotFix(
        _version,
        fixLoadSoFileSuccess: () {
          if (UpdateUtil.todayShow || showDialog) {
            SmartDialog.show(
              clickBgDismissTemp: false,
              backDismiss: false,
              tag: DialogTag.hotfix.text,
              widget: UpdateHotfixFinishDialog(_version),
            );
          } else {
            ToastProvider.success("请重启应用以使用新版本");
            setIdle();
          }
        },
        fixError: () {
          _updateWithApk();
        },
        download_failed: (_, __, reason) {
          debugPrint("下载失败：$reason");
        },
      );

  /// 通过Apk更新
  Future<void> _updateWithApk() async {
    if (UpdateUtil.todayShow || showDialog) {
      // 先检查是否已经下载了文件，如果已经下载了就直接弹出安装提示框
      final path = PathUtil.downloadDir.path + "/apk/" + _version.apkName;
      final exist = await File(path).exists();
      if (exist) {
        setLoad();
        _showInstallDialog();
        return;
      }
      // 如果没有文件，就弹窗下载弹窗
      SmartDialog.show(
        clickBgDismissTemp: false,
        backDismiss: false,
        tag: DialogTag.apk.text,
        widget: UpdateApkDialog(_version),
      );
    } else {
      setIdle();
    }
  }

  void download() {
    setDownload();

    _showProgressDialog();
    cancelDialog(DialogTag.apk);

    final task = DownloadTask(
      url: _version.path,
      fileName: _version.apkName,
      title: '微北洋',
      description: _version.apkName,
      showNotification: false,
      type: DownloadType.apk,
    );

    // 如果成功，就先关闭进度条，然后显示安装对话框
    SuccessCallback downloadSuccess = (task) async {
      progress = 1.0;
      setLoad();
      await cancelDialog(DialogTag.progress);
      _showInstallDialog();
      progress = 0;
    };

    // 如果创建任务失败，就关闭任务信息弹窗，并显示创建任务失败
    StartErrorCallback startErrorCallback = () async {
      await cancelDialog(DialogTag.progress);
      progress = 0;
      SmartDialog.showToast("创建任务失败");
      setIdle();
    };

    // 下载正式开始的时候，关闭任务信息弹窗，显示进度条
    PendingCallback pendingCallback = (_) {
      progress = 0.01;
    };

    // 下载失败，关闭进度条，并显示下载失败
    FailedCallback downloadFailure = (_, __, ___) async {
      await cancelDialog(DialogTag.progress);
      progress = 0;
      SmartDialog.showToast("下载失败");
      setIdle();
    };

    // 更新进度
    RunningCallback downloadRunning = (task, p) {
      progress = p;
    };

    DownloadManager.getInstance().download(
      task,
      startError: startErrorCallback,
      download_pending: pendingCallback,
      download_running: downloadRunning,
      download_failed: downloadFailure,
      download_success: downloadSuccess,
    );
  }

  Future<void> cancelDialog(DialogTag tag) async {
    await SmartDialog.dismiss(status: SmartStatus.dialog, tag: tag.text);
  }

  void _showInstallDialog() {
    SmartDialog.show(
      clickBgDismissTemp: false,
      backDismiss: false,
      tag: DialogTag.install.text,
      widget: UpdateInstallDialog(_version),
    );
  }

  void _showProgressDialog() {
    SmartDialog.show(
      clickBgDismissTemp: false,
      backDismiss: false,
      tag: DialogTag.progress.text,
      widget: UpdateProgressDialog(_version),
    );
  }
}
