import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/update/UpdateDialog.dart';
import 'package:wei_pei_yang_demo/commons/update/common.dart';
import 'package:wei_pei_yang_demo/commons/update/http.dart';
import 'package:wei_pei_yang_demo/commons/update/update.dart';
import 'package:wei_pei_yang_demo/commons/update/version_data.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class UpdatePrompter {
  /// 版本更新信息
  final Version updateEntity;

  final InstallCallback onInstall;

  UpdateDialog _dialog;

  double _progress = 0.0;

  File _apkFile;

  UpdatePrompter({@required this.updateEntity, @required this.onInstall});

  void show(BuildContext context) async {
    if (_dialog != null && _dialog.isShowing()) {
      return;
    }
    String title = "是否升级到${updateEntity.version}版本？";
    String updateContent = getUpdateContent();
    if (Platform.isAndroid) {
      _apkFile = await CommonUtils.getApkFileWithTemporaryName(updateEntity);
    }
    if (_apkFile != null && _apkFile.existsSync()) {
      _dialog = UpdateDialog.showUpdate(
        context,
        title: title,
        updateContent: updateContent,
        updateButtonText: "安装",
        extraHeight: 10,
        onUpdate: doInstall,
      );
    } else {
      _dialog = UpdateDialog.showUpdate(
        context,
        title: title,
        updateContent: updateContent,
        extraHeight: 10,
        onUpdate: onUpdate,
      );
    }
  }

  String getUpdateContent() {
    String targetSize = '24.6mb';
    // CommonUtils.getTargetSize(updateEntity.apkSize.toDouble());
    String updateContent = "";
    if (targetSize.isNotEmpty) {
      updateContent += "新版本大小：$targetSize\n";
    }
    updateContent += updateEntity.content;
    return updateContent;
  }

  Future<void> onUpdate() async {
    if (Platform.isIOS) {
      doInstall();
      return;
    }

    HttpUtils.downloadFile(updateEntity.path, _apkFile.path,
        onReceiveProgress: (int count, int total) {
      _progress = count.toDouble() / total;
      if (_progress <= 1.0001) {
        _dialog.update(_progress);
      }
    }).then((value) async {
      var path = CommonUtils.getApkNameByDownloadUrl(updateEntity.path);
      _apkFile.rename(path);
      doInstall();
    }).catchError((value) {
      ToastProvider.error("下载失败！");
      _dialog.dismiss();
    });
  }

  /// 安装
  void doInstall() {
    _dialog.dismiss();
    onInstall.call(_apkFile != null ? _apkFile.path : updateEntity.path);
  }
}
