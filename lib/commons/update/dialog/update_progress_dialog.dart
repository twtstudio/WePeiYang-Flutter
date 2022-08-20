// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_dialog.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_progress_bar.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

class UpdateProgressDialog extends StatelessWidget {
  const UpdateProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.read<UpdateManager>();

    final size = DialogSize.getSize(context);

    final progressBar = Selector<UpdateManager, double>(
      builder: (_, progress, __) {
        final progressHeight = 2.0;
        if (progress == 0) {
          return Loading();
        } else {
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
        }
      },
      selector: (_, manager) => manager.progress,
    );

    Widget dismiss;

    if (manager.version.isForced) {
      dismiss = TextButton(
        onPressed: () {
          ToastProvider.running("正在下载，请稍等");
        },
        child: Text(
          "稍等片刻...",
          style: TextStyle(
            color: Color(0xff62677b),
            fontSize: 12,
          ),
        ),
      );
    } else {
      dismiss = TextButton(
        onPressed: () {
          UpdateDialog.progress.cancel();
        },
        child: Text(
          "点击隐藏窗口",
          style: TextStyle(
            color: Color(0xff62677b),
            fontSize: 12,
          ),
        ),
      );
    }

    final column = Padding(
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UpdateTitle(),
          SizedBox(height: size.verticalPadding),
          UpdateDetail(),
          SizedBox(height: size.verticalPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [progressBar],
          ),
          SizedBox(height: size.verticalPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [dismiss],
          ),
        ],
      ),
    );

    return WbyDialogLayout(child: column);
  }
}
