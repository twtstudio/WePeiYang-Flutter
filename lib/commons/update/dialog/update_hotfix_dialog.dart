import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

import '../../channel/install/hotfix.dart';
import '../../util/text_util.dart';

// 下载安装apk时的dialog
class UpdateHotfixFinishDialog extends StatelessWidget {
  const UpdateHotfixFinishDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);
    final messageRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 12,
          color: ColorUtil.yellowF0,
        ),
        SizedBox(width: 4),
        Text(
          '本次更新需要重启后生效',
          style: TextUtil.base.yellowF0.sp(8),
        ),
      ],
    );

    void cancel() {
      manager.setIdle();
    }

    Future<void> ok() async {
      await HotFixManager.restartApp();
      if (!manager.version.isForced) manager.setIdle();
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
        first: cancel,
        second: ok,
        firstText: "稍后重启",
        secondText: "立刻重启",
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
              SizedBox(height: size.dialogWidth * 0.04),
              messageRow,
              SizedBox(height: size.dialogWidth * 0.04),
              UpdateDetail(),
              SizedBox(height: size.dialogWidth * 0.04),
              buttons,
              SizedBox(height: size.dialogWidth * 0.04),
            ],
          ),
        ),
      ],
    );

    return WbyDialogLayout(child: column, bottomPadding: false);
  }
}
