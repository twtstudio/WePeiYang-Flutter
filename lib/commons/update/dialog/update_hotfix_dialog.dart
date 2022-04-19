// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/today_check.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

import '../../channel/install/hotfix.dart';

// 下载安装apk时的dialog
class UpdateHotfixFinishDialog extends StatelessWidget {
  const UpdateHotfixFinishDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);
    final messageRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
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

    void cancel() {
      manager.setIdle();
    }

    Future<void> ok() async {
      await HotFixManager.restartApp();
      manager.setIdle();
    }

    Widget buttons;

    if (manager.version.isForced) {
      buttons = WbyDialogButton(
        onTap: ok,
        text: '立刻重启',
        type: ButtonType.dark,
        expand: true,
      );
    } else {
      buttons = WbyDialogStandardTwoButton(
        cancel: cancel,
        ok: ok,
        cancelText: "稍后重启",
        okText: "立刻重启",
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
              SizedBox(height: size.dialogWidth * 0.04),
              messageRow,
              SizedBox(height: size.dialogWidth * 0.04),
              UpdateDetail(),
              SizedBox(height: size.dialogWidth * 0.04),
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
