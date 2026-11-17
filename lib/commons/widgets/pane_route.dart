import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../themes/template/wpy_theme_data.dart';
import '../themes/wpy_theme.dart';
import 'adaptive_viewport.dart';

/// 平行视界（列表-详情分栏）路由。
///
/// 窗口足够宽且开启了平行视界时（见 [ViewportSpec.isSplit]）：
/// * 平时首页（锚点路由）铺满窗口；
/// * 从首页打开的页面（帖子、课表、入校码、自习室、设置……）在右栏打开，
///   首页收缩到左栏，保持可见、可操作；
/// * 在右栏页面里继续打开的页面仍在右栏内叠加，逐级返回；
/// * 在左栏再打开一个页面，会替换掉右栏原有的页面；
/// * [PaneNavigatorObserver.fullScreenRouteNames] 中的页面照常全屏打开。
///
/// 手机、窄窗口或关闭平行视界时与 [MaterialPageRoute] 行为完全一致。
/// 窗口尺寸变化时会在两种模式间无缝切换，页面状态不会丢失。
class PaneRoute<T> extends MaterialPageRoute<T> {
  PaneRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  bool _isDetail = false;

  bool get isAnchor => PaneNavigatorObserver.isAnchor(this);

  /// 是否为在右栏打开的详情页
  bool get isDetail => _isDetail;

  bool get _split => AdaptiveViewport.spec.value.isSplit;

  @override
  void install() {
    _isDetail = PaneNavigatorObserver.instance._opensInDetailPane(this);
    AdaptiveViewport.spec.addListener(_handleLayoutChanged);
    super.install();
  }

  @override
  void dispose() {
    AdaptiveViewport.spec.removeListener(_handleLayoutChanged);
    super.dispose();
  }

  void _handleLayoutChanged() {
    if (overlayEntries.isEmpty) return;
    // 分栏时详情页不能是 opaque，否则下面的首页不会被绘制
    if (animation?.isCompleted ?? false) overlayEntries.first.opaque = opaque;
    changedInternalState();
  }

  @override
  bool get opaque => !(_isDetail && _split);

  /// 默认的 ModalBarrier 覆盖整个窗口，会挡住左栏的点击
  @override
  Widget buildModalBarrier() => _isDetail && _split
      ? const SizedBox.shrink()
      : super.buildModalBarrier();

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final spec = AdaptiveViewport.of(context);
    if (!spec.isSplit || !(isAnchor || _isDetail)) {
      return _PaneFrame(
        rect: null,
        child: super.buildTransitions(
            context, animation, secondaryAnimation, child),
      );
    }
    if (_isDetail) {
      return _PaneFrame(
        rect: spec.rightPane,
        // 被右栏更上层的页面完全盖住时不再绘制（保留状态）
        covered: secondaryAnimation.isCompleted,
        // 右栏不用默认的缩放转场：它会在整栏先铺一层背景色，看起来像闪一下灰
        child: _PaneDetailTransition(animation: animation, child: child),
      );
    }
    // 首页：有详情页时收缩到左栏，不做退场动画
    return ValueListenableBuilder<bool>(
      valueListenable: PaneNavigatorObserver.instance.hasDetail,
      builder: (context, hasDetail, child) => _PaneFrame(
        rect: hasDetail ? spec.leftPane : null,
        animate: true,
        divider: hasDetail,
        child: child!,
      ),
      child: super.buildTransitions(
          context, animation, kAlwaysDismissedAnimation, child),
    );
  }
}

/// 右栏页面的转场：从右侧轻微滑入并淡入
class _PaneDetailTransition extends StatelessWidget {
  const _PaneDetailTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0.06, 0), end: Offset.zero)
            .animate(curved),
        child: child,
      ),
    );
  }
}

