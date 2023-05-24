import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/install/hotfix.dart';
import 'package:we_pei_yang_flutter/commons/channel/install/install.dart';
import 'package:we_pei_yang_flutter/commons/channel/local_setting/local_setting.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'dialog/update_dialog.dart';
import 'update_service.dart';
import 'update_util.dart';
import 'version_data.dart';

part 'update_listener.dart';

enum UpdateState {
  nothing,
  checkUpdate,
  download,
  load,
}

/// 版本更新管理
class UpdateManager extends UpdateStatusListener {
  /// 新版信息
  late AndroidVersion _androidVersion;
  late IOSVersion _iosVersion;

  dynamic get version => Platform.isAndroid ? _androidVersion : _iosVersion;

  /// 是否为自动检查更新
  bool _auto = false;

  /// r版本大于l版本
  bool _versionCmp(String l, String r) {
    final lArr = l.split('.').map((e) => int.parse(e)).toList();
    final rArr = r.split('.').map((e) => int.parse(e)).toList();
    if (lArr.length != 3 || rArr.length != 3) return false;

    return (lArr[0] * 10000 + lArr[1] * 100 + lArr[2]) <
        (rArr[0] * 10000 + rArr[1] * 100 + rArr[2]);
  }

  Future<void> checkUpdate({bool auto = true}) async {
    switch (status) {
      case UpdateStatus.idle:
        _auto = auto;
        // 无事发生就检查更新
        setGetVersion();
        // 获取最新版本
        final dynamic v = Platform.isIOS
            ? await UpdateService.latestIOSVersion
            : await UpdateService.latestAndroidVersion;

        // 如果获取最新版本失败，需要显示弹窗的时候显示检查更新失败
        if (v == null) {
          setIdle();
          if (!_auto) ToastProvider.error("检查更新失败");
          return;
        }
        if (Platform.isAndroid)
          _androidVersion = v as AndroidVersion;
        else if (Platform.isIOS) _iosVersion = v as IOSVersion;

        // 如果今天不再检查更新，且为自动更新，且不是强制更新
        if (!UpdateUtil.todayCheckAgain && auto && !v.isForced) {
          setIdle();
          return;
        }
        // 如果跳过版本
        if (auto &&
            CommonPreferences.ignoreUpdateVersion.value == version.version) {
          setIdle();
          return;
        }

        if (Platform.isAndroid) {
          debugPrint("remoteVersionCode ${v.versionCode}");
          debugPrint("localVersionCode  ${EnvConfig.VERSIONCODE}");
          await InstallManager.getCanGoToMarket();

          if (v.versionCode <= EnvConfig.VERSIONCODE) {
            // 如果新获取到的版本不高于现在的版本，那么就不更新
            setIdle();
            if (!_auto) ToastProvider.success('已是最新版本');
          } else {
            //如果新获取到的版本高于当前版本，则更新
            // 1.删除原来的（不是当前版本的）apk和so
            await _deleteOriginalFile();
            // 2.判断是否有当前文件可用
            if (await _checkIfFileCanUse()) return;
            // 3.如果没有的话先判断是否 强制更新 或 手动更新 或 不能使用热修复
            if (v.isForced || !_auto || !v.canHotFix) {
              // 如果不能热修复 或 强制更新 或 手动更新，则弹窗对话框
              UpdateDialog.message.show();
            } else {
              // 否则，就优先热更新
              setDownload();
            }
          }
        } else if (Platform.isIOS) {
          final localVersion = await LocalSetting.getBundleVersion();
          debugPrint("remoteVersionCode ${v.version}");
          debugPrint("localVersionCode  ${localVersion}");
          final remoteVersion = (v.version as String);
          if (_versionCmp(localVersion, remoteVersion)) {
            UpdateDialog.message.show();
          } else {
            // 如果新获取到的版本不高于现在的版本，那么就不更新
            setIdle();
            if (!_auto) ToastProvider.success('已是最新版本');
          }
        }
        break;
      case UpdateStatus.getVersion:
        // 正在请求检查更新接口，弹窗告诉他不要急
        if (!_auto) ToastProvider.running("正在请求最新版本信息");
        break;
      case UpdateStatus.download:
        // 既然正在下载就显示进度
        UpdateDialog.progress.show();
        break;
      case UpdateStatus.load:
        // 正在加载也显示进度
        UpdateDialog.progress.show();
        break;
      case UpdateStatus.error:
        UpdateDialog.failure.show();
        break;
    }
  }

  /// 检查是否有热修复文件或apk可以使用
  Future<bool> _checkIfFileCanUse() async {
    // 可能使用热修复，判断是否有热修复文件可使用
    final soCanUse = await HotFixManager.soFileCanUse(version.soName);
    if (soCanUse == true) {
      // 有热修复文件可以使用
      setLoad();
      UpdateDialog.hotfix.show();
      return true;
    } else if (soCanUse == false) {
      // 有热修复文件不能使用
      _androidVersion.canHotFix = false;
    }
    // 也可能使用apk，检查apk是否存在
    if (await File(version.apkPath).exists()) {
      setLoad();
      UpdateDialog.install.show();
      return true;
    }
    return false;
  }

