import 'package:flutter/cupertino.dart';
import 'package:wei_pei_yang_demo/commons/update/common.dart';
import 'package:wei_pei_yang_demo/commons/update/http.dart';
import 'package:wei_pei_yang_demo/commons/update/update_parser.dart';
import 'package:wei_pei_yang_demo/commons/update/update_prompter.dart';


/// 版本更新管理
class UpdateManager {
  ///全局初始化
  static init(
      {String baseUrl, int timeout = 5000, Map<String, dynamic> headers}) {
    HttpUtils.init(baseUrl: baseUrl, timeout: timeout, headers: headers);
  }

  static void checkUpdate(BuildContext context, String url) {
    HttpUtils.get(url).then((response) {
      UpdateParser.parseJson(response.toString()).then((value) => {
            UpdatePrompter(
                updateEntity: value,
                onInstall: (String filePath) {
                  CommonUtils.installAPP(filePath);
                }).show(context)
          });
    }).catchError((onError) {
      // ToastProvider.error(onError.toString());
      throw onError;
    });
  }
}

typedef InstallCallback = Function(String filePath);
