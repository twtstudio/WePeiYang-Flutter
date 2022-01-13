import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/download/download_item.dart';
import 'package:we_pei_yang_flutter/commons/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class HotfixManager {
  HotfixManager._();

  static const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

  static HotfixManager _instance;

  factory HotfixManager.getInstance() {
    if (_instance == null) {
      _instance = HotfixManager._();
    }
    return _instance;
  }

  void _hotFix(
    String url,
    int versionCode, {
    @required Function fixDefaultError,
    void Function(String message) downloadDefaultError,
    void Function() downloadBegin,
    void Function(DownloadItem task, double progress) downloadRunning,
    void Function(List<String> paths) downloadAllSuccess,
    void Function(String message) downloadArgumentError,
    void Function(String message) downloadConfigError,
    void Function(String message) downloadRegisterError,
    void Function(String message) downloadAddTasksError,
    void Function(String message) downloadError,
    void Function(String message) downloadRemoveRegisterError,
    Function fixDownloadSuccess,
    Function fixLoadSoFileSuccess,
    Function fixNoPathError,
    Function fixFileNotFoundError,
    Function fixFileIllegalError,
    Function fixMoveFileError,
  }) {
    final fileName = "$versionCode-libapp.so";
    DownloadManager.getInstance().download(
      DownloadItem(
        url: url,
        fileName: fileName,
        showNotification: false,
        type: DownloadType.hotfix,
      ),
      error: (e) {
        ToastProvider.error(e);
        downloadDefaultError?.call(e);
      },
      success: (item) async {
        ToastProvider.success("download success : ${item.resultPath}");
        fixDownloadSuccess?.call();
        try {
          await _hotfixChannel
              .invokeMethod("hotfix", {"path": item.resultPath});
          ToastProvider.success("load so file success");
          fixLoadSoFileSuccess?.call();
        } on PlatformException catch (e) {
          ToastProvider.success("load so file error : ${e.code}");
          switch (e.code) {
            case "NO_PATH_ERROR":
              fixNoPathError?.call();
              break;
            case "DOWNLOAD_FILE_NOT_FOUND":
              fixFileNotFoundError?.call();
              break;
            case "DOWNLOAD_FILE_NOT_ALLOW":
              fixFileIllegalError?.call();
              break;
            case "COPY_FILE_ERROR":
              fixMoveFileError?.call();
              break;
            default:
              break;
          }
          fixDefaultError.call();
        } catch (e) {
          ToastProvider.success("load so file error : $e");
          fixDefaultError.call();
        }
      },
      begin: downloadBegin,
      running: downloadRunning,
      allSuccess: downloadAllSuccess,
      argumentError: downloadArgumentError,
      configError: downloadConfigError,
      registerError: downloadRegisterError,
      addTasksError: downloadAddTasksError,
      downloadError: downloadError,
      removeRegisterError: downloadRemoveRegisterError,
    );
  }

  void hotfixDownloadAndLoadNow(
    int versionCode,
    String url, {
    @required Function fixDefaultError,
    Function(Function restart) fixLoadSoFileSuccess,
  }) {
    _hotFix(url, versionCode, fixLoadSoFileSuccess: () {
      // 二次Toast提示，防止返回
      fixLoadSoFileSuccess(_restartApp);
    }, fixDefaultError: fixDefaultError);
  }

  void hotfixDownloadAndLoadNext(
    int versionCode,
    String url, {
    @required Function fixDefaultError,
    Function loadSuccess,
  }) {
    _hotFix(
      url,
      versionCode,
      fixLoadSoFileSuccess: loadSuccess,
      fixDefaultError: fixDefaultError,
    );
  }

  Future<void> _restartApp() async {
    try {
      await _hotfixChannel.invokeMethod("restartApp");
    } catch (e) {
      ToastProvider.error("请手动重启应用");
    }
  }
}
