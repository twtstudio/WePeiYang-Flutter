// @dart = 2.12
import 'package:flutter/material.dart';

class WbyDialogLayout extends StatelessWidget {
  final Widget child;
  final bool padding;

  const WbyDialogLayout({
    Key? key,
    required this.child,
    this.padding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = DialogSize.getSize(context);

    return Container(
      width: size.dialogWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.dialogRadius),
        color: Colors.white,
      ),
      child: padding
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.horizontalPadding,
                vertical: size.verticalPadding,
              ),
              child: child,
            )
          : child,
    );
  }
}

class DialogSize {
  final double dialogWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double dialogRadius;

  DialogSize._(this.dialogWidth, this.horizontalPadding, this.verticalPadding,
      this.dialogRadius);

  factory DialogSize.getSize(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final dialogWidth = windowWidth * 0.77;
    final horizontalPadding = dialogWidth * 0.1;
    final verticalPadding = dialogWidth * 0.07;
    final dialogRadius = dialogWidth * 0.077;
    return DialogSize._(
      dialogWidth,
      horizontalPadding,
      verticalPadding,
      dialogRadius,
    );
  }
}
