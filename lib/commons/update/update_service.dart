import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_manager.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/update_prompter.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

const wby_flutter_model_version = 1;

/// 版本更新管理
class UpdateManager {
  // TODO: 检查更新的同时应该删除旧的安装包
  // TODO: 这里检查只检查 versionCode,不检查fixCode
  static void checkUpdate({bool showToast = false}) {
    UpdateService.checkUpdate(
        onResult: _updateApp,
        onSuccess: () {
          ToastProvider.success(wby_flutter_model_version.toString());
          if (showToast) ToastProvider.success('已是最新版本');
        },
        onFailure: (_) {
          if (showToast) ToastProvider.error("检查更新失败");
        });
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
  static Future<void> _updateApp(Version version) async {
    final localVersion = await UpdateUtil.getVersionCode();
    if (localVersion + version.flutterFixCode < version.versionCode) {
      // 安卓端进行了更改，只能通过下载新的安装包更新
      debugPrint("$localVersion + ${version.flutterFixCode} + ${version.flutterFixSoFile}");
      updateWithApk(version);
    } else if (localVersion < version.versionCode &&
        localVersion + version.flutterFixCode >= version.versionCode) {
      // 则代表可以通过热修复更新 也可以通过下载新的安装包更新
      // 若用户打开自动更新，则在后台下载libapp.so并在完成后提示用户下次打开后应用更新
      // 若用户没打开自动更新，则弹出对话框
      if (CommonPreferences().autoUpdateApp.value) {
        // 自动更新，不弹出对话框
        HotfixManager.getInstance().hotfixDownloadAndLoadNext(
            version.versionCode, version.flutterFixSoFile, loadSuccess: () {
          ToastProvider.success("应用将在重启后加载更新");
        }, fixDefaultError: () {
          // 如果失败了，就下载apk更新
          ToastProvider.error("热更新失败");
          updateWithApk(version);
        });
      } else {
        // 手动更新，弹出对话框，让用户选择：热更新（下载完毕后立刻加载），热更新（下次启动时加载），下载安装包
      }
    }
  }

  static updateWithApk(Version version) {
    UpdatePrompter(
      updateEntity: version,
    ).show(version);
  }

  static autoUpdateSoFile(Version version) {}
}

class UpdateDio extends DioAbstract {
  @override
  ResponseType responseType = ResponseType.plain;
}

final updateDio = UpdateDio();

class UpdateService with AsyncTimer {
  static checkUpdate(
      {@required OnResult<Version> onResult,
      @required OnSuccess onSuccess,
      @required OnFailure onFailure}) async {
    AsyncTimer.runRepeatChecked('checkUpdate', () async {
      try {
        var response = await updateDio
            .get('https://mobile-api.twt.edu.cn/api/app/latest-version/2');
        var version = await parseJson(response.data.toString());
        if (version == null)
          onSuccess();
        else
          onResult(version);
      } on DioError catch (e) {
        onFailure(e);
      }
    });
  }
}

Future<Version> parseJson(String json) async {
  final data = VersionData.fromJson(jsonDecode(json));
  if (data == null || data.success != 1) {
    return null;
  }
  final apkType = CommonPreferences().apkType.value;
  Version version;
  if (apkType != "release") {
    // beta
    version = data.info.beta;
  } else {
    version = data.info.release;
  }
  final localVersionCode = await UpdateUtil.getVersionCode();
  print("localVersionCode  $localVersionCode");
  print("remoteVersionCode ${version.versionCode}");
  if (version.versionCode <= localVersionCode) {
    return null;
  }
  // 说明版本落后了，需要更新
  return version;
}
