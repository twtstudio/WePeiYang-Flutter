# WePeiYang-Flutter 全仓代码审查报告

审查时间：2026-04-28  
审查范围：`lib/`、`android/`、`ios/`、`pubspec.yaml`、`analysis_options.yaml`、`.gitignore`、现有测试。  
验证命令：

- `fvm flutter analyze --no-pub`：失败，51 个 analyzer issue。
- `fvm flutter test --no-pub`：失败，现有 widget test 仍是默认 counter 测试，并触发 `sharedPref` / `downloadDir` 未初始化异常。

## 总体结论

仓库的主要风险不在单个 UI 细节，而在几个横向基础设施问题：账号/令牌传输与日志暴露、启动初始化竞态、依赖不可复现、测试体系失效、以及多个全局单例/静态状态缺少生命周期管理。下面列出 40 个具体问题，按严重度优先排序。

## 问题清单

### 1. 生产环境失物招领接口仍使用 HTTP

- 位置：`lib/commons/environment/config.dart:21`
- 问题：`EnvConfig.LAF` 的开发和生产值都指向 `http://110.41.178.7:8080/`。
- 风险：登录、发帖、联系方式获取等失物招领流量都可能被中间人读取或篡改。
- 建议：生产必须切到 HTTPS；如果服务端暂不支持，至少把该功能标为不可进入生产发布的阻断项。

### 2. 年度总结把 token 放进明文 HTTP URL

- 位置：`lib/home/view/web_views/summary_page.dart:24`, `lib/home/view/web_views/summary_page.dart:31`
- 问题：页面使用 `http://summary.twtstudio.com/`，并把 token 拼到 query string。
- 风险：token 会出现在明文网络、WebView 历史、代理日志和服务器 access log 中。
- 建议：改为 HTTPS；避免 URL query 传 token，改用短期一次性 code、POST handoff 或 WebView header/cookie。

### 3. Android 全局允许明文流量

- 位置：`android/app/src/main/AndroidManifest.xml:70`
- 问题：`android:usesCleartextTraffic="true"` 对整个应用生效。
- 风险：即使某些接口已经 HTTPS，后续新增 HTTP URL 也会静默进入生产。
- 建议：移除全局开关；如必须兼容历史域名，使用 network security config 做域名级白名单，并加到 release 检查。

### 4. iOS 全局关闭 ATS 保护

- 位置：`ios/Runner/Info.plist:44`
- 问题：`NSAllowsArbitraryLoads` 设置为 `true`。
- 风险：iOS 端同样允许任意明文请求，安全边界过宽。
- 建议：改为按域名配置 ATS exception，并逐步清理 HTTP 依赖。

### 5. 失物招领登录把账号密码放在 query string

- 位置：`lib/lost_and_found/network/lost_and_found_service.dart:72`, `lib/commons/token/laf_token_manager.dart:41`
- 问题：登录和刷新 token 都通过 GET query 传 `account` / `password`。
- 风险：凭证会进入 URL、日志、代理、缓存；结合 HTTP 生产域名风险更高。
- 建议：改为 HTTPS POST body；服务端也应停止在 access log 中记录敏感字段。

### 6. 求实论坛二级登录把密码放在 query string

- 位置：`lib/feedback/network/feedback_service.dart:147`
- 问题：`auth/passwd` 使用 GET query 传 `user` / `password`。
- 风险：即使基础域名是 HTTPS，URL 仍容易被客户端、代理和服务端日志持久化。
- 建议：改为 POST body；同时统一登录接口的敏感字段脱敏策略。

### 7. 修改密码接口把新密码放在 query string

- 位置：`lib/auth/network/auth_service.dart:227`
- 问题：`password/person/reset` 使用 `queryParameters: {"password": password}`。
- 风险：新密码会被 URL 日志记录。
- 建议：改为 POST/PUT body，并确保网络日志脱敏。

### 8. 多处 WebView/外部浏览器 URL 直接携带主 token

