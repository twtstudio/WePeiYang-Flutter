// @dart = 2.12
import 'package:flutter/cupertino.dart';

/// 统一Button样式
class WButton extends StatefulWidget {
  const WButton({Key? key, this.child, this.onPressed, this.decoration})
      : super(key: key);
  final Function()? onPressed;
  final Widget? child;
  final Decoration? decoration;

  @override
  _WButtonState createState() => _WButtonState();
}

class _WButtonState extends State<WButton> {
  @override
  Widget build(BuildContext context) {
    return widget.decoration == null
        ? CupertinoButton(
            child: widget.child!,
            onPressed: widget.onPressed,
            padding: EdgeInsets.zero,
            minSize: 0,
          )
        : DecoratedBox(
            decoration: widget.decoration!,
            child: CupertinoButton(
              child: widget.child!,
              onPressed: widget.onPressed,
              padding: EdgeInsets.zero,
              minSize: 0,
            ));
  }
}
