import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

import '../../themes/template/wpy_theme_data.dart';
import '../../themes/wpy_theme.dart';
import '../w_button.dart';

enum ButtonType { light, dark, blue }

class WbyDialogButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final ButtonType type;
  final bool expand;

  const WbyDialogButton({
    Key? key,
    required this.onTap,
    required this.text,
    required this.type,
    this.expand = false,
  }) : super(key: key);

  Color _buttonColor(context) {
    if (type == ButtonType.blue)
      return WpyTheme.of(context).get(WpyThemeKeys.primaryActionColor);
    else if (type == ButtonType.dark)
      return ColorUtil.grey6267Color;
    else
      return WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor);
  }

  Color _textColor(context) {
    if (type == ButtonType.dark || type == ButtonType.blue)
      return WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor);
    else
      return WpyTheme.of(context).get(WpyThemeKeys.basicTextColor);
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = DialogSize.getSize(context).dialogWidth;
    final buttonWidth = dialogWidth * 0.36;
    final buttonHeight = buttonWidth * 0.368;
    final buttonRadius = buttonWidth * 0.08;

    return WButton(
      onPressed: onTap,
      child: Container(
        width: expand ? null : buttonWidth,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: _buttonColor(context),
          boxShadow: [
            BoxShadow(
              color: ColorUtil.black19,
              offset: Offset(0, 2),
              blurRadius: 20,
            )
          ],
        ),
        child: Text(
          text,
          style: TextUtil.base.w600.sp(12).customColor(_textColor(context)),
        ),
      ),
    );
  }
}

class WbyDialogStandardTwoButton extends StatelessWidget {
  final VoidCallback first;
  final VoidCallback second;
  final String firstText;
  final String secondText;
  final ButtonType firstType;
  final ButtonType secondType;

  const WbyDialogStandardTwoButton({
    Key? key,
    required this.first,
    required this.second,
    required this.firstText,
    required this.secondText,
    this.firstType = ButtonType.light,
    this.secondType = ButtonType.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstButton = WbyDialogButton(
      onTap: first,
      text: firstText,
      type: firstType,
    );

    final secondButton = WbyDialogButton(
      onTap: second,
      text: secondText,
      type: secondType,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            firstButton,
            secondButton,
          ],
        ),
      ],
    );
  }
}