- 位置：`lib/home/view/web_views/fifty_two_hz_page.dart:12`, `lib/home/view/web_views/festival_page.dart:35`, `lib/home/view/dialogs/activity_dialog.dart:53`
- 问题：`CommonPreferences.token.value` 和 lake token 被直接替换到 URL 中。
- 风险：第三方页面、外部浏览器、系统日志、分享链路都可能拿到长期 token。
- 建议：改成短期授权 code；外部浏览器不要携带主账号 token。

### 9. 账号密码和办公网密码明文存在 SharedPreferences

- 位置：`lib/commons/preferences/common_prefs.dart:27`, `lib/commons/preferences/common_prefs.dart:70`, `lib/auth/network/auth_service.dart:276`
- 问题：主账号密码、办公网密码均使用普通 preferences 保存。
- 风险：设备备份、root/调试环境、日志或本地漏洞都可能泄露用户密码。
- 建议：使用平台安全存储；更理想的是保存 refresh token，不保存原始密码。

### 10. 网络层默认记录请求 body 和调试响应

- 位置：`lib/commons/network/dio_abstract.dart:51`, `lib/commons/network/dio_abstract.dart:58`
- 问题：所有 Dio 默认加 `LogInterceptor(requestBody: true)`，debug client 还记录 `responseBody: true`。
- 风险：登录、改密、token、身份证号等敏感数据会进入日志体系。
- 建议：release 禁用 body 日志；统一对 `password`、`token`、`Authorization`、身份证、手机号脱敏。

### 11. 主账号 token 每次请求都被 print

- 位置：`lib/auth/network/auth_service.dart:31`
- 问题：AuthDio interceptor 在 onRequest 中 `print("token: " + CommonPreferences.token.value)`。
- 风险：release 下 `print` 会被 zone 捕获进入内存日志。
- 建议：删除该打印；如果必须定位问题，只打印 token hash 的前几位。

### 12. 图书馆登录直接打印用户名和密码

- 位置：`lib/commons/network/library_service.dart:103`
- 问题：`print("loging in with $username, $password")`。
- 风险：办公网/图书馆凭证直接泄露到日志。
- 建议：立即删除；补充 lint 禁止打印敏感字段。

### 13. 隐藏日志页可展示敏感日志

- 位置：`lib/auth/view/settings/setting_page.dart:112`, `lib/auth/view/user/debug_page.dart:9`
- 问题：长按设置项即可进入日志页，日志内容来自 `Logger.logs`。
- 风险：结合网络层日志，普通用户或借机使用设备的人可看到 token/密码/响应数据。
- 建议：release 禁用该入口；日志页加开发构建开关或强认证。

### 14. Gradle 文件硬编码仓库密码和厂商 secret

- 位置：`android/build.gradle:36`, `android/app/build.gradle:78`
- 问题：Maven credentials、OPPO app secret 等直接写在仓库中。
- 风险：密钥轮换困难，泄露面扩大。
- 建议：迁移到 CI secret / `local.properties` / Gradle properties，并评估已提交 secret 是否需要轮换。

### 15. `StorageUtil.init()` 未 await，启动存在竞态

- 位置：`lib/main.dart:59`, `lib/main.dart:231`, `lib/commons/channel/download/download_item.dart:105`
- 问题：`StorageUtil.init()` 是 async，但 main 中没有 `await`；首帧后字体下载立刻读取 `StorageUtil.downloadDir.path`。
- 风险：冷启动时可能触发 `LateInitializationError: downloadDir has not been initialized`。现有测试已经触发该类异常。
- 建议：`await StorageUtil.init()` 后再 `runApp`，或让 `DownloadType.path` 返回 Future 并显式处理初始化状态。

### 16. 存储目录获取使用强制解包和 `.first`

- 位置：`lib/commons/util/storage_util.dart:18`
- 问题：`getExternalStorageDirectories(...)! .first` 没有处理 null 或空列表。
- 风险：部分 Android 版本、权限状态或厂商 ROM 下会直接崩溃。
- 建议：使用 fallback 到 app-specific directory，并把失败转成可恢复错误。

### 17. Android 构建无条件读取 `local.properties`

