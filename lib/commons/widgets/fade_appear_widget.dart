import 'package:flutter/material.dart';

class AnimatedAppear extends StatefulWidget {
  AnimatedAppear({
    super.key,
    required this.child,
    required this.duration,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
  });

  final AnimatedSwitcherTransitionBuilder transitionBuilder;
  final Widget child;
  final Duration duration;

  @override
  State<AnimatedAppear> createState() => _AnimatedAppearState();
}

class _AnimatedAppearState extends State<AnimatedAppear>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..forward();

  late Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.transitionBuilder(
      widget.child,
      _animation,
    );
  }
}
