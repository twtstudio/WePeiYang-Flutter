# Flutter 3.44.2 升级记录

## 环境版本

| 组件 | 旧版本 | 新版本 |
|------|--------|--------|
| Flutter | 3.19.6 | 3.44.2 |
| AGP | 7.4.0 | 8.11.1 |
| Gradle | 7.5 | 8.14 |
| Kotlin | 1.9.0 | 2.3.20 |

## 构建系统迁移

- `settings.gradle` → `settings.gradle.kts`（Kotlin DSL）
- `build.gradle` → `build.gradle.kts`
- `app/build.gradle` → `app/build.gradle.kts`
- `gradle.properties`：添加 `android.newDsl=false` + `android.builtInKotlin=false`（Flutter 官方临时方案）
- 添加阿里云 Maven 镜像（`maven.aliyun.com`）加速下载
- 移除 `android.defaults.buildfeatures.buildconfig=true`（AGP 9+ 已废弃）
- `compileSdk`/`targetSdk`/`ndkVersion` 改用 `flutter.compileSdkVersion` 等动态值

## 依赖升级

### Dart 包

| 包 | 旧版本 | 新版本 | API 迁移说明 |
|----|--------|--------|-------------|
| `image_cropper` | git/1.5.1 | pub 12.2.1 | `File?` → `CroppedFile?`；`androidUiSettings`/`iosUiSettings` → `uiSettings: [...]`；`cropStyle` 移入各平台 settings；`statusBarColor` → `statusBarLight` |
| `gallery_saver` | git | `gallery_saver_plus` 3.2.9 | import 路径改为 `gallery_saver_plus/gallery_saver.dart`，API 不变 |
| `qr_code_tools` | git | pub 0.2.0 | API 不变 |
| `webview_flutter` | 2.8.0 | 4.13.1 | `WebView()` → `WebViewController` + `WebViewWidget`；`JavascriptMode` → `JavaScriptMode`；`javascriptChannels` → `addJavaScriptChannel(name, onMessageReceived:)`；`loadUrl` → `loadRequest(Uri.parse())`；`JavascriptChannel` → `WebViewChannelConfig` 自定义封装 |
| `record` | 4.4.4 | 7.1.0 | `Record()` → `AudioRecorder()`；`start(path:, encoder:)` → `start(RecordConfig(encoder:), path:)`；`samplingRate` → `sampleRate`；`AudioEncoder.pcm16bit` → `AudioEncoder.pcm16bits` |
| `share_plus` | 8.0.2 | 12.0.2 | `Share.shareXFiles()` → `SharePlus.instance.share(ShareParams(files:))` |
| `package_info_plus` | 6.0.0 | 8.3.1 | API 不变（`PackageInfo.fromPlatform()`） |
| `shared_preferences` | 2.2.2 | 2.5.5 | `SharedPreferences.getInstance()` → `SharedPreferencesWithCache.create(cacheOptions:)`；同步 getter 不变；`SharedPreferencesAsync` 用于无缓存场景 |
| `fluttertoast` | 8.2.8 | 9.1.0 | `positionedToastBuilder: (context, child)` → `(context, child, gravity)`，第三个参数为新加 |
| `connectivity_plus` | 5.0.2 | 7.1.1 | `ConnectivityResult?` → `List<ConnectivityResult>`；`checkConnectivity()` 返回 `List` |
| `image_picker` | 1.0.7 | 1.2.2 | API 不变 |
| `path_provider` | 2.1.4 | 2.1.5 | API 不变 |
| `url_launcher` | 6.2.5 | 6.3.2 | API 不变 |
| `permission_handler` | 11.3.0 | 12.0.3 | API 不变 |
| `sqflite` | 2.3.3+1 | 2.4.3 | API 不变 |
| `video_player` | 2.9.2 | 2.11.1 | API 不变 |
| `flutter_image_compress` | 2.3.0 | 2.4.0 | API 不变 |
| `screenshot` | 2.1.0 | 3.0.0 | API 不变 |
| `simple_html_css` | 4.0.0 | 5.0.0 | 移除内置 unescape，需调用前自行处理（项目数据来自 API，不受影响） |
| `wechat_assets_picker` | 9.2.2 | 10.1.2 | API 不变 |
| `wechat_picker_library` | 1.0.5 | 1.0.7 | API 不变 |
| `photo_manager` | 3.6.4 (override) | 3.9.0 | 移除 `dependency_overrides`，API 不变 |
| `flutter_plugin_android_lifecycle` | 2.0.19 | 2.0.28 | 间接依赖升级，修复 v1 embedding 编译错误 |

### Android 原生依赖

| 依赖 | 操作 | 说明 |
|------|------|------|
| `com.huawei.agconnect:agcp` | 1.6.0.300 → 1.9.1.301 | 兼容 AGP 8.x |
| `io.github.lucksiege:pictureselector:v2.7.2` | 移除 | 历史遗留，已由 `wechat_assets_picker` 替代 |

## 移除的依赖

- `miui_long_screenshot: ^0.1.0` — 功能和该插件均已废弃

## KGP 警告（已知，等待上游修复）

以下插件仍使用旧版 Kotlin Gradle Plugin，`android.builtInKotlin=false` 保证当前正常编译：

| 插件 | GitHub Issue | 状态 |
|------|-------------|------|
| `package_info_plus` | [plus_plugins#3871](https://github.com/fluttercommunity/plus_plugins/issues/3871) | 开放 |
| `share_plus` | [plus_plugins#3870](https://github.com/fluttercommunity/plus_plugins/issues/3870) | 开放 |
| `photo_manager` | [#1403](https://github.com/fluttercandies/flutter_photo_manager/issues/1403) | 开发中 |
| `flutter_image_compress` | [#362](https://github.com/fluttercandies/flutter_image_compress/issues/362) | 开放 |
| `fluttertoast` | 仓库 404 | 维护停滞 |
| `gallery_saver_plus` | 未找到 | - |
| `qr_code_tools` | 未找到 | - |

## 其他修复

- `PushBroadCastReceiver.kt`: PendingIntent 添加 `FLAG_IMMUTABLE`（Android 12+ lint 要求）
- App level deps: 移除 `pictureselector` 原生库（与 `image_cropper` 的 UCrop 冲突）