- 位置：`android/app/build.gradle:25`
- 问题：`props.load(project.rootProject.file('local.properties').newDataInputStream())` 在文件不存在时直接失败。
- 风险：干净 checkout、CI、首次构建会在配置阶段失败。
- 建议：像前面的 `localPropertiesFile.exists()` 一样判断存在；签名字段缺失时只影响 release signing。

### 18. 语音权限声明后又被移除

- 位置：`android/app/src/main/AndroidManifest.xml:12`, `android/app/src/main/AndroidManifest.xml:47`
- 问题：先声明 `RECORD_AUDIO`，随后用 `tools:node="remove"` 删除。
- 风险：小天语音/录音功能在 Android 上无法正常申请麦克风权限。
- 建议：如果语音功能仍在线，恢复权限并完善运行时申请；如果下线，删除相关 UI 入口和依赖。

### 19. `pubspec.yaml` 版本号与 `EnvConfig.VERSIONCODE` 默认值不一致

- 位置：`pubspec.yaml:9`, `lib/commons/environment/config.dart:40`
- 问题：pubspec 是 `4.5.2+180`，代码默认 `VERSIONCODE` 仍是 `179`。
- 风险：打包脚本漏传 dart-define 时，更新判断会把当前版本当作旧版本。
- 建议：版本脚本生成两处值，或运行时从 `package_info_plus` 读取真实 build number。

### 20. `pubspec.lock` 被忽略且未纳入版本控制

- 位置：`.gitignore:31`
- 问题：Flutter 应用没有提交 lockfile。
- 风险：`any`、git 依赖、transitive 版本变化会导致不同机器构建不同产物。
- 建议：应用仓库应提交 `pubspec.lock`；依赖升级走显式 PR。

### 21. 依赖约束过宽，且存在全局 override

- 位置：`pubspec.yaml:57`, `pubspec.yaml:82`, `pubspec.yaml:122`, `pubspec.yaml:147`
- 问题：多个依赖使用 `any`，同时全局 override `photo_manager: 3.6.4`。
- 风险：依赖解析不可预测；override 会影响所有间接依赖，升级时难以定位兼容性问题。
- 建议：固定最小可用版本范围；override 只作为临时补丁，并记录移除条件。

### 22. Analyzer lint 基本被关闭

- 位置：`analysis_options.yaml:1`
- 问题：`package:flutter_lints/flutter.yaml` 被注释掉。
- 风险：大量 lifecycle、style、unused、unsafe context 问题只能靠人工发现。
- 建议：恢复基础 lint，并按模块逐步处理；至少启用 `use_build_context_synchronously`、`avoid_print`、`unawaited_futures`。

### 23. 现有测试是默认 counter 测试且无法通过

- 位置：`test/widget_test.dart:14`
- 问题：测试仍断言 Counter UI，但应用没有 Counter；且直接 pump `WePeiYangApp()` 没有初始化全局依赖。
- 风险：CI 即使接入也无法提供有效质量门禁。
- 建议：删除默认测试，替换为启动 smoke test；在 test setup mock `SharedPreferences`、存储目录、MethodChannel。

### 24. `RemoteConfig.getRemoteConfig()` 在 build 中触发副作用

- 位置：`lib/main.dart:369`, `lib/commons/channel/remote_config/remote_config_manager.dart:20`
- 问题：`Builder` 的 build 每次执行都会读取远端配置并 `notifyListeners()`。
- 风险：主题切换/重建可能触发重复 MethodChannel 调用，甚至形成 build -> notify -> build 的抖动。
- 建议：移到 `initState` 或 provider 初始化逻辑，并加 `_loaded` / refresh 策略。

### 25. `AsyncTimer.runRepeatChecked` 异常时不会恢复状态

- 位置：`lib/commons/network/async_timer.dart:8`
- 问题：`_map[key] = true` 不在 `finally` 中。
- 风险：如果 body 抛出未捕获异常，该 key 对应功能会永久不可再次触发。
- 建议：使用 `try/finally` 恢复状态，并考虑返回执行结果。

### 26. WebView 初始化异步回调缺少 `mounted` 检查