  @override
  setDownload() {
    if (status.isDownload) return;
    super.setDownload();

    // 设置下载进度为0
    progress = 0;
    // 不自动打开进度条页面

    if (version.canHotFix) {
      // 如果能热修复，下载zip文件
      _updateByHotfix();
    } else {
      // 不能热修复则下载apk
      _updateByApk();
    }
  }

  @override
  setIdle() {
    // 如果是强制更新，就不能退出，必须更新完毕
    if (status.isIdle) return;
    super.setIdle();
    // 设置下载进度为0
    progress = 0;
    // 关闭所有弹窗
    UpdateDialog.message.cancelAll();
  }

  @override
  setLoad() {
    if (status.isLoad) return;
    super.setLoad();
    progress = 1.0;
  }

  /// 通过替换libapp.so文件实现热更新
  void _updateByHotfix() {
    void _updateByHotfixError() {
      setError();
      // TODO: 再考虑下
      // 热修复失败，设置为不能使用热修复更新
      _androidVersion.canHotFix = false;
      if (_auto && !_androidVersion.isForced) {
        // 如果是自动更新，且非强制更新，则在这里弹出更新信息页面，由用户手动开始使用apk更新，
        // 因为只有这种情况是不自动显示弹窗
        UpdateDialog.message.show();
      } else {
        // 如果不是自动更新，则此时应该是热修复失败，自动继续使用apk更新
        setDownload();
      }
    }

    // 如果成功，就先关闭进度条，然后显示安装对话框
    SuccessCallback downloadSuccess = (task) async {
      setLoad();

      try {
        // 加载热修复so文件
        await HotFixManager.hotFix(task.path);
        // 加载成功则弹窗通知重启应用
        UpdateDialog.hotfix.show();
      } catch (e, s) {
        Logger.reportError(e, s);
        _updateByHotfixError();
      }
    };

    // 创建任务就失败了
    StartErrorCallback startErrorCallback = () {
      _updateByHotfixError();
    };

    // 下载正式开始的时候，显示进度条
    PendingCallback pendingCallback = (_) {
      progress = 0.01;
    };

    // 下载失败，关闭进度条，并显示下载失败
    FailedCallback downloadFailure = (_, __, ___) {
      _updateByHotfixError();
    };

    // 更新进度
    RunningCallback downloadRunning = (task, p) {
      if (p > progress) progress = p;
    };

    DownloadManager.getInstance().download(
      DownloadTask.updateZip(version),
      startError: startErrorCallback,
      download_pending: pendingCallback,
      download_running: downloadRunning,
      download_failed: downloadFailure,
      download_success: downloadSuccess,
    );
  }

  /// 通过安装apk实现应用内更新
  ///
  /// 只有人手动选择通过apk更新，才会下载apk，所以如果更新失败，就弹出弹窗
  void _updateByApk() {
    void _updateByApkError() async {
      setError();
      UpdateDialog.failure.show();
    }

    // 如果成功，就先关闭进度条，然后显示安装对话框
    SuccessCallback downloadSuccess = (task) async {
      setLoad();
      UpdateDialog.install.show();
    };

    // 如果创建任务失败，就关闭任务信息弹窗，并显示创建任务失败
    StartErrorCallback startErrorCallback = () async {
      _updateByApkError();
    };

    // 下载正式开始的时候，关闭任务信息弹窗，显示进度条
    PendingCallback pendingCallback = (_) {
      progress = 0.01;
    };

    // 下载失败，关闭进度条，并显示下载失败
    FailedCallback downloadFailure = (_, __, ___) async {
      _updateByApkError();
    };

    // 更新进度
    RunningCallback downloadRunning = (task, p) {
      if (p > progress) progress = p;
    };

    DownloadManager.getInstance().download(
      DownloadTask.updateApk(version),
      startError: startErrorCallback,
      download_pending: pendingCallback,
      download_running: downloadRunning,
      download_failed: downloadFailure,
      download_success: downloadSuccess,
    );
  }

  /// 删除之前下载的应用更新相关文件
  Future<void> _deleteOriginalFile() async {
    final apkDir = Directory(DownloadType.apk.path);
    if (!apkDir.existsSync()) return;

    for (var file in apkDir.listSync()) {
      final name = file.path.split(Platform.pathSeparator).last;

      // 如果下载的文件是apk，则将不是新版本的删除
      if (name.endsWith('.apk')) {
        final versionCode = int.tryParse(name.split('-')[0]) ?? 0;
        if (versionCode < _androidVersion.versionCode) {
          file.delete();
        }
      }

      // 如果下载的文件以"-libapp.zip"结尾，直接删除
      if (name.endsWith('-libapp.zip')) file.delete();
    }
  }
}
