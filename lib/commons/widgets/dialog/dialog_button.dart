import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_layout.dart';

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

  Color get _buttonColor {
    if (type == ButtonType.blue)
      return ColorUtil.blue2CColor;
    else if (type == ButtonType.dark)
      return ColorUtil.grey6267Color;
    else
      return ColorUtil.whiteFFColor;
  }

  Color get _textColor {
    if (type == ButtonType.dark || type == ButtonType.blue)
      return ColorUtil.whiteFFColor;
    else
      return ColorUtil.black00Color;
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = DialogSize.getSize(context).dialogWidth;
    final buttonWidth = dialogWidth * 0.36;
    final buttonHeight = buttonWidth * 0.368;
    final buttonRadius = buttonWidth * 0.08;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: expand ? null : buttonWidth,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: _buttonColor,
          boxShadow: const [
            BoxShadow(
              color: ColorUtil.black19,
              offset: Offset(0, 2),
              blurRadius: 20,
            )
          ],
        ),
        child: Text(
          text,
          style: TextUtil.base.w600.sp(12).customColor(_textColor),
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
