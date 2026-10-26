import 'package:flutter/material.dart';

/// Keeps comment-input state stable while the keyboard and editor change size.
class CommentInputSize extends StatelessWidget {
  const CommentInputSize({
    super.key,
    required this.keyboardVisible,
    required this.child,
  });

  final bool keyboardVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSize(
        clipBehavior: Clip.antiAlias,
        // A zero duration notifies AnimatedSize synchronously during layout in
        // Flutter 3.44. Finish on the next frame while keeping the editor mounted.
        duration: keyboardVisible
            ? const Duration(milliseconds: 1)
            : const Duration(milliseconds: 300),
        curve: Curves.easeOutSine,
        child: child,
      );
}
