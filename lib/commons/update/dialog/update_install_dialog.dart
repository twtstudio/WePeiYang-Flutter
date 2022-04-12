// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/install/install.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/today_check.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

import 'util.dart';

// 下载安装apk时的dialog
class UpdateInstallDialog extends StatelessWidget {
  final Version version;

  const UpdateInstallDialog(this.version, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = DialogSize.getSize(context);

    void cancel() {
      context.read<UpdateManager>().setIdle();
      context.read<UpdateManager>().cancelDialog(DialogTag.install);
    }

    void ok() {
      InstallManager.install(version.apkName);
      cancel();
    }

    final buttons = WbyDialogStandardTwoButton(
      cancel: cancel,
      ok: ok,
      cancelText: "稍后安装",
      okText: "立刻安装",
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 为了给checkbox流出足够大的点击区域
        // 主要是因为Transform只能移动ui，不能移动点击区域
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.verticalPadding),
              UpdateTitle(version),
              SizedBox(height: size.verticalPadding),
              UpdateDetail(version),
              SizedBox(height: size.verticalPadding),
              buttons,
            ],
          ),
        ),
        TodayShowAgainCheck(tap: cancel),
      ],
    );

    return WbyDialogLayout(child: column, padding: false);
  }
}
