import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

class TodayShowAgainCheck extends StatelessWidget {
  final VoidCallback tap;

  const TodayShowAgainCheck({Key? key, required this.tap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isForced = context.read<UpdateManager>().version.isForced;

    final size = DialogSize.getSize(context);
    final checkboxLeftPadding = size.horizontalPadding;
    const checkboxElsePadding = 10.0;

    Widget dismiss;
    if (isForced) {
      dismiss = SizedBox(height: checkboxElsePadding * 2 - 4);
    } else {
      final checkboxTextWidget = Text(
        '今日不再弹出',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xffdedede),
        ),
      );

      dismiss = GestureDetector(
        onTap: () {
          UpdateUtil.setTodayNotCheckUpdate();
          tap();
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(
            left: checkboxLeftPadding,
            top: checkboxElsePadding + 4,
            bottom: checkboxElsePadding * 2 - 4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: checkboxElsePadding + 10),
              checkboxTextWidget,
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dismiss,
      ],
    );
  }
}
