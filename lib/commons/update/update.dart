import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/app_cache_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/update_service.dart';
import 'package:we_pei_yang_flutter/commons/update/update_prompter.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

/// 版本更新管理
class UpdateManager {
  ///全局初始化
  static init({BuildContext context}) {
    baseContext = context;
  }

  static BuildContext baseContext;

  static void checkUpdate({bool showDialog = false}) {
    // searchLocalCache();
    // delAllTemporaryFile();
    searchLocalCache();
    UpdateService.checkUpdate(onResult: (version) {
      UpdatePrompter(
              updateEntity: version,
              onInstall: (filePath) => CommonUtils.installAPP(filePath))
          .show(baseContext, version);
    }, onSuccess: () {
      if (showDialog) ToastProvider.success('已是最新版本');
    }, onFailure: (_) {
      if (showDialog) ToastProvider.error("检查更新失败");
    });
  }

  /// 解析器
  static Future<Version> parseJson(String json) async {
    Version release = VersionData.fromJson(jsonDecode(json)).info.release;
    if (release == null || release.versionCode == 0) {
      return null;
    }
    String versionCode = await CommonUtils.getVersionCode();
    print("versionCode local $versionCode");
    print("versionCode remote ${release.versionCode}");
    if (release.versionCode <= int.parse(versionCode)) {
      return null;
    }
    return release;
  }
}
