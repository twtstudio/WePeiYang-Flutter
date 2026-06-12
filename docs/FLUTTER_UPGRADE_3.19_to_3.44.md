# Flutter 3.19 → 3.44 升级摘要

> 生成日期：2026-06-12 | 当前版本：Flutter 3.44.2 / Dart 3.12.2

## Dart 语言版本对应

| Flutter | Dart |
|---|---|
| 3.19   | 3.3  |
| 3.22   | 3.4  |
| 3.24   | 3.5  |
| 3.27   | 3.6  |
| 3.29   | 3.7  |
| 3.32   | 3.8  |
| 3.35   | 3.9  |
| 3.38   | 3.10 |
| 3.41   | 3.11 |
| 3.44   | 3.12 |

---

## Flutter 3.22（2024.05）

| 类别 | 变化 |
|---|---|
| Breaking | `MaterialState` → `WidgetState` 全局重命名 |
| Breaking | 新增 `ColorScheme` 色值（`surfaceDim`, `surfaceBright` 等） |
| Breaking | 废弃 Android KitKat（API 19），最低 API 21 |
| Breaking | `PageView.controller` 改为可空 |
| Breaking | `MemoryAllocations` → `FlutterMemoryAllocations` |
| Web | dart2wasm 编译稳定，WebAssembly 正式可用 |
| 引擎 | Impeller 在 iOS 默认启用 |

## Flutter 3.24（2024.08）

| 类别 | 变化 |
|---|---|
| Breaking | `Navigator` page API 破坏性变更（`onPopInvokedWithResult` 取代 `onPopInvoked`） |
| Breaking | `PopScope` 支持泛型返回结果 |
| Breaking | `ButtonBar` 废弃 → 用 `OverflowBar` |
| Android | 新增 Android Surface 插件 API |
| 引擎 | Impeller 渲染性能大幅提升 |
| iOS | macOS 隐私清单（Privacy Manifest）合规 |

## Flutter 3.27（2024.12）

| 类别 | 变化 |
|---|---|
| Breaking | `Color` 广色域 (Display P3) 支持 |
| Breaking | 组件主题规范化（Component theme normalization）开始 |
| Breaking | Material 3 Token 更新 |
| Breaking | `InputDecoration.collapsed` 移除无效参数 |
| Breaking | 默认 `SystemUiMode` → Edge-to-Edge（全屏） |
| ARM | iOS/Android ARM 设备 Impeller 默认 |

## Flutter 3.29（2025.02）

| 类别 | 变化 |
|---|---|
| Breaking | **v1 Android embedding 彻底移除** |
| Breaking | `ThemeData.dialogBackgroundColor` → `DialogThemeData.backgroundColor` |
| Breaking | Material 3 `Slider` 重设计 |
| Breaking | Material 3 `CircularProgressIndicator`/`LinearProgressIndicator` 更新 |
| Breaking | `ImageFilter.blur` 默认 tileMode 自动选择 |
| iOS | 修复大量 Impeller GLES 驱动兼容性问题 |

## Flutter 3.32（2025.05）

| 类别 | 变化 |
|---|---|
| Breaking | `.flutter-plugins` → `.flutter-plugins-dependencies` |
| Breaking | `ExpansionTileController` → `ExpansibleController` |
| Breaking | Material Theme System 重大更新 |
| Breaking | 本地化生成为源码而非合成 package |
| Breaking | 弹簧动画欠阻尼公式修正 |
| Breaking | `RouteTransitionRecord.markForRemove` → `markForComplete` |
| 引擎 | Impeller Vulkan 后端持续修复 |

## Flutter 3.35（2025.08）

| 类别 | 变化 |
|---|---|
| Breaking | **Radio 组件全新 API 重设计** |
| Breaking | `Form` 不再支持作为 sliver |
| Breaking | Android 默认 `abiFilters`（`arm64-v8a`, `x86_64`） |
| Breaking | macOS/Windows merged threads 默认 |
| Breaking | `Visibility` maintainState 时不再默认 focusable |
| Feature | **Widget Preview**（实验性）首次加入 |
| Feature | `AppFlavor` 运行时获取支持 |
| Android | AGP 9 初步支持 |

