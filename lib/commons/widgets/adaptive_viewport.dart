import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 全局自适应视口。
///
/// 所有页面都是按 390x844 的竖屏手机设计稿、用 `.w/.h/.sp` 写的。原来在平板、折叠屏内屏、
/// 桌面窗口里 ScreenUtil 会按宽、高两个不同的比例拉伸（例如 1600x900 的窗口里 `.w` 放大 4 倍
/// 而 `.h` 只放大 1.07 倍），导致文字截断、溢出、变形。这里按 Material 3 的大屏规范统一处理：
///
/// * **竖屏手机**（宽 <= 480 且高宽比 1.7 ~ 2.6）：与原来完全一致，设计稿 390x844、铺满屏幕；
/// * **单栏**（平板竖屏、较窄的桌面窗口）：铺满整个窗口，宽高使用同一个缩放比例，
///   设计稿高度 >= 844、宽度 >= 390，页面按实际宽度自适应；
/// * **可分栏 / 平行视界**（折叠屏内屏、平板横屏、桌面宽窗口，且设置中开启了平行视界）：
///   平时首页铺满窗口；从首页的列表打开帖子等详情页时，首页收缩到左栏、详情页在右栏打开
///   （见 `PaneRoute`）。两栏的设计稿宽度都 >= 390、高度 >= 844，因此在手机上能正常显示的
///   布局，在任意一栏里也不会溢出。如果设备有铰链/折痕，两栏会沿着折痕分开。
///
/// 无论哪种布局，`.w/.h/.sp` 的缩放比例只取决于窗口，不随栏宽变化；
/// 与宽度相关的尺寸请用 `MediaQuery.sizeOf(context)`（每一栏内都是本栏的尺寸），
/// 不要再用 `1.sw` / `ScreenUtil().screenWidth` 这类整窗口的全局值。
@immutable
class ViewportSpec {
  const ViewportSpec._({
    required this.window,
    required this.designSize,
    required this.isPhone,
    this.leftPane,
    this.rightPane,
  });

  static const Size phoneDesignSize = Size(390, 844);

  /// 每一栏至少容纳的设计稿宽度（= 手机设计稿宽度）
  static const double minPaneDesignWidth = 390;

  /// 设计稿宽度达到这个值时开启双栏（会适当缩小比例保证两栏都 >= [minPaneDesignWidth]）
  static const double splitDesignWidth = 700;

  /// 左栏（首页）设计稿宽度的上限
  static const double maxLeftDesignWidth = 640;

  /// 非手机布局下的缩放范围：太小看不清，太大浪费空间
  static const double minScale = 0.75;
  static const double maxScale = 1.5;

  final Size window;

  /// 传给 ScreenUtil 的设计稿尺寸
  final Size designSize;

  /// 是否为原来的竖屏手机布局
  final bool isPhone;

  /// 分栏时左栏（首页）与右栏（详情页）在窗口中的位置
  final Rect? leftPane;
  final Rect? rightPane;

  /// 窗口是否足够宽、可以分栏（是否真的分栏还取决于有没有打开详情页）
  bool get isSplit => leftPane != null;

  /// `.w` 的缩放比例（非手机布局下宽高一致）
  double get scale => window.width / designSize.width;

  /// 竖屏手机：宽度 <= 480（大屏手机、折叠屏外屏约 344~430），高宽比 1.7 ~ 2.6。
  /// 手机都在 16:9（1.78）以上；更"矮胖"的屏幕（阔折叠外屏约 1.47 等）如果仍按 390x844
  /// 非等比拉伸，宽度方向放大而高度方向缩小，文字会撑破按 .h 计算的高度，所以改为等比缩放
  /// （最细长的折叠屏外屏约 2.56）。
  /// 超出这个范围的窗口（小平板、桌面窄窗口、极细长的窗口）按等比缩放处理，
  /// 否则宽高缩放比例相差过大，文字会被横向放大或纵向拉长。
  static bool isPhoneSize(Size screen) {
    final aspect = screen.height / screen.width;
    return screen.width <= 480 && aspect >= 1.7 && aspect <= 2.6;
  }

