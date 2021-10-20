import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class ClipCopy extends StatelessWidget {
  final Widget child;
  final String copy;
  final String toast;

  const ClipCopy({
    Key key,
    @required this.child,
    @required this.copy,
    @required this.toast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        ClipboardData data = ClipboardData(text: copy);
        Clipboard.setData(data);
        ToastProvider.success(toast);
      },
      child: child,
    );
  }
}
