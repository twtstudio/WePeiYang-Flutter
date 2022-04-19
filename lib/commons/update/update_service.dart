// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class UpdateDio extends DioAbstract {}

final updateDio = UpdateDio();

class UpdateService with AsyncTimer {
  static const BASEURL = 'https://upgrade.twt.edu.cn/androidupdate/';

  /// 获取最新版本，如果失败则返回null
  static Future<Version?> get latestVersion async {
    try {
      var code = UpdateUtil.apkType == ApkType.release ? 1 : 0;
      var response = await updateDio.get("${BASEURL}check/$code");
      debugPrint(response.data.toString());
      return VersionData.fromJson(response.data).data;
    } catch (error, stack) {
      Logger.reportError(error, stack);
      return null;
    }
  }
}