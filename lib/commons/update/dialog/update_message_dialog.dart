// @dart = 2.12

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

// 下载安装apk时的dialog
class UpdateMessageDialog extends StatelessWidget {
  const UpdateMessageDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);
    void cancel() {
      // 设置跳过这个版本
      CommonPreferences.ignoreUpdateVersion.value = manager.version.version;
      manager.setIdle();
    }

    void ok() {
      if (Platform.isAndroid) {
        // 弹出进度对话框
        UpdateDialog.progress.show();
        context.read<UpdateManager>().setDownload();
      } else if (Platform.isIOS) {
        launchUrl(Uri.parse('itms-apps://itunes.apple.com/app/id1542905353'));
      }
    }

    Widget buttons;

    if (manager.version.isForced) {
      buttons = WbyDialogButton(
        onTap: ok,
        text: '应用版本过低，立刻更新',
        type: ButtonType.blue,
        expand: true,
      );
    } else {
      buttons = WbyDialogStandardTwoButton(
        first: cancel,
        second: ok,
        firstText: '跳过此版本',
        secondText: '立刻更新',
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
              SizedBox(height: size.verticalPadding),
            ],
          ),
        ),
      ],
    );

    return WbyDialogLayout(child: column, bottomPadding: false);
  }
}
