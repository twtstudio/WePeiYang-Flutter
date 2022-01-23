// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog_state.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

// 下载安装apk时的dialog
class UpdateHotfixFinishDialog extends StatefulWidget {
  final Version version;

  const UpdateHotfixFinishDialog(this.version, {Key? key}) : super(key: key);

  @override
  _UpdateHotfixFinishDialogState createState() => _UpdateHotfixFinishDialogState();
}

class _UpdateHotfixFinishDialogState extends UpdateDialogState<UpdateHotfixFinishDialog> {
  @override
  Version get version => widget.version;

  @override
  String get okButtonText => "立刻重启";

  @override
  String get cancelButtonText => "稍后重启";

  @override
  void okButtonTap() {
    HotfixManager.getInstance().restartApp();
  }

  @override
  void cancelButtonTap() {
    context.read<UpdateManager>().cancelDialog(DialogTag.hotfix);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final messageRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 12,
          color: Color(0xfff0ad4e),
        ),
        SizedBox(width: 4),
        Text(
          '本次更新需要重启后生效',
          style: TextStyle(
            fontSize: 8,
            color: Color(0xfff0ad4e),
          ),
        ),
      ],
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 为了给checkbox流出足够大的点击区域
        // 主要是因为Transform只能移动ui，不能移动点击区域
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: dialogWidth * 0.07),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title,
                ],
              ),
              SizedBox(height: dialogWidth * 0.04),
              messageRow,
              SizedBox(height: dialogWidth * 0.07),
              detail,
              updateButtons,
            ],
          ),
        ),
        checkbox,
      ],
    );

    return Container(
      width: dialogWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dialogRadius),
        color: Colors.white,
      ),
      child: column,
    );
  }
}
