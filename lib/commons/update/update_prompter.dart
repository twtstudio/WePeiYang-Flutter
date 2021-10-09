import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/update/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

typedef InstallCallback = Function(String filePath);

class UpdatePrompter {
  final Version updateEntity;

  final InstallCallback onInstall;

  UpdateDialog _dialog;

  UpdatePrompter({@required this.updateEntity, @required this.onInstall});

  void show(BuildContext context, Version version) async {
    if (_dialog != null && _dialog.isShowing) {
      return;
    }
    _dialog = UpdateDialog.showUpdate(
      context,
      onUpdate: onUpdate,
      version: version,
    );
  }

  Future<void> onUpdate() async {
    if (Platform.isIOS) {
      return;
    }
    _dialog.update(0);
    var arguments = {
      'url': updateEntity.path,
      'version': "${updateEntity.path}-${updateEntity.versionCode}"
    };
    eventChannel.receiveBroadcastStream(arguments).listen(
      (progress) {
        _dialog.update(progress);
      },
      onError: (_) {
        ToastProvider.error("下载失败！请确保网络通畅");
        _dialog.dismiss();
      },
      cancelOnError: true,
    );
  }
}

const eventChannel = EventChannel('com.twt.service/update');