// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/update_progress_bar.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/util.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_detail.dart';
import 'package:we_pei_yang_flutter/commons/update/dialog/widgets/update_title.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

class UpdateProgressDialog extends StatelessWidget {
  final Version version;

  const UpdateProgressDialog(this.version, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = DialogSize.getSize(context);
    final progressBar = Selector<UpdateManager, double>(
      builder: (_, progress, __) {
        debugPrint('show _progress : $progress');
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

    final dismiss = TextButton(
      onPressed: () {
        context.read<UpdateManager>().cancelDialog(DialogTag.progress);
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
