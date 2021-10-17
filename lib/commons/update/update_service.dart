import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/update_prompter.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';

/// 版本更新管理
class UpdateManager {
  static void checkUpdate({bool showDialog = false}) {
    UpdateService.checkUpdate(onResult: (version) {
      UpdatePrompter(
        updateEntity: version,
      ).show(WePeiYangApp.navigatorState.currentState.overlay.context, version);
    }, onSuccess: () {
      if (showDialog) ToastProvider.success('已是最新版本');
    }, onFailure: (_) {
      if (showDialog) ToastProvider.error("检查更新失败");
    });
  }
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

/// 解析器
Future<Version> parseJson(String json) async {
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