/// 保持固定的组件树结构（Stack → Positioned → MediaQuery → ClipRect → Offstage），
/// 切换全屏/分栏时页面只改变位置和尺寸，不会被重建。
class _PaneFrame extends StatelessWidget {
  const _PaneFrame({
    required this.rect,
    required this.child,
    this.covered = false,
    this.animate = false,
    this.divider = false,
  });

  /// 页面所在的栏，null 表示铺满窗口
  final Rect? rect;
  final bool covered;
  final bool animate;
  final bool divider;
  final Widget child;

  static const _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final pane = rect ?? Offset.zero & data.size;
    final page = MediaQuery(
      data: rect == null ? data : ViewportSpec.paneData(data, pane),
      child: ClipRect(
        clipBehavior: rect == null ? Clip.none : Clip.hardEdge,
        child: Offstage(offstage: covered, child: child),
      ),
    );
    return Stack(
      children: [
        AnimatedPositioned.fromRect(
          key: const ValueKey('page'),
          rect: pane,
          duration: animate ? _duration : Duration.zero,
          curve: Curves.easeOutCubic,
          child: page,
        ),
        if (divider)
          Positioned(
            key: const ValueKey('divider'),
            left: pane.right - 0.5,
            width: 0.5,
            top: 0,
            bottom: 0,
            child: ColoredBox(
                color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor)),
          ),
      ],
    );
  }
}

/// 记录路由栈：判断页面是否在右栏打开，以及当前是否有详情页（首页据此收缩到左栏）。
class PaneNavigatorObserver extends NavigatorObserver {
  PaneNavigatorObserver._();

  static final instance = PaneNavigatorObserver._();

  /// 锚点路由名（首页），由 RouterManager 设置
  static String? anchorRouteName;

  /// 即使从首页打开也全屏显示的页面（例外），由 RouterManager 设置
  static Set<String> fullScreenRouteNames = const {};

  static bool isAnchor(Route route) =>
      anchorRouteName != null && route.settings.name == anchorRouteName;

  final List<Route<dynamic>> _stack = [];

  /// 路由栈中是否有右栏的详情页
  final ValueNotifier<bool> hasDetail = ValueNotifier(false);

  /// 是否在右栏打开：从首页打开的页面，以及在右栏页面里继续打开的页面
  /// （[fullScreenRouteNames] 除外）。
  bool _opensInDetailPane(Route route) {
    if (_stack.isEmpty || isAnchor(route)) return false;
    if (fullScreenRouteNames.contains(route.settings.name)) return false;
    final below = _stack.last;
    return isAnchor(below) || (below is PaneRoute && below.isDetail);
  }

  /// 最近一次操作是否发生在左栏（首页）
  bool get _fromLeftPane {
    final spec = AdaptiveViewport.spec.value;
    final pointer = AdaptiveViewport.lastPointerDown;
    return spec.isSplit && pointer != null && spec.leftPane!.contains(pointer);
  }

  void _update() =>
      hasDetail.value = _stack.any((r) => r is PaneRoute && r.isDetail);

  @override
  void didPush(Route route, Route? previousRoute) {
    _stack.add(route);
    _update();
    _replaceDetailsIfFromLeftPane(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _stack.remove(route);
    _update();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _stack.remove(route);
    _update();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final i = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (newRoute != null) {
      if (i >= 0) {
        _stack[i] = newRoute;
      } else {
        _stack.add(newRoute);
      }
    }
    _update();
  }

  /// 在左栏打开详情页时，替换掉右栏原有的页面
  void _replaceDetailsIfFromLeftPane(Route route) {
    if (route is! PaneRoute || !route.isDetail || !_fromLeftPane) return;
    final stale = _stack
        .whereType<PaneRoute>()
        .where((r) => r != route && r.isDetail)
        .toList();
    if (stale.isEmpty) return;
    // 不能在 Navigator 推入路由的过程中修改路由栈
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final nav = route.navigator;
      if (nav == null) return;
      for (final r in stale) {
        if (r.isActive) nav.removeRoute(r);
      }
    });
  }
}
