import 'package:flutter/material.dart';

class FluentFadeSwitcher extends StatefulWidget {
  Widget child;

  FluentFadeSwitcher({super.key, required this.child});

  @override
  State<FluentFadeSwitcher> createState() => _FluentFadeSwitcherState();
}

class _FluentFadeSwitcherState extends State<FluentFadeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: widget.child,
        ),
      ],
    );
  }
}
