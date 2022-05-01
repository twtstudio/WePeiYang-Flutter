// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/layout.dart';

enum ButtonType { light, dark }

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
          color: type == ButtonType.dark ? Color(0xff62677b) : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              offset: Offset(0, 2),
              blurRadius: 20,
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: type == ButtonType.dark ? Colors.white : Colors.black,
          ),
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
    this.secondType = ButtonType.dark,
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
