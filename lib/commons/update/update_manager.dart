// @dart = 2.12

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/remote_config/remote_config_manager.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_apk_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_install_dialog.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

import 'dialog/update_hotfix_dialog.dart';
import 'dialog/util.dart';
import 'file_util.dart';
import 'hotfix_util.dart';
import 'update_service.dart';
import 'update_util.dart';
import 'version_data.dart';

part 'update_listener.dart';

enum ApkType { beta, release }

/// 版本更新管理
class UpdateManager extends UpdateListener {
  Version? _version;

  final BuildContext _context;

  UpdateManager(this._context);

  /// 当前是测试版('beta')还是正式版('release')
  ApkType get apkType {
    final type = CommonPreferences().apkType.value;
    if (type == 'release') {
      return ApkType.release;
    } else {
      return ApkType.beta;
    }
  }

  /// 手动调用检查更新，[showToast]表示是否弹出检查更新或失败的提示。
  Future<void> checkUpdate({bool showToast = false}) async {
    if (state.isIdle) {
      setGetVersion();
      // 删除原来的（不是当前版本的）apk和so
      await FileUtil.deleteOriginalFile().catchError((error, stack) {
        // TODO
      });

      final v = await latestVersion;

      if (v == null) {
        setIdle();
        if (showToast) SmartDialog.showToast("检查更新失败");
        return;
      } else {
        _version = v;
      }

      final localVersionCode = await UpdateUtil.getVersionCode();
      debugPrint("localVersionCode  $localVersionCode");
      debugPrint("remoteVersionCode ${v.versionCode}");

      if (v.versionCode <= localVersionCode) {
        setIdle();
        if (showToast) SmartDialog.showToast('已是最新版本');
      } else {
        _updateApp(v, showToast);
      }
    } else if (state == UpdateState.download && _version != null) {
      _showApkDialog(_version!, showToast);
    }
  }

  /// 获取最新的版本
  Future<Version?> get latestVersion async {
    // 从个腿上获取配置的最新版本
    final remoteConfigVersionData =
        _context.read<RemoteConfig>().latestVersionData;

    // 从天外天服务器上获取最新版本
    final serverLatestVersionData = await UpdateService.latestVersionData;

    Version? remoteConfigVersion;
    Version? serverLatestVersion;

    switch (apkType) {
      case ApkType.release:
        remoteConfigVersion = remoteConfigVersionData?.info.release;
        serverLatestVersion = serverLatestVersionData?.info.release;
        break;
      case ApkType.beta:
        remoteConfigVersion = remoteConfigVersionData?.info.beta;
        serverLatestVersion = serverLatestVersionData?.info.beta;
        break;
    }

    // 如果同时没有获取到两个版本，即检查更新失败
    if (remoteConfigVersion == null && serverLatestVersion == null) {
      return null;
    }

    // 此时_version 必然不是null
    var v = remoteConfigVersion ?? serverLatestVersion;

    if (v! < serverLatestVersion) {
      v = serverLatestVersion;
    }

    return v;
  }

  /// webFixCode(更新的接口中) remoteVersionCode(新的apk版本)
  /// 如果 webFixCode = 0 ：则表示新版的apk进行了安卓端的改动，需要重新下载安装apk
  /// localVersionCode(现在的apk版本)
  ///
  /// 如果localVersionCode + webFixCode >= remoteVersionCode &&
  /// (localVersionCode < remoteVersionCode) 则代表可以通过热修复更新 也可以通过下载新的安装包更新
  ///
  /// 如果localVersionCode + webFixCode < remoteVersionCode 则表示要
  /// 不就是忘改了，要不就是对安卓端进行了修改，这时候只能通过下载新的安装包更新
  ///
  /// 如果localVersionCode > remoteVersionCode 这就必定有问题，要不是写错了，要不是开发人员，不管
  Future<void> _updateApp(Version version, bool showToast) async {
    _version = version;
    final localVersion = await UpdateUtil.getVersionCode();
    if (localVersion + version.flutterFixCode < version.versionCode) {
      // 安卓端进行了更改，只能通过下载新的安装包更新
      _updateWithApk(version, showToast);
    } else if (localVersion < version.versionCode &&
        localVersion + version.flutterFixCode >= version.versionCode) {
      // 则代表可以通过热修复更新 也可以通过下载新的安装包更新
      // 自动更新，下载完成后再弹对话框
      hotFix(version, fixLoadSoFileSuccess: () {
        _showHotfixDialog(version, showToast);
      }, fixError: (e) {
        // 如果失败了，就下载apk更新
        _updateWithApk(version, showToast);
      }, downloadError: (e) {
        ToastProvider.error(e.toString());
      });
    }
  }

