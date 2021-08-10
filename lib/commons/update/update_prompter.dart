import 'dart:io';

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/common.dart';
import 'package:we_pei_yang_flutter/commons/update/http.dart';
import 'package:we_pei_yang_flutter/commons/update/update.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class UpdatePrompter {
  /// 版本更新信息
  final Version updateEntity;

  final InstallCallback onInstall;

  UpdateDialog _dialog;

  double _progress = 0.0;

  File _apkFile;

  UpdatePrompter({@required this.updateEntity, @required this.onInstall});

  void show(BuildContext context, Version version) async {
    if (_dialog != null && _dialog.isShowing()) {
      return;
    }
    String title = "是否升级到${updateEntity.version}版本？";
    String updateContent = getUpdateContent();
    if (Platform.isAndroid) {
      _apkFile = await CommonUtils.getApkFileWithTemporaryName(updateEntity);
      // debugPrint("apkfile path:");
      // debugPrint(_apkFile.path);
    }
    if (_apkFile != null && _apkFile.existsSync()) {
      _dialog = UpdateDialog.showUpdate(
        context,
        title: title,
        updateContent: updateContent,
        updateButtonText: "安装",
        extraHeight: 10,
        onUpdate: doInstall,
        version: version,
      );
    } else {
      _dialog = UpdateDialog.showUpdate(
        context,
        title: title,
        updateContent: updateContent,
        extraHeight: 10,
        enableIgnore: true,
        onIgnore: () => Navigator.pop(context),
        onUpdate: onUpdate,
        version: version,
      );
    }
  }

  String getUpdateContent() {
    // String targetSize = '24.6mb';
    // // CommonUtils.getTargetSize(updateEntity.apkSize.toDouble());
    // String updateContent = "";
    // if (targetSize.isNotEmpty) {
    //   updateContent += "新版本大小：$targetSize\n";
    // }
    // updateContent += updateEntity.content;
    // return updateContent;
    return updateEntity.content;
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
      // debugPrint(path);
      // debugPrint(updateEntity.path);
      var newPath = _apkFile.absolute.parent.path + "/" + path;
      // debugPrint(newPath);
      await _apkFile.rename(newPath).then((_) => doInstall(newPath));
    }).catchError((value) {
      ToastProvider.error("下载失败！");
      _dialog.dismiss();
      // debugPrint(value.toString());
    });
  }

  /// 安装
  void doInstall([String path]) {
    _dialog.dismiss();
    // debugPrint("abcdefg   ${_apkFile.absolute.path}");
    onInstall.call(path ?? _apkFile.absolute.path);
  }
}
