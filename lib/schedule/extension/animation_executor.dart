import 'dart:async' show Timer;
import 'package:flutter/widgets.dart';

typedef Builder = Widget Function(
    BuildContext context, AnimationController animationController);

class AnimationExecutor extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final Builder builder;

  const AnimationExecutor({
    Key key,
    @required this.duration,
    this.delay = Duration.zero,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  _AnimationExecutorState createState() => _AnimationExecutorState();
}

class _AnimationExecutorState extends State<AnimationExecutor>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: widget.duration, vsync: this);
    _timer = Timer(widget.delay, () => _animationController.forward());
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, _) => widget.builder(context, _animationController),
      animation: _animationController,
    );
  }
}