  Future<void> _updateWithApk(Version version, bool showToast) async {
    // 这里其实只返回一个，为了适配安卓低版本才返回一个列表，具体看源码中的注释
    final downloadDirectories =
        await getExternalStorageDirectories(type: StorageDirectory.downloads);
    if (downloadDirectories == null) return;
    for (var directory in downloadDirectories) {
      final path = directory.path + "/apk/" + version.apkName;
      final exist = await File(path).exists();
      if (exist) {
        state = UpdateState.load;
        _showInstallDialog(version, showToast);
        return;
      }
    }
    _showApkDialog(version, showToast);
  }

  void download(Version version) {
    state = UpdateState.download;

    final task = DownloadItem(
      url: version.path,
      fileName: version.apkName,
      title: '微北洋',
      showNotification: true,
      type: DownloadType.apk,
    );

    Future<void> downloadSuccess(DownloadItem task) async {
      if (task.fileName == version.apkName) {
        progress = 1.0;
        state = UpdateState.load;
        await Future.delayed(const Duration(seconds: 1));
        cancelDialog(DialogTag.apk);
        SmartDialog.show(
          clickBgDismissTemp: false,
          backDismiss: false,
          tag: DialogTag.install.text,
          widget: UpdateInstallDialog(version),
          onDismiss: () {
            state = UpdateState.idle;
            progress = 0;
          },
        );
      }
    }

    void downloadFailure(message) {
      SmartDialog.showToast("下载失败");
      cancelDialog(DialogTag.apk);
      state = UpdateState.idle;
    }

    void downloadRunning(DownloadItem task, double p) {
      if (task.fileName == version.apkName) {
        progress = p;
      }
    }

    DownloadManager.getInstance().download(
      task,
      error: downloadFailure,
      success: downloadSuccess,
      running: downloadRunning,
    );
  }

  void cancelDialog(DialogTag tag) {
    SmartDialog.dismiss(status: SmartStatus.dialog, tag: tag.text);
  }

  bool get todayShowDialogAgain {
    final date = CommonPreferences().todayShowUpdateAgain.value;
    final todayNotAgain =
        DateTime.tryParse(date)?.isTheSameDay(DateTime.now()) ?? false;
    if (todayNotAgain) {
      return false;
    } else {
      return true;
    }
  }

  void _showInstallDialog(Version version, bool showToast) {
    if (todayShowDialogAgain || showToast) {
      SmartDialog.show(
        clickBgDismissTemp: false,
        backDismiss: false,
        tag: DialogTag.install.text,
        widget: UpdateInstallDialog(version),
        onDismiss: () {
          state = UpdateState.idle;
        },
      );
    } else {
      state = UpdateState.idle;
    }
  }

  void _showHotfixDialog(Version version, bool showToast) {
    if (todayShowDialogAgain || showToast) {
      SmartDialog.show(
        clickBgDismissTemp: false,
        backDismiss: false,
        tag: DialogTag.hotfix.text,
        widget: UpdateHotfixFinishDialog(version),
        onDismiss: () {
          state = UpdateState.idle;
        },
      );
    } else {
      state = UpdateState.idle;
    }
  }

  void _showApkDialog(Version version, bool showToast) {
    if (todayShowDialogAgain || showToast) {
      debugPrint('$todayShowDialogAgain  || $showToast');
      SmartDialog.show(
        clickBgDismissTemp: false,
        backDismiss: false,
        tag: DialogTag.apk.text,
        widget: UpdateApkDialog(version),
        onDismiss: () {
          state = UpdateState.idle;
        },
      );
    } else {
      state = UpdateState.idle;
    }
  }

  Future<void> forceUpdateApk(int testVersionCode) async {
    state = UpdateState.getVersion;
    var response = await updateDio.get(UpdateService.wbyUpdateUrl);
    var version =
        VersionData.fromJson(jsonDecode(response.data.toString())).info.beta;
    if (testVersionCode + version.flutterFixCode < version.versionCode) {
      _updateWithApk(version, true);
    } else if (testVersionCode < version.versionCode &&
        testVersionCode + version.flutterFixCode >= version.versionCode) {
      hotFix(version, fixLoadSoFileSuccess: () {
        _showHotfixDialog(version, true);
      }, fixError: (e) {
        _updateWithApk(version, true);
      }, downloadError: (e) {
        ToastProvider.error(e.toString());
      }, fixDownloadSuccess: (path) {
        debugPrint('download : $path');
      });
    }
  }

  Future<void> forceUpdateSo() async {
    state = UpdateState.getVersion;
    var response = await updateDio.get(UpdateService.wbyUpdateUrl);
    var version =
        VersionData.fromJson(jsonDecode(response.data.toString())).info.beta;
    hotFix(version, fixLoadSoFileSuccess: () {
      _showHotfixDialog(version, true);
    }, fixError: (e) {
      _updateWithApk(version, true);
    }, downloadError: (e) {
      ToastProvider.error(e.toString());
    }, fixDownloadSuccess: (path) {
      debugPrint('download : $path');
    });
  }
}
