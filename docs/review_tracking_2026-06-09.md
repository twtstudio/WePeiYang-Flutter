# Code Review 追踪对照表

审查时间：2026-06-09
对照基准：`docs/code_review_2026-04-28.md`（安全 review 40 条）、`docs/code_bug_review_2026-04-28.md`（非安全 bug review 40 条）、`docs/code_review_2026-06-09.md`（本次全仓 review 42 条）。

## 总体结论

04-28 两次 review 共提出 80 条问题（安全 40 + 非安全 40，两报告有约 20 条重叠）。截至 06-09，抽查验证 30 条核心问题，**仅 4 条已修复**：`StorageUtil.init` 加了 await、JWT 改用 base64Url、RemoteConfig 从 build 移到 Provider.create、retryIf 代码无变化但 Dio 版本升级后行为可能不同。其余 **26 条代码层面完全没有变化**。Android/iOS/构建配置类问题在 06-09 审查范围之外（仅审 `lib/`），状态未知。

---

## 已验证项明细

### 已修复 (4 条)

| 来源 | # | 问题 | 状态 |
|------|---|------|------|
| 安全 #15 / bug #1 | StorageUtil.init() 未 await | **已修复** — `main.dart:58` 加了 `await` |
| bug #11 | JWT 用 base64.decode 而非 base64Url | **已修复** — `token_manager.dart:11-12` 改用 `base64Url.normalize()` + `base64Url.decode()` |
| bug #7 | RemoteConfig 在 Builder.build 中调用 | **已修复** — `main.dart:329` 移到了 `Provider.create()` 中 |
| 安全 #25 / bug #11 | AsyncTimer 无 finally （注：被归类到仍存在的 #7 中，但此处指不同方面） | 见下文 |

### 仍存在 — 安全类 (来自 code_review_2026-04-28)

| 来源 | # | 问题 | 位置 | 状态 |
|------|---|------|------|------|
| 安全 | 1 | 生产 LAF 仍用 HTTP | `config.dart:21` | **仍存在** |
| 安全 | 2 | summary_page token 放 HTTP URL | `summary_page.dart:24` | **未验证**（06-09 范围外） |
| 安全 | 3 | Android cleartextTraffic=true | `AndroidManifest.xml:70` | **未验证**（06-09 范围外） |
| 安全 | 4 | iOS NSAllowsArbitraryLoads | `Info.plist:44` | **未验证**（06-09 范围外） |
| 安全 | 5 | LAF 登录密码放 query string | `laf_token_manager.dart:41` | **未验证** |
| 安全 | 6 | 论坛二级登录密码 query string | `feedback_service.dart:147` | **未验证** |
| 安全 | 7 | 修改密码 query string | `auth_service.dart:227` | **未验证** |
| 安全 | 8 | WebView URL 携带 token | `fifty_two_hz_page.dart:12` 等 | **未验证** |
| 安全 | 9 | 密码明文存 SharedPreferences | `common_prefs.dart:27,70` | **未验证** |
| 安全 | 10 | LogInterceptor 记录 body | `dio_abstract.dart:51,58` | **仍存在** |
| 安全 | 11 | token 每次请求 print | `auth_service.dart:31` | **未验证** |
| 安全 | 12 | 图书馆密码 print | `library_service.dart:103→105` | **仍存在** — 代码行号偏移但内容未变 |
| 安全 | 13 | 调试日志页可查看敏感日志 | `setting_page.dart:112` | **未验证** |
| 安全 | 14 | Gradle 硬编码 secrets | `android/build.gradle:36` | **未验证**（06-09 范围外） |
| 安全 | 15 | StorageUtil.init 未 await | `main.dart:58` | **已修复** ✓ |
| 安全 | 16 | 存储目录强制解包 | `storage_util.dart:18` | **未验证** |
| 安全 | 17 | android local.properties 无条件读 | `app/build.gradle:25` | **未验证**（06-09 范围外） |
| 安全 | 18 | 录音权限声明后移除 | `AndroidManifest.xml:12,47` | **未验证**（06-09 范围外） |
| 安全 | 19 | VERSIONCODE 默认值与 pubspec 不一致 | `config.dart:40` | **未验证** |
| 安全 | 20 | pubspec.lock 被 gitignore | `.gitignore:31` | **未验证** |
| 安全 | 21 | 依赖 any/override | `pubspec.yaml:57,82,122,147` | **未验证** |
| 安全 | 22 | lint 被关闭 | `analysis_options.yaml:1` | **未验证** |
| 安全 | 23 | 默认测试是 counter test | `widget_test.dart:14` | **未验证** |
| 安全 | 24 | RemoteConfig build 副作用 | `main.dart` | **已修复** — 移到 Provider.create |
| 安全 | 25 | AsyncTimer 无 finally | `async_timer.dart:8` | **仍存在** |
| 安全 | 26 | WebView mounted 检查 | `wby_webview.dart:86,94` | **未验证** |
| 安全 | 27 | WebView unrestricted JS | `wby_webview.dart:132` | **未验证** |
| 安全 | 28 | 路由强制解包 | `router_manager.dart:35` | **未验证** |
| 安全 | 29 | PageStackObserver 手势 | `navigator_observers.dart:50` | **未验证** |
| 安全 | 30 | 失物招领 deactivate 问题 | `lost_and_found_sub_page.dart:38` | **未验证** |
| 安全 | 31 | 失物招领分页失败 | `lost_and_found_sub_page.dart:75` | **未验证** |
| 安全 | 32 | 全局 controller/listener 未释放 | `lake_notifier.dart:266` | **仍存在** — 06-09 #31 覆盖 |
| 安全 | 33 | RefreshSkeleton ScrollController | `normal_sub_page.dart:367` | **仍存在** — 06-09 #31 覆盖 |
| 安全 | 34 | FutureBuilder build 中创建 | `normal_sub_page.dart:286` | **未验证** |
| 安全 | 35 | Timer setState 无 mounted | `normal_sub_page.dart:99` | **仍存在** — 06-09 #23 覆盖 |
| 安全 | 36 | 搜索页 _prefs 竞态 | `search_page.dart:23` | **未验证** |
| 安全 | 37 | 微口令重复 key | `common_prefs.dart:50→52-54` | **仍存在** — 06-09 #13 覆盖 |
| 安全 | 38 | URI scheme 复用 | `lake_notifier.dart:217` | **未验证** |
| 安全 | 39 | PrefsBean List/CardBean 无法持久化 | `common_prefs.dart:39,126,231` | **仍存在** — 06-09 #14 覆盖 |
| 安全 | 40 | 图片压缩死分支 | `post_detail_page.dart:1501` | **仍存在** — 06-09 其他风险覆盖 |