- 位置：`lib/commons/webview/wby_webview.dart:86`, `lib/commons/webview/wby_webview.dart:94`
- 问题：`getInitialUrl(context)` await 后直接 `setState`。
- 风险：用户快速返回时可能触发 setState after dispose。
- 建议：await 后先检查 `mounted`；WebView 回调也应统一检查生命周期。

### 27. 所有 WebView 都开启 unrestricted JavaScript

- 位置：`lib/commons/webview/wby_webview.dart:132`
- 问题：通用 WebView 默认 `JavascriptMode.unrestricted`，URL 又可来自远程配置。
- 风险：远程页面一旦被劫持或配置错误，攻击面较大。
- 建议：按页面配置 JS 权限；默认禁用 JS，只有受信域名开启。

### 28. 路由管理对未知路由直接强制解包

- 位置：`lib/commons/util/router_manager.dart:35`
- 问题：`_routers[settings.name]!(settings.arguments)` 没有 fallback。
- 风险：推送、shortcut、深链或远程配置传入未知 route 时直接崩溃。
- 建议：增加 notFound route，并记录错误上下文。

### 29. `PageStackObserver` 在手势开始时提前移除页面

- 位置：`lib/commons/util/navigator_observers.dart:50`
- 问题：`didStartUserGesture` 中直接 `pageStack.remove(route.settings.name)`。
- 风险：用户取消返回手势时，页面仍在栈上但 `pageStack` 已丢失，后续防重入判断会失效。
- 建议：只在 `didPop` / `didRemove` / `didReplace` 更新栈；手势取消需要恢复。

### 30. 失物招领页在 `deactivate()` 中访问 Provider

- 位置：`lib/lost_and_found/view/lost_and_found_sub_page.dart:38`
- 问题：`deactivate()` 没调用 `super.deactivate()`，还对 `ModalRoute.of(context)` 做 `bool!`，随后 `_onRefresh()` 访问 `context.read`。
- 风险：路由切换或 widget 移除时可能触发 ancestor lookup 异常或空值崩溃。
- 建议：不要在 `deactivate` 发起刷新；改为 route observer、返回结果或页面恢复事件。

### 31. 失物招领分页失败后页码不会回滚

- 位置：`lib/lost_and_found/view/lost_and_found_sub_page.dart:75`
- 问题：加载下一页时先 `page: ++curPage`，失败分支只标记 `loadFailed()`。
- 风险：下一次加载会跳过失败页，造成列表缺页。
- 建议：请求成功后再递增，或失败时 `curPage--`。

### 32. 多个全局 controller/listener 没有释放

- 位置：`lib/feedback/view/lake_home_page/lake_notifier.dart:266`, `lib/commons/channel/download/download_manager.dart:145`
- 问题：`LakePageController` 内含 `ScrollController` / `RefreshController`，但静态 map 清理时未 dispose；下载 listener 加入 map 后也未看到移除。
- 风险：页面切换、账号切换或多次下载后泄漏 controller、回调和 MethodChannel 状态。
- 建议：为 controller/listener 定义生命周期，清理时显式 dispose/remove。

### 33. `RefreshSkeleton` 在 build 中创建 `ScrollController`

- 位置：`lib/feedback/view/lake_home_page/normal_sub_page.dart:367`
- 问题：StatelessWidget 每次 build 都创建新的 `ScrollController`，没有 dispose。
- 风险：频繁刷新骨架屏会泄漏 controller。
- 建议：改成 StatefulWidget 管理 controller，或不传 controller。

### 34. `FutureBuilder` 在 build 中直接创建网络 Future

- 位置：`lib/feedback/view/lake_home_page/normal_sub_page.dart:286`
- 问题：`future: LakeUtil.initPostList(index)` 每次 build 都会创建新 Future。
- 风险：如果缓存未及时写入或重建频繁，会重复请求/刷新同一列表。
- 建议：在 `initState` 缓存 Future，forced refresh 时显式替换。

### 35. 刷新延迟 Timer 里 `setState` 缺少 mounted 检查

