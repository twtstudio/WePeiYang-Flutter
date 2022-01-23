// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog_state.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

import 'update_progress_bar.dart';

// 下载安装apk时的dialog
class UpdateApkDialog extends StatefulWidget {
  final Version version;

  const UpdateApkDialog(this.version, {Key? key}) : super(key: key);

  @override
  _UpdateApkDialogState createState() => _UpdateApkDialogState();
}

class _UpdateApkDialogState extends UpdateDialogState<UpdateApkDialog> {
  @override
  Version get version => widget.version;

  @override
  void cancelButtonTap() {
    context.read<UpdateManager>().cancelDialog(DialogTag.apk);
  }

  @override
  String get cancelButtonText => '稍后更新';

  @override
  void okButtonTap() {
    context.read<UpdateManager>().download(widget.version);
  }

  @override
  String get okButtonText => '立刻更新';

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = context.select((UpdateManager manager) => manager.state);
    if (state == UpdateState.checkUpdate) {
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
    } else {
      final progressBar = Selector<UpdateManager, double>(
        builder: (_, progress, __) {
          debugPrint('show _progress : $progress');
          final progressHeight = 2.0;
          return SizedBox(
            width: dialogWidth - horizontalPadding * 2,
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
        onPressed: cancelButtonTap,
        child: Text(
          "隐藏窗口",
          style: TextStyle(
            color: Color(0xff62677b),
            fontSize: 12,
          ),
        ),
      );

      final column = Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: dialogWidth * 0.07),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [title],
            ),
            SizedBox(height: dialogWidth * 0.07),
            detail,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [progressBar],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [dismiss],
            )
          ],
        ),
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
}
