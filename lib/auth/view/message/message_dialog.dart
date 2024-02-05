import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

import '../../../commons/themes/wpy_theme.dart';

class MessageDialog extends Dialog {
  final data;

  const MessageDialog(this.data);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 200,
        width: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
            color: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor)),
        child: Center(child: Text(data)),
      ),
    );
  }
}
