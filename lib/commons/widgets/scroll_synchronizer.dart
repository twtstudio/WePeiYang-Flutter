import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollSynchronizer {
  ScrollController controller1 = ScrollController();
  bool allowScrollingSecond = false;

  ScrollSynchronizer();

  factory ScrollSynchronizer.fromExist(ScrollController sc1) {
    ScrollSynchronizer sc = ScrollSynchronizer();
    sc.controller1 = sc1;
    return sc;
  }

  bool get firstAtBottom =>
      controller1.position.pixels == controller1.position.maxScrollExtent;

  bool secondAtTop(sc) => sc.position.pixels == sc.position.minScrollExtent;
}
