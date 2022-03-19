// @dart = 2.12

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class UpdateDio extends DioAbstract {
  @override
  ResponseType responseType = ResponseType.plain;
}

final updateDio = UpdateDio();

class UpdateService with AsyncTimer {
  static const wbyUpdateUrl = 'https://mobile-api.twt.edu.cn/api/app/latest-version/2';

  static Future<VersionData?> get latestVersionData async {
    try {
      var response = await updateDio.get(wbyUpdateUrl);
      return VersionData.fromJson(response.data);
    } catch (error,stack){
      // TODO
      throw error;
    }
  }
}