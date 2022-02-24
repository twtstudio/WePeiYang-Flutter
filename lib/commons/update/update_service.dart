// @dart =2.12
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class UpdateDio extends DioAbstract {
  @override
  ResponseType responseType = ResponseType.plain;
}

final updateDio = UpdateDio();

class UpdateService with AsyncTimer {
  static const githubTestUrl = 'https://239what475.github.io/update.json';
  static const wbyUpdateUrl =
      'https://mobile-api.twt.edu.cn/api/app/latest-version/2';

  static checkUpdate({
    required OnResult<Version> onResult,
    required OnSuccess onSuccess,
    required OnFailure onFailure,
  }) async {
    AsyncTimer.runRepeatChecked('checkUpdate', () async {
      try {
        var response = await updateDio.get(githubTestUrl);
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

Future<Version?> parseJson(String json) async {
  final data = VersionData.fromJson(jsonDecode(json));
  if (data.info == null || data.success != 1) {
    return null;
  }
  final apkType = CommonPreferences.apkType.value;
  Version version;
  if (apkType != "release") {
    // beta
    version = data.info!.beta;
  } else {
    version = data.info!.release;
  }
  final localVersionCode = await UpdateUtil.getVersionCode();
  debugPrint("localVersionCode  $localVersionCode");
  debugPrint("remoteVersionCode ${version.versionCode}");
  if (version.versionCode <= localVersionCode) {
    return null;
  }
  // 说明版本落后了，需要更新
  return version;
}
