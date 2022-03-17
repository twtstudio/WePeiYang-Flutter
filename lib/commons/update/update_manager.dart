// @dart = 2.12

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_apk_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_install_dialog.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

import 'dialog/update_hotfix_dialog.dart';
import 'hotfix_util.dart';
import 'update_service.dart';
import 'update_util.dart';
import 'version_data.dart';

enum UpdateState {
  nothing,
  checkUpdate,
  download,
  load,
}

enum DialogTag { apk, hotfix, install }

extension DialogTagExt on DialogTag {
  String get text => ['updateDialog', 'hotfixDialog', 'installDialog'][index];
}

/// 版本更新管理
class UpdateManager extends ChangeNotifier {
  Version? _version;

  double _progress = 0;

  double get progress => _progress;

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  UpdateState _state = UpdateState.nothing;

  UpdateState get state => _state;

  set state(UpdateState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> checkUpdate({bool showToast = false}) async {
    debugPrint('check update');
    if (state == UpdateState.nothing) {
      debugPrint('check update123');
      state = UpdateState.checkUpdate;
      // 先删除原来的apk和so
      await _deleteOriginalFile();
      // 再检查更新
      await UpdateService.checkUpdate(
          onResult: (version) => _updateApp(version, showToast),
          onSuccess: () {
            state = UpdateState.nothing;
            if (showToast) SmartDialog.showToast('已是最新版本');
          },
          onFailure: (_) {
            state = UpdateState.nothing;
            if (showToast) SmartDialog.showToast("检查更新失败");
          });
    } else if (state == UpdateState.download && _version != null) {
      _showApkDialog(_version!, showToast);
    }
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
      hotFix(
        version.flutterFixSoFile,
        version.versionCode,
        version.flutterFixCode,
        fixLoadSoFileSuccess: () {
          _showHotfixDialog(version, showToast);
        },
        fixError: (e) {
          // 如果失败了，就下载apk更新
          _updateWithApk(version, showToast);
        },
        downloadError: (e) {
          ToastProvider.error(e.toString());
        },
      );
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
    DownloadManager.getInstance().download(
      DownloadItem(
        url: version.path,
        fileName: version.apkName,
        title: '微北洋',
        showNotification: true,
        type: DownloadType.apk,
      ),
      error: (message) {
        debugPrint("ffffffffffffffffffffkkkkkkkkkkkkkkkkkkk");
        SmartDialog.showToast("下载失败");
        cancelDialog(DialogTag.apk);
        state = UpdateState.nothing;
      },
      success: (task) async {
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
              state = UpdateState.nothing;
              progress = 0;
            },
          );
        }
      },
      running: (task, p) {
        if (task.fileName == version.apkName) {
          progress = p;
        }
      },
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
          state = UpdateState.nothing;
        },
      );
    } else {
      state = UpdateState.nothing;
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
          state = UpdateState.nothing;
        },
      );
    } else {
      state = UpdateState.nothing;
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
          state = UpdateState.nothing;
        },
      );
    } else {
      state = UpdateState.nothing;
    }
  }

  Future<void> _deleteOriginalFile() async {
    final dir =
        (await getExternalStorageDirectories(type: StorageDirectory.downloads))
            ?.first;
    if (dir == null) {
      // 没有这个文件夹就很尬
    }
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

  Future<void> forceUpdateApk(int testVersionCode) async {
    state = UpdateState.checkUpdate;
    var response = await updateDio.get(UpdateService.wbyUpdateUrl);
    var version =
        VersionData.fromJson(jsonDecode(response.data.toString())).info!.beta;
    if (testVersionCode + version.flutterFixCode < version.versionCode) {
      _updateWithApk(version, true);
    } else if (testVersionCode < version.versionCode &&
        testVersionCode + version.flutterFixCode >= version.versionCode) {
      hotFix(
          version.flutterFixSoFile, version.versionCode, version.flutterFixCode,
          fixLoadSoFileSuccess: () {
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
    state = UpdateState.checkUpdate;
    var response = await updateDio.get(UpdateService.wbyUpdateUrl);
    var version =
        VersionData.fromJson(jsonDecode(response.data.toString())).info!.beta;
    hotFix(
        version.flutterFixSoFile, version.versionCode, version.flutterFixCode,
        fixLoadSoFileSuccess: () {
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
