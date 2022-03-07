// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/today_check.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

import 'update_progress_bar.dart';

// 下载安装apk时的dialog
class UpdateApkDialog extends StatelessWidget {
  final Version version;

  const UpdateApkDialog(this.version, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.select((UpdateManager manager) => manager.state);
    final size = DialogSize.getSize(context);
    if (state == UpdateState.checkUpdate) {
      final buttons = WbyDialogStandardTwoButton(
        cancel: () {
          context.read<UpdateManager>().cancelDialog(DialogTag.apk);
        },
        ok: () {
          context.read<UpdateManager>().download(version);
        },
        cancelText: '稍后更新',
        okText: '立刻更新',
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
          TodayShowAgainCheck(),
        ],
      );

      return WbyDialogLayout(child: column,padding: false);
    } else {
      final progressBar = Selector<UpdateManager, double>(
        builder: (_, progress, __) {
          debugPrint('show _progress : $progress');
          final progressHeight = 2.0;
          return SizedBox(
            width: size.dialogWidth - size.horizontalPadding * 2,
            height: progressHeight,
            child: GradientLinearProgressBar(
              value: progress,
              strokeWidth: progressHeight,
              colors: [
                Color(0x2262677b),
                Color(0x8862677b),
                Color(0xff62677b),
              ],
            ),
          );
        },
        selector: (_, manager) => manager.progress,
      );

      final dismiss = TextButton(
        onPressed: () {
          context.read<UpdateManager>().cancelDialog(DialogTag.apk);
        },
        child: Text(
          "隐藏窗口",
          style: TextStyle(
            color: Color(0xff62677b),
            fontSize: 12,
          ),
        ),
      );

      final column = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UpdateTitle(version),
          SizedBox(height: size.verticalPadding),
          UpdateDetail(version),
          SizedBox(height: size.verticalPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [progressBar],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [dismiss],
          ),
        ],
      );

      return WbyDialogLayout(child: column);
    }
  }
}
