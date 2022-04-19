// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/today_check.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

// 下载安装apk时的dialog
class UpdateMessageDialog extends StatelessWidget {
  const UpdateMessageDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);
    void cancel() {
      manager.setIdle();
    }

    void ok() {
      // 弹出进度对话框
      UpdateDialog.progress.show();
      context.read<UpdateManager>().setDownload();
    }

    Widget buttons;

    if (manager.version.isForced) {
      buttons = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WbyDialogButton(
            onTap: ok,
            text: '立刻更新',
            type: ButtonType.dark,
          ),
        ],
      );
    } else {
      buttons = WbyDialogStandardTwoButton(
        cancel: cancel,
        ok: ok,
        cancelText: '稍后更新',
        okText: '立刻更新',
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
              SizedBox(height: size.verticalPadding),
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

    return WbyDialogLayout(child: column, padding: false);
  }
}
