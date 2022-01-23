// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/hotfix/hotfix_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog_state.dart';
import 'package:we_pei_yang_flutter/commons/update/install_util..dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:provider/provider.dart';

// 下载安装apk时的dialog
class UpdateInstallDialog extends StatefulWidget {
  final Version version;

  const UpdateInstallDialog(this.version, {Key? key}) : super(key: key);

  @override
  _UpdateInstallDialogState createState() => _UpdateInstallDialogState();
}

class _UpdateInstallDialogState extends UpdateDialogState<UpdateInstallDialog> {
  @override
  Version get version => widget.version;

  @override
  String get okButtonText => "立刻安装";

  @override
  String get cancelButtonText => "稍后安装";

  @override
  void okButtonTap() {
    InstallUtil.install(version.apkName);
  }

  @override
  void cancelButtonTap() {
    context.read<UpdateManager>().cancelDialog(DialogTag.install);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