## Flutter 3.38（2025.11）

| 类别 | 变化 |
|---|---|
| Breaking | **UISceneDelegate 采用**（iOS 26 必需） |
| Breaking | `CupertinoDynamicColor` 广色域支持 |
| Breaking | SnackBar 含 action 时不再自动消失 |
| Breaking | Android 默认页面过渡 → `PredictiveBackPageTransitionBuilder` |
| Breaking | `SemanticsProperties.focusable` → `isFocusable` |
| Breaking | `OverlayPortal.targetsRootOverlay` 废弃 |
| iOS | Xcode 26 兼容，iOS 26 支持 |
| Web | SkWasm 渲染器稳定 |

## Flutter 3.41（2026.02）

| 类别 | 变化 |
|---|---|
| Feature | **公开 Release 窗口**（2/5/8/11 月季度发布） |
| Feature | **Material/Cupertino SDK 解耦启动**（独立升级，不绑定 SDK） |
| Feature | **Swift Package Manager 全面支持** + UIScene 默认 |
| Feature | **平台特定 assets**（`pubspec.yaml` 中 `platforms:` 字段） |
| Feature | **Content-sized Flutter views**（Add-to-App 自适应尺寸） |
| Feature | `Navigator.popUntilWithResult` |
| Feature | `RepeatingAnimationBuilder` 声明式连续动画 |
| Feature | Fragment Shader 增强：同步图片解码 + 128bit float 纹理 |
| Feature | **实验性 Multi-Window API**（Canonical 贡献） |
| Feature | Linux merged threads 默认 |
| Breaking | `containsSemantics` → `isSemantics` |
| Breaking | `findChildIndexCallback` → `findItemIndexCallback` |
| Breaking | `FontWeight` 同时控制可变字体 weight 属性 |
| 引擎 | DevTools 编译为 dart2wasm，性能提升 |

## Flutter 3.44（2026.06，最新）

| 类别 | 变化 |
|---|---|
| Feature | **Flutter 可作为 Swift Package 依赖引入** |
| Feature | **CupertinoSheet 可拖拽滚动** |
| Feature | **Hero 支持自定义动画曲线** |
| Feature | **Win32 Tooltip 独立窗口** |
| Feature | `ExpansibleController.toggle()` 方法 |
| Feature | `AnimatedCrossFade.onEnd` 回调 |
| Feature | `CupertinoSheetRoute` 支持 `RouteSettings` |
| Feature | Android display corner radii 支持 |
| Feature | iOS 动效无障碍（reduce motion） |
| Breaking | `IconData` class 标记为 `final` |
| Breaking | **Android 项目迁移到内建 Kotlin**（不再需要手动 plugin apply） |
| Breaking | Page transition builders 重组 |
| Breaking | `onReorder` 回调废弃（用 `onReorderStart`/`onReorderEnd`） |
| Breaking | `TextInputConnection.setStyle` 废弃 |
| Breaking | `cacheExtent`/`cacheExtentStyle` 废弃 |
| Breaking | `RawMenuAnchor` 关闭顺序变更 |
| Breaking | ListTile 被 colored widget 包裹且在 debug 模式时报错 |

---

## 对本项目的关键影响

| 项目 | 检查项 |
|---|---|
| `pubspec.yaml` | 检查是否可用 `platforms:` 按平台过滤 assets 减小包体积 |
| Android 工程 | Kotlin 内建迁移（`settings.gradle` 去掉手动 `apply plugin`） |
| iOS 工程 | SPM 迁移 + UIScene 适配 |
| 全局替换 | `MaterialState` → `WidgetState` |
| 组件替换 | `ExpansionTileController` → `ExpansibleController` |
| 组件替换 | `ButtonBar` → `OverflowBar` |
| API 替换 | `containsSemantics` → `isSemantics` |
| 废弃 API | `onReorder` / `TextInputConnection.setStyle` / `cacheExtent` |
| 导航 | `PopScope` 改用 `onPopInvokedWithResult` |