  static ViewportSpec resolve(Size window,
      [List<DisplayFeature> displayFeatures = const [],
      bool allowSplit = true]) {
    if (window.isEmpty || isPhoneSize(window)) {
      return ViewportSpec._(
          window: window, designSize: phoneDesignSize, isPhone: true);
    }
    final w = window.width, h = window.height;
    var s = (h / phoneDesignSize.height).clamp(minScale, maxScale).toDouble();
    // 宽度至少容纳一屏手机设计稿
    if (w / s < minPaneDesignWidth) s = w / minPaneDesignWidth;

    Rect? left, right;
    if (allowSplit && w / s >= splitDesignWidth) {
      // 两栏都至少 390 设计稿宽度
      s = math.min(s, w / (minPaneDesignWidth * 2));
      final minPane = minPaneDesignWidth * s;
      var leftWidth = ((w / s) * 0.42)
              .clamp(minPaneDesignWidth, maxLeftDesignWidth)
              .toDouble() *
          s;
      var rightStart = leftWidth;
      // 折叠屏铰链/折痕：沿折痕分栏，避免内容落在折痕上
      for (final f in displayFeatures) {
        final b = f.bounds;
        final vertical = b.height >= h * 0.9 && b.width < w * 0.1;
        final centered = b.center.dx > w * 0.3 && b.center.dx < w * 0.7;
        final isFold = f.type == DisplayFeatureType.fold ||
            f.type == DisplayFeatureType.hinge;
        if (isFold && vertical && centered &&
            b.left >= minPane &&
            w - b.right >= minPane) {
          leftWidth = b.left;
          rightStart = b.right;
          break;
        }
      }
      left = Rect.fromLTWH(0, 0, leftWidth, h);
      right = Rect.fromLTWH(rightStart, 0, w - rightStart, h);
    }
    return ViewportSpec._(
      window: window,
      designSize: Size(w / s, h / s),
      isPhone: false,
      leftPane: left,
      rightPane: right,
    );
  }

