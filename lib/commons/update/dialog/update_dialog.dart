// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'update_failure_dialog.dart';
import 'update_hotfix_dialog.dart';
import 'update_install_dialog.dart';
import 'update_message_dialog.dart';
import 'update_progress_dialog.dart';

enum UpdateDialog { message, hotfix, install, progress, failure }

extension UpdateDialogExt on UpdateDialog {
  String get tag => [
        'messageDialog',
        'hotfixDialog',
        'installDialog',
        'progressDialog',
        'failure',
      ][index];

  Widget get dialog => [
        UpdateMessageDialog(),
        UpdateHotfixFinishDialog(),
        UpdateInstallDialog(),
        UpdateProgressDialog(),
        UpdateFailureDialog(),
      ][index];

  void show() {
    // 显示这个dialog
    SmartDialog.show(
      clickBgDismissTemp: false,
      backDismiss: false,
      tag: tag,
      widget: dialog,
    );

    // 清除其他dialog
    cancelAll();

    // 将现在的这个dialog加入到set中
    _show.add(this);
  }

  Future<void> cancel() async {
    if (!_show.contains(this)) return;
    await SmartDialog.dismiss(status: SmartStatus.dialog, tag: tag);
    _show.remove(this);
  }

  void cancelAll() {
    for (var d in _show) {
      d.cancel();
    }
    _show.clear();
  }

  bool get exist => _show.contains(this);
}

Set<UpdateDialog> _show = Set();