- 位置：`lib/feedback/view/lake_home_page/normal_sub_page.dart:99`
- 问题：Timer 触发时直接 `setState(() { isRefresh = true; })`。
- 风险：刷新期间退出页面会触发 setState after dispose。
- 建议：Timer 回调和 await 后都检查 `mounted`，dispose 中取消未完成 timer。

### 36. 搜索页 SharedPreferences 初始化晚于用户交互

- 位置：`lib/feedback/view/search_page.dart:23`, `lib/lost_and_found/view/lost_and_found_search_page.dart:24`
- 问题：`_prefs` 是 `late final`，在 post-frame async 中初始化；但 `_searchHistoryList` listener 和提交/删除操作可能更早访问 `_prefs`。
- 风险：用户快速输入或删除历史时触发 LateInitializationError。
- 建议：在 `initState` 中先同步禁用交互，或用 FutureBuilder/加载状态等待 prefs 初始化。

### 37. 两个微口令去重偏好使用同一个 key

- 位置：`lib/commons/preferences/common_prefs.dart:50`
- 问题：`feedbackLastWeCo` 和 `feedbackLastLostAndFoundWeCo` 都使用 `'feedbackLastWeKo'`。
- 风险：求实论坛和失物招领互相覆盖“已处理微口令”状态，导致漏弹或重复弹。
- 建议：拆成不同 key，并写一次 migration。

### 38. 求实论坛和失物招领复用同一 URI scheme / path

- 位置：`lib/feedback/view/lake_home_page/lake_notifier.dart:217`, `lib/lost_and_found/view/lost_and_found_notifier.dart:130`, `lib/lost_and_found/view/lost_and_found_detail_page.dart:469`
- 问题：两个模块都解析 `wpy://school_project/(\d*)`；失物招领分享文案也写成“求实论坛打开问题”。
- 风险：复制失物招领口令后，求实论坛入口可能抢先按帖子 ID 查询，两个模块语义混乱。
- 建议：给 LAF 使用独立 path，例如 `wpy://lost_and_found/<id>`；修正文案。

### 39. `PrefsBean<List>` / `PrefsBean<List<CardBean>>` 无法可靠持久化

- 位置：`lib/commons/preferences/common_prefs.dart:39`, `lib/commons/preferences/common_prefs.dart:126`, `lib/commons/preferences/common_prefs.dart:231`
- 问题：`_setValue` 只支持 `List<String>`；`accountUpgrade` 无默认值时可能返回 null；`displayedTool` / `userTool` 是 `List<CardBean>`，但 preferences 无法保存该类型。
- 风险：账号升级状态、工具栏自定义等功能在重启后丢失或崩溃。
- 建议：只在 prefs 层存 JSON string / string list；为所有 List 偏好提供非空默认值。

### 40. 图片压缩循环的错误分支不可达

- 位置：`lib/feedback/view/post_detail_page.dart:1501`, `lib/feedback/view/new_post_page.dart:1092`, `lib/lost_and_found/view/lost_and_found_post_page.dart:475`
- 问题：循环条件是 `j < 10`，内部判断 `if (j == 10)` 永远不会成立。
- 风险：压缩 10 次后仍超过 2MB 的图片会继续加入上传列表，而不是提示用户。
- 建议：循环结束后再次检查文件大小；或把失败判断放在循环外。

## 其他值得排期的风险

- `lib/commons/token/token_manager.dart:8` 使用 `base64.decode` 解析 JWT payload，没有处理 base64url 和 padding，可能导致 token 总被判为失效并频繁刷新。
- `lib/feedback/network/post.dart:546` 中 `AvatarBox.id` 是 `int`，但缺省值给了 `''`，服务端缺字段时会类型崩溃。
- `lib/lost_and_found/network/lost_and_found_post.dart:45` 的模型解析几乎没有默认值或类型兜底，接口字段缺失会直接崩溃。
- `lib/feedback/network/feedback_service.dart:113` 和 `lib/message/network/message_service.dart:27` 允许用户输入任意正则做屏蔽词，复杂正则可能在列表渲染时造成卡顿。
- `lib/commons/channel/download/download_manager.dart:55` 对 native 回调中的 listener/task 使用强制解包，迟到回调或异常 id 会崩溃。