  /// 某一栏内使用的 MediaQuery：尺寸替换为栏的尺寸，另一侧的安全区由另一栏处理
  static MediaQueryData paneData(MediaQueryData data, Rect pane) {
    final w = data.size.width;
    EdgeInsets trim(EdgeInsets e) => e.copyWith(
          left: pane.left > 0 ? 0.0 : e.left,
          right: pane.right < w ? 0.0 : e.right,
        );
    return data.copyWith(
      size: pane.size,
      padding: trim(data.padding),
      viewPadding: trim(data.viewPadding),
      // 铰链等显示特征只对整窗口有意义
      displayFeatures: const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ViewportSpec &&
      other.window == window &&
      other.designSize == designSize &&
      other.leftPane == leftPane &&
      other.rightPane == rightPane;

  @override
  int get hashCode => Object.hash(window, designSize, leftPane, rightPane);

  @override
  String toString() => 'ViewportSpec(window: $window, design: $designSize, '
      'phone: $isPhone, left: $leftPane, right: $rightPane)';
}

/// 代替 `ScreenUtilInit`：
/// flutter_screenutil 5.9（目前最新正式版）的 ScreenUtilInit 只会按整个窗口、
/// 宽高两个独立比例缩放，这里改为自己计算设计稿尺寸后调用 [ScreenUtil.configure]。
class AdaptiveViewport extends StatefulWidget {
  const AdaptiveViewport({
    super.key,
    required this.child,
    this.allowSplit = true,
    this.forceAllowRotation = false,
  });

  final Widget child;

  /// 是否允许平行视界分栏（设置项）
  final bool allowSplit;

  /// 手机上也允许旋转（设置里的手动开关）；为 false 时按屏幕尺寸自动决定
  final bool forceAllowRotation;

  /// 当前视口布局。路由（`PaneRoute`）需要在 build 之外读取并监听它。
  static final ValueNotifier<ViewportSpec> spec = ValueNotifier(
      ViewportSpec.resolve(Size.zero));

  /// 最近一次按下的指针位置（全局坐标），用于判断操作来自左栏还是右栏
  static Offset? lastPointerDown;

  static ViewportSpec of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ViewportScope>()?.spec ??
      spec.value;

  @override
  State<AdaptiveViewport> createState() => _AdaptiveViewportState();
}

class _AdaptiveViewportState extends State<AdaptiveViewport> {
  ViewportSpec? _spec;
  bool? _portraitOnly;

  /// 手机尺寸的屏幕（最短边 < 600dp）保持竖屏；平板、折叠屏展开后允许旋转。
  /// 按物理屏幕而不是窗口判断，分屏/小窗不会改变结果；折叠屏开合时自动切换。
  /// 启动时由原生 MainActivity 按同样的规则先设置一次，这里负责之后的变化。
  void _updateOrientationLock() {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    final display = View.of(context).display;
    final portraitOnly = !widget.forceAllowRotation &&
        display.size.shortestSide / display.devicePixelRatio < 600;
    if (_portraitOnly == portraitOnly) return;
    _portraitOnly = portraitOnly;
    SystemChrome.setPreferredOrientations(
        portraitOnly ? const [DeviceOrientation.portraitUp] : const []);
  }

  static void _markNeedsBuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(_markNeedsBuild);
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final spec = ViewportSpec.resolve(
        data.size, data.displayFeatures, widget.allowSplit);

    ScreenUtil.configure(
      data: data,
      designSize: spec.designSize,
      minTextAdapt: true,
      // 与 ScreenUtilInit 的默认值一致（`.sp` 按宽度比例缩放；首次 configure 必须显式给出）
      splitScreenMode: false,
      fontSizeResolver: FontSizeResolvers.width,
    );

    _updateOrientationLock();

    if (_spec != spec) {
      // 只用了 .w/.h/.sp 的组件并不依赖 MediaQuery，尺寸变化时需要主动标记重建
      // （与 ScreenUtilInit 的做法相同）
      if (_spec != null) (context as Element).visitChildren(_markNeedsBuild);
      _spec = spec;
      AdaptiveViewport.spec.value = spec;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => AdaptiveViewport.lastPointerDown = e.position,
      child: _ViewportScope(spec: spec, child: widget.child),
    );
  }
}

class _ViewportScope extends InheritedWidget {
  const _ViewportScope({required this.spec, required super.child});

  final ViewportSpec spec;

  @override
  bool updateShouldNotify(_ViewportScope oldWidget) => spec != oldWidget.spec;
}

/// 按当前所在栏的尺寸计算的尺寸工具，用于替代整窗口的 `1.sw` / `1.sh`。
/// 手机上与原来的 `.sw/.sh` 完全相同；双栏时返回本栏的宽高。
extension PaneSizeContext on BuildContext {
  /// 本栏宽度 * [fraction]
  double sw([double fraction = 1]) => MediaQuery.sizeOf(this).width * fraction;

  /// 本栏高度 * [fraction]
  double sh([double fraction = 1]) => MediaQuery.sizeOf(this).height * fraction;
}

/// Material 3 窗口尺寸等级（按本栏的设计稿宽度划分，与 `.w` 的缩放无关）
enum WindowClass {
  /// < 600：手机布局（底部导航栏、单列）
  compact,

  /// 600 ~ 840：侧边导航栏、两列
  medium,

  /// >= 840：侧边导航栏、多列
  expanded,
}

extension WindowClassContext on BuildContext {
  /// 本栏宽度对应的设计稿宽度（手机上恒为 390）
  double get paneDesignWidth =>
      MediaQuery.sizeOf(this).width / ScreenUtil().scaleWidth;

  WindowClass get windowClass {
    final w = paneDesignWidth;
    if (w >= 840) return WindowClass.expanded;
    if (w >= 600) return WindowClass.medium;
    return WindowClass.compact;
  }
}
