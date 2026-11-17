import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 首页的外层列表与内层列表（自习室、考表）联动滚动：内层先带动外层滚到底，再滚动自身。
///
/// 未关联外层列表时（[linked] 为 false，例如内层列表独占一栏），内层列表直接自己滚动。
class ScrollSynchronizer {
  ScrollController controller1 = ScrollController();
  bool allowScrollingSecond = false;

  /// 是否关联了外层列表
  final bool linked;

  ScrollSynchronizer() : linked = false;

  ScrollSynchronizer._linked(this.controller1) : linked = true;

  factory ScrollSynchronizer.fromExist(ScrollController sc1) =>
      ScrollSynchronizer._linked(sc1);

  bool get firstAtBottom =>
      controller1.position.pixels == controller1.position.maxScrollExtent;

  bool secondAtTop(ScrollController sc) =>
      sc.position.pixels == sc.position.minScrollExtent;

  /// 内层列表收到 [dy] 的滚动（正值表示手指向下滑）：外层未到底时先滚外层，
  /// 回到内层顶部再向下滑时交还给外层。
  void scrollBy(ScrollController inner, double dy) {
    if (!controller1.hasClients) return;
    final outer = controller1.position;
    if (!firstAtBottom || !inner.hasClients || (secondAtTop(inner) && dy > 0)) {
      controller1.jumpTo((outer.pixels - dy).clamp(0.0, outer.maxScrollExtent));
    } else {
      final pos = inner.position;
      inner.jumpTo((pos.pixels - dy).clamp(0.0, pos.maxScrollExtent));
    }
  }
}

/// 联动滚动区域：触摸拖动和鼠标滚轮都按"先外层、后内层"的顺序滚动。
/// [builder] 拿到内层列表应使用的滚动物理（联动时由这里驱动，独立时为 null，自己滚动）。
class SynchronizedScrollArea extends StatelessWidget {
  const SynchronizedScrollArea({
    super.key,
    required this.inner,
    required this.builder,
  });

  final ScrollController inner;

  final Widget Function(BuildContext context, ScrollPhysics? physics) builder;

  @override
  Widget build(BuildContext context) {
    final sync = Provider.of<ScrollSynchronizer>(context, listen: false);
    if (!sync.linked) return builder(context, null);
    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        GestureBinding.instance.pointerSignalResolver.register(
          event,
          (e) => sync.scrollBy(inner, -(e as PointerScrollEvent).scrollDelta.dy),
        );
      },
      child: GestureDetector(
        onVerticalDragUpdate: (d) => sync.scrollBy(inner, d.primaryDelta!),
        child: builder(context, const NeverScrollableScrollPhysics()),
      ),
    );
  }
}
