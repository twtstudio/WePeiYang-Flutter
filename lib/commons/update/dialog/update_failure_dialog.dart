// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/channel/install/install.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/today_check.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

// 下载安装apk时的dialog
class UpdateFailureDialog extends StatelessWidget {
  const UpdateFailureDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);
    void cancel() {
      manager.setIdle();
    }

    void retry() {
      // 弹出进度对话框
      UpdateDialog.progress.show();
      context.read<UpdateManager>().setDownload();
    }

    void goToMarket() {
      InstallManager.goToMarket();
    }

    void goToWeb() {
      launch("https://mobile.twt.edu.cn/wpy/index.html");
    }

    Widget buttons;

    if (manager.version.isForced) {
      buttons = Column(
        children: InstallManager.canGoToMarket
            ? [
                WbyDialogStandardTwoButton(
                  first: goToWeb,
                  second: goToMarket,
                  firstText: '前往网页下载',
                  secondText: '前往应用市场',
                  secondType: ButtonType.light,
                ),
                SizedBox(height: size.verticalPadding),
                WbyDialogButton(
                  onTap: retry,
                  text: '重试',
                  type: ButtonType.dark,
                  expand: true,
                ),
              ]
            : [
                WbyDialogStandardTwoButton(
                  first: goToWeb,
                  second: retry,
                  firstText: '前往网页下载',
                  secondText: '重试',
                ),
              ],
      );
    } else {
      // 如果不是强制更新，那么就可以现在不更新
      buttons = Column(
        children: InstallManager.canGoToMarket
            ? [
                WbyDialogStandardTwoButton(
                  first: goToWeb,
                  second: goToMarket,
                  firstText: '前往网页下载',
                  secondText: '前往应用市场',
                  secondType: ButtonType.light,
                ),
                SizedBox(height: size.verticalPadding),
                WbyDialogStandardTwoButton(
                  first: cancel,
                  second: retry,
                  firstText: '稍后更新',
                  secondText: '重试',
                ),
              ]
            : [
                WbyDialogStandardTwoButton(
                  first: goToWeb,
                  second: cancel,
                  firstText: '前往网页下载',
                  secondText: '稍后更新',
                  secondType: ButtonType.light,
                ),
                SizedBox(height: size.verticalPadding),
                WbyDialogButton(
                  onTap: retry,
                  text: '重试',
                  type: ButtonType.dark,
                  expand: true,
                ),
              ],
      );
    }

    final failureText = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "更新失败",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
          padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UpdateTitle(),
              SizedBox(height: size.verticalPadding),
              UpdateDetail(),
              SizedBox(height: size.verticalPadding),
              failureText,
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
