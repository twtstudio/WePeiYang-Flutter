import 'package:flutter/material.dart';

class ForceAdjustableScrollPhysics extends ScrollPhysics {
  double scrollFactor = 1;

  ForceAdjustableScrollPhysics(
      {required this.scrollFactor, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  ForceAdjustableScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ForceAdjustableScrollPhysics(
        scrollFactor: scrollFactor, parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // 减少偏移量来增加拖动难度，这里的缩减因子可以根据需要调整
    return offset / scrollFactor;
  }
}
