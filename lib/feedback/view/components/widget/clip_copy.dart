import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';

class CommentCardGestureDetector extends StatelessWidget {
  final Widget child;
  final String copy;
  final String toast;
  final int id;
  final bool isOfficial; // 官方回复card点击后需要进入详情页，所以不需要弹出输入框

  const CommentCardGestureDetector({
    Key? key,
    required this.child,
    required this.copy,
    required this.toast,
    required this.id,
    required this.isOfficial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOfficial
          ? null
          : () {
              if (Provider.of<NewFloorProvider>(context, listen: false)
                  .inputFieldEnabled) {
                context.read<NewFloorProvider>().clearAndClose();
              } else {
                Provider.of<NewFloorProvider>(context, listen: false)
                    .inputFieldOpenAndReplyTo(id);
                FocusScope.of(context).requestFocus(
                    Provider.of<NewFloorProvider>(context, listen: false)
                        .focusNode);
              }
            },
      onLongPress: () {
        ClipboardData data = ClipboardData(text: copy);
        Clipboard.setData(data);
        ToastProvider.success(toast);
      },
      child: child,
    );
  }
}
