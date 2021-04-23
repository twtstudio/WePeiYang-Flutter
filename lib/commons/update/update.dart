import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/update/app_cache_manager.dart';
import 'package:wei_pei_yang_demo/commons/update/common.dart';
import 'package:wei_pei_yang_demo/commons/update/http.dart';
import 'package:wei_pei_yang_demo/commons/update/update_parser.dart';
import 'package:wei_pei_yang_demo/commons/update/update_prompter.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

/// 版本更新管理
class UpdateManager {
  ///全局初始化
  static init(
      {String baseUrl,
      int timeout = 5000,
      Map<String, dynamic> headers,
      BuildContext context}) {
    HttpUtils.init(baseUrl: baseUrl, timeout: timeout, headers: headers);
    baseContext = context;
  }

  static BuildContext baseContext;

  static void checkUpdate() {
    // searchLocalCache();
    // delAllTemporaryFile();
    String url = 'https://mobile-api.twt.edu.cn/api/app/latest-version/2';
    searchLocalCache();
    HttpUtils.get(url).then((response) {
      UpdateParser.parseJson(response.toString())?.then((value) {
        UpdatePrompter(
            updateEntity: value,
            onInstall: (String filePath) {
              CommonUtils.installAPP(filePath);
            }).show(baseContext, value);
      });
    }).catchError((onError) {
      // ToastProvider.error(onError.toString());
      ToastProvider.error("检查更新失败");
    });
  }
}

typedef InstallCallback = Function(String filePath);
