import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

///版本更新默认的方法
class UpdateParser {
  /// 解析器
  static Future<Version> parseJson(String json) async {
    Version release = VersionData.fromJson(jsonDecode(json)).info.release;
    if (release == null || release.versionCode == 0) {
      return null;
    }
    String versionCode = await CommonUtils.getVersionCode();
    // debugPrint("versionCode local $versionCode");
    // debugPrint("versionCode remote ${release.versionCode}");
    if (release.versionCode <= int.parse(versionCode)) {
      return null;
    }
    return release;
  }
}
