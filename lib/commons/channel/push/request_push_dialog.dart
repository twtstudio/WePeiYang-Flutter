// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

class RequestPushDialog extends StatelessWidget {
  const RequestPushDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = DialogSize.getSize(context);

    final buttons = WbyDialogStandardTwoButton(
      first: context.read<PushManager>().closeDialogAndTurnOffPush,
      second: context.read<PushManager>().closeDialogAndRetryTurnOnPush,
      firstText: "取消",
      secondText: "打开",
    );

    final message = Text(
      "获取微北洋推送服务需要通知权限\n请手动打开通知权限",
      style: TextUtil.base.normal,
    );

    final column = Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 30),
            ],
          ),
          SizedBox(height: size.verticalPadding),
          Center(child: message),
          SizedBox(height: size.verticalPadding),
          buttons,
        ],
      ),
    );

    return WbyDialogLayout(child: column);
  }
}