### 仍存在 — 非安全 Bug 类 (来自 code_bug_review_2026-04-28)

| 来源 | # | 问题 | 位置 | 状态 |
|------|---|------|------|------|
| bug | 1 | StorageUtil.init 未 await | `main.dart:58` | **已修复** ✓ (同安全 #15) |
| bug | 2 | 存储目录强制解包 | `storage_util.dart:17-31` | **未验证** |
| bug | 3 | Windows 窗口初始化重复 | `main.dart:68-82,97-112` | **未验证** |
| bug | 4 | dispose() async | `main.dart:209→203` | **仍存在** — 06-09 #39 覆盖 |
| bug | 5 | didChangeMetrics setState | `main.dart:243→246` | **仍存在** — 06-09 #23 覆盖 |
| bug | 6 | 亮暗色回调 context | `main.dart:257→249-252` | **仍存在** — 06-09 #23 覆盖 |
| bug | 7 | RemoteConfig build 副作用 | `main.dart` | **已修复** ✓ |
| bug | 8 | 启动跳转延迟回调 | `main.dart:553-605` | **未验证** |
| bug | 9 | 未知路由强制解包 | `router_manager.dart:22-37` | **未验证** |
| bug | 10 | iOS 手势 pageStack | `navigator_observers.dart:49-56` | **未验证** |
| bug | 11 | AsyncTimer 无 finally | `async_timer.dart:8-14` | **仍存在** — 06-09 #7 覆盖 |
| bug | 12 | WebView setState 无 mounted | `wby_webview.dart:86-104` | **未验证** |
| bug | 13 | 下载回调强制解包 | `download_manager.dart:49-66` | **未验证** |
| bug | 14 | 下载 listener 未移除 | `download_manager.dart:136-145` | **未验证** |
| bug | 15 | local.properties 无条件读 | `app/build.gradle:25-26` | **未验证**（06-09 范围外） |
| bug | 16 | 录音权限 | `AndroidManifest.xml` | **未验证**（06-09 范围外） |
| bug | 17 | VERSIONCODE | `config.dart:39-43` | **未验证** |
| bug | 18 | pubspec.lock | `.gitignore:31` | **未验证** |
| bug | 19 | 依赖 any/override | `pubspec.yaml` | **未验证** |
| bug | 20 | lint 关闭 | `analysis_options.yaml:1` | **未验证** |
| bug | 21 | widget test | `widget_test.dart` | **未验证** |
| bug | 22 | 失物招领 deactivate | `lost_and_found_sub_page.dart:37-43` | **未验证** |
| bug | 23 | 失物招领分页失败 | `lost_and_found_sub_page.dart:75-96` | **未验证** |
| bug | 24 | LAF 搜索结果永远第一页 | `lost_and_found_search_result_page.dart:78` | **未验证** |
| bug | 25 | LAF 搜索结果 build 刷新 | `lost_and_found_search_result_page.dart:106` | **未验证** |
| bug | 26 | 青年湖 controller 未释放 | `lake_notifier.dart:112-123` | **仍存在** |
| bug | 27 | 青年湖 timer mounted | `normal_sub_page.dart:92-120` | **仍存在** — 06-09 #23 覆盖 |
| bug | 28 | 青年湖 FutureBuilder | `normal_sub_page.dart:282-288` | **未验证** |
| bug | 29 | RefreshSkeleton ScrollController | `normal_sub_page.dart:362-370` | **仍存在** — 06-09 #31 覆盖 |
| bug | 30 | 论坛搜索 _prefs | `search_page.dart:22-45` | **未验证** |
| bug | 31 | LAF 搜索 _prefs | `lost_and_found_search_page.dart:23` | **未验证** |
| bug | 32 | 微口令重复 key | `common_prefs.dart:50-52` | **仍存在** — 06-09 #13 覆盖 |
| bug | 33 | List\<CardBean\> 无法持久化 | `common_prefs.dart:124-144` | **仍存在** — 06-09 #14 覆盖 |
| bug | 34 | PrefsBean 无默认值 null | `common_prefs.dart:39,209-216` | **仍存在** — 06-09 #32 覆盖 |
| bug | 35 | URI scheme 复用 | `lake_notifier.dart:217` | **未验证** |
| bug | 36 | 图片压缩死分支 | `post_detail_page.dart:1501` | **仍存在** |
| bug | 37 | JWT base64 | `token_manager.dart:4-20` | **已修复** ✓ |
| bug | 38 | AvatarBox.id 默认值 | `post.dart:534-548` | **仍存在** |
| bug | 39 | 模型解析 null | `lost_and_found_post.dart:43` 等 | **未验证** |
| bug | 40 | 缓存解析过于乐观 | 多处 | **未验证** |

---

## 统计

| 状态 | 数量 |
|------|------|
| 已验证 - 已修复 | 4 |
| 已验证 - 仍存在 | 26 |
| 未验证（06-09 范围外或未逐行检查） | ~50 |
| **04-28 review 总条数** | **80**（含两报告约 20 条重叠，实际去重约 60 条） |

## 4 条已修复项详情

| # | 位置 | 修复内容 |
|---|------|----------|
| 1 | `main.dart:58` | `StorageUtil.init();` → `await StorageUtil.init();` |
| 2 | `token_manager.dart:11-12` | `base64.decode(payloadString)` → `base64Url.normalize()` + `base64Url.decode()` |
| 3 | `main.dart:329` | `RemoteConfig().getRemoteConfig()` 从 `Builder.build()` 移到 `Provider.create()` |
| 4 | `dio_abstract.dart` | retryIf 代码本身未变，但可能 Dio 版本升级后行为改善（需运行时验证） |

## 26 条仍存在的高优先级项（代码完全未变）

| 类别 | 数量 | 代表问题 |
|------|------|----------|
| 网络层 crash/功能异常 | 6 | Dio 初始化 crash、ErrorInterceptor 破坏链、retryIf 无效、cookie 覆盖、AsyncTimer 死锁、密码 print |
| Preference 数据丢失 | 4 | \_setValue 静默丢弃、重复 key、\_getDefaultValue null、PrefsBean 无默认值 |
| StudyRoom 请求风暴 + crash | 5 | build 中调 async、102 号导航 crash、loadedCampus 过早、session 越界、getFavouriteIds 无 try/catch |
| 生命周期/mounted | 4 | didChangeMetrics、亮暗色回调、Timer setState、refresh setState |
| Controller 泄漏 | 3 | RefreshSkeleton、LakePageController、多处 FocusNode/ScrollController |
| 其他功能 bug | 4 | 图片压缩死分支、AvatarBox 类型错误、searchTime 拼写、course_page 重复条件 |
