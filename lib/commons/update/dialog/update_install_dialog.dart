// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/install/install.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/today_check.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

// 下载安装apk时的dialog
class UpdateInstallDialog extends StatelessWidget {
  const UpdateInstallDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);

    void cancel() {
      manager.setIdle();
    }

    void ok() {
      InstallManager.install(manager.version.apkPath);
      if (!manager.version.isForced) manager.setIdle();
    }

    Widget buttons;

    if (manager.version.isForced) {
      buttons = WbyDialogButton(
        onTap: ok,
        text: '立刻安装',
        type: ButtonType.dark,
        expand: true,
      );
    } else {
      buttons = WbyDialogStandardTwoButton(
        first: cancel,
        second: ok,
        firstText: "稍后安装",
        secondText: "立刻安装",
      );
    }

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
              UpdateTitle(),
              SizedBox(height: size.verticalPadding),
              UpdateDetail(),
              SizedBox(height: size.verticalPadding),
              buttons,
            ],
          ),
        ),
        TodayShowAgainCheck(tap: cancel),
      ],
    );

    return WbyDialogLayout(child: column, bottomPadding: false);
  }
}
