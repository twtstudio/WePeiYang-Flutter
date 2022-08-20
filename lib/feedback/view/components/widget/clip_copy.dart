import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';

class ClipCopy extends StatelessWidget {
  final Widget child;
  final String copy;
  final String toast;
  final int id;

  const ClipCopy({
    Key key,
    @required this.child,
    @required this.copy,
    @required this.toast,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Provider.of<NewFloorProvider>(context, listen: false)
            .inputFieldEnabled) {
          Provider.of<NewFloorProvider>(context, listen: false).clearAndClose();
        } else {
          Provider.of<NewFloorProvider>(context, listen: false)
              .inputFieldOpenAndReplyTo(id);
          FocusScope.of(context).requestFocus(
              Provider.of<NewFloorProvider>(context, listen: false).focusNode);
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
