# WePeiYang-Flutter 非安全 Bug 审查报告

审查时间：2026-04-28  
审查范围：`lib/`、`android/`、`pubspec.yaml`、`analysis_options.yaml`、`.gitignore`、现有测试。  
排除范围：本报告暂不审查安全问题，不展开网络明文、证书、密钥、隐私、日志暴露等安全类风险。  
验证命令：

- `fvm flutter analyze --no-pub`：失败，当前 51 个 analyzer issue。
- `fvm flutter test --no-pub`：失败，默认 widget test 未适配当前 app 初始化流程，并触发 `sharedPref` / `downloadDir` late-init 异常。

## 总体结论

当前仓库最突出的非安全问题是启动初始化竞态、生命周期回调缺少 `mounted`/dispose 保护、全局静态状态和控制器泄漏、分页与搜索逻辑错误、JSON/缓存解析过于乐观，以及构建/测试输入不可复现。下面列出 40 个具体 bug，按影响优先排序。

## 问题清单

### 1. `StorageUtil.init()` 没有 await，启动期存在 late 字段竞争

- 位置：`lib/main.dart:53-60`，`lib/main.dart:221-232`，`lib/commons/channel/download/download_item.dart:100-106`
- 问题：`main()` 中调用 `StorageUtil.init();` 但没有 `await`。后续首帧回调会调用 `WbyFontLoader.initFonts()`，下载路径又依赖 `StorageUtil.downloadDir.path`。
- 影响：启动早期可能读取未初始化的 `downloadDir`，出现 `LateInitializationError`。当前 `fvm flutter test --no-pub` 已复现 `downloadDir has not been initialized`。
- 建议：把 `StorageUtil.init();` 改为 `await StorageUtil.init();`，并把依赖存储目录的初始化放到它之后。

### 2. 存储目录获取强制解包，部分设备会直接崩溃

- 位置：`lib/commons/util/storage_util.dart:17-31`
- 问题：Android 分支对 `getExternalStorageDirectories(...)` 使用 `!` 和 `.first`，没有处理返回 `null` 或空列表。
- 影响：无外部存储目录、权限/ROM 行为异常、桌面/测试环境下都会触发 crash。
- 建议：对 `null` 和空列表做 fallback，例如退回 `getApplicationSupportDirectory()` 或 `getTemporaryDirectory()`。

### 3. Windows 窗口初始化代码重复执行

- 位置：`lib/main.dart:68-82`，`lib/main.dart:97-112`
- 问题：`Platform.isWindows` 的 `windowManager.ensureInitialized()` 和 `waitUntilReadyToShow()` 写了两遍。
- 影响：Windows 端启动流程会重复 show/focus，后续如果加入更多窗口副作用会出现不可预测行为。
- 建议：保留一份窗口初始化逻辑，或抽成独立函数并只调用一次。

### 4. 根组件 `dispose()` 被标成 async，生命周期签名错误

- 位置：`lib/main.dart:209-215`
- 问题：`void dispose() async` 在 Flutter 生命周期里没有意义，返回的 Future 不会被框架等待。
- 影响：后续如果在这里加入异步清理，很容易以为被 await，实际会在 widget 销毁后继续跑。
- 建议：保持 `dispose()` 同步；异步清理应提前触发，或封装成不依赖 `BuildContext` 的后台任务。

### 5. `didChangeMetrics()` 直接用 context 和 setState，销毁边界不安全

- 位置：`lib/main.dart:243-253`
- 问题：系统 metrics 变化时直接 `MediaQuery.of(context)` 和 `setState()`，没有检查 `mounted`，也没有处理 context 上没有 `MediaQuery` 的情况。
- 影响：窗口 resize、键盘/折叠屏变化、页面销毁附近可能触发 `setState() called after dispose()` 或 `No MediaQuery widget found`。
- 建议：先判断 `mounted`，并优先从 `navigatorState.currentState?.overlay?.context` 获取稳定 context。

### 6. 亮暗色回调延迟使用 context，页面销毁后仍可能执行

- 位置：`lib/main.dart:257-260`
- 问题：`_onBrightnessChanged()` 延迟 400ms 后调用 `WpyTheme.updateAutoDarkTheme(context)`，没有 `mounted` 检查。
- 影响：切换系统主题时如果 app 根状态正在销毁，会使用失效 context。
- 建议：延迟回调后先检查 `mounted`，必要时取消或改用全局 navigator context。

### 7. 远程配置请求写在 build 中，会重复触发副作用

- 位置：`lib/main.dart:369-371`，`lib/commons/channel/remote_config/remote_config_manager.dart:9-25`
- 问题：`Builder.build` 每次重建都调用 `context.read<RemoteConfig>().getRemoteConfig()`；该方法会走 MethodChannel 并 `notifyListeners()`。
- 影响：一次 notify 会引发 rebuild，rebuild 又重新请求配置，形成重复 MethodChannel 请求和额外重绘。
- 建议：把远程配置初始化移到 `initState()` 或 provider 初始化阶段，并加 `_loaded/_loading` 防重入。

### 8. 启动跳转的延迟回调没有校验 context 是否还有效

- 位置：`lib/main.dart:553-605`
- 问题：`Future.delayed(...).then(...)` 后直接用 `Navigator` 和当前 `context` 跳转。
- 影响：启动页被销毁、热重载、系统返回或异常重建时，回调可能对失效 context 做导航。
- 建议：延迟回调后检查 `mounted`；跨页面跳转优先使用 `WePeiYangApp.navigatorState`。

### 9. 未知路由会被强制解包成崩溃

- 位置：`lib/commons/util/router_manager.dart:22-37`
- 问题：`_routers[settings.name]!(settings.arguments)` 对不存在的 route 使用 `!`。
- 影响：远程配置、剪贴板微口令、快捷方式或手写路由名一旦错字，直接空指针崩溃。
- 建议：增加 unknown route fallback 页面，并记录错误路由名。

### 10. iOS 返回手势一开始就修改 pageStack，取消手势会导致栈错乱

- 位置：`lib/commons/util/navigator_observers.dart:49-56`
- 问题：`didStartUserGesture` 里直接 `pageStack.remove(route.settings.name)`。
- 影响：用户侧滑返回后又取消，真实页面没 pop，但 `pageStack` 已经少了一层。
- 建议：不要在 gesture start 修改栈；只在 `didPop`/`didRemove`/`didReplace` 后同步。

### 11. `AsyncTimer.runRepeatChecked` 没有 finally，异常后同类请求永久锁死

- 位置：`lib/commons/network/async_timer.dart:8-14`
- 问题：执行 `body()` 期间如果抛异常，`_map[key] = true` 不会执行。
- 影响：登录、验证码、发帖、删除、上传等使用该 mixin 的接口，异常一次后同 key 后续点击都会被静默忽略。
- 建议：用 `try { await body(); } finally { _map[key] = true; }`。

### 12. WebView 初始化异步返回后 setState，没有 mounted 保护

- 位置：`lib/commons/webview/wby_webview.dart:86-104`
- 问题：`initUrl()` await 后直接 `setState()`。
- 影响：用户快速退出 WebView 或远程配置慢返回时，会触发 `setState() called after dispose()`。
- 建议：每个 await 后先 `if (!mounted) return;`。

### 13. 下载进度回调强制解包 listener/task，原生回调乱序会崩

- 位置：`lib/commons/channel/download/download_manager.dart:49-66`
- 问题：`listeners[listenerId]!` 和 `listener.tasks[taskId]!` 假设回调一定对应当前 Dart 内存状态。
- 影响：app 重启、任务清理、重复 listenerId、原生延迟回调时，下载回调会 crash。
- 建议：找不到 listener/task 时忽略或上报，不要强制解包。

### 14. 下载 listener 写入后没有移除，长时间运行会保留过期回调

- 位置：`lib/commons/channel/download/download_manager.dart:136-145`
- 问题：`listeners[listener.listenerId] = listener` 后没有看到完成或失败时 remove。
- 影响：多次下载后旧 listener 留在静态 map 中，可能造成内存增长和错误回调。
- 建议：在 allComplete/allSuccess/failed 后移除对应 listener，并提供取消下载时的清理入口。

### 15. Android 构建无条件读取 `local.properties`，干净环境会失败

- 位置：`android/app/build.gradle:25-26`
- 问题：前面虽然按 Flutter 模板读了 `local.properties`，但这里又无条件 `props.load(project.rootProject.file('local.properties').newDataInputStream())`。
- 影响：CI、干净 clone、非 Android Studio 环境没有该文件时，Gradle 配置阶段直接失败。
- 建议：读取前判断文件存在；需要的本地属性给默认值或通过环境变量注入。

### 16. Android 录音权限先声明又被移除，语音输入功能不可用

- 位置：`android/app/src/main/AndroidManifest.xml:8-12`，`android/app/src/main/AndroidManifest.xml:46-49`，`lib/commons/speech_to_text/model/speech_record_manager.dart:11-24`
- 问题：manifest 声明 `RECORD_AUDIO` 后又用 `tools:node="remove"` 移除；代码仍会请求 `Permission.microphone` 并使用 `record`。
- 影响：Android 上语音输入可能一直拿不到权限，表现为录音按钮不可用或报 `Microphone permission not granted`。
- 建议：如果语音功能要保留，移除 `tools:node="remove"`；如果暂时关闭功能，应隐藏入口并避免请求权限。

### 17. app versionCode 默认值和 `pubspec.yaml` 不一致

- 位置：`pubspec.yaml:6-9`，`lib/commons/environment/config.dart:39-43`
- 问题：`pubspec.yaml` 是 `4.5.2+180`，但 `EnvConfig.VERSIONCODE` 默认是 `179`。
- 影响：未通过 `--dart-define=VERSIONCODE` 构建时，应用内更新判断会把当前版本识别错。
- 建议：让默认值和 `pubspec.yaml` 保持一致，或构建脚本强制生成该文件并在 CI 校验。

### 18. 应用仓库忽略 `pubspec.lock`，依赖解析不可复现

- 位置：`.gitignore:31`，`pubspec.lock`
- 问题：Flutter 应用通常应提交 lockfile；当前 `.gitignore` 忽略 `/pubspec.lock`。
- 影响：不同机器 `pub get` 可能拿到不同 transitive dependency，导致构建、运行、插件行为漂移。
- 建议：停止忽略 app 的 `pubspec.lock`，提交稳定 lockfile。

### 19. 多个依赖使用 `any`，叠加 override，版本漂移风险高

- 位置：`pubspec.yaml:57`，`pubspec.yaml:82-83`，`pubspec.yaml:122`，`pubspec.yaml:135`，`pubspec.yaml:147-148`
- 问题：`extended_image`、`glass_kit`、`frosted_glass_effect`、`wechat_assets_picker`、`glass` 使用 `any`，同时全局 override `photo_manager`。
- 影响：插件 API 或 Android/iOS 原生依赖变化时，功能可能在没有代码变更的情况下坏掉。
- 建议：锁定已验证版本；override 保留注释说明原因和移除条件。

### 20. lint 配置被关闭，当前 analyzer 已经暴露 51 个问题

- 位置：`analysis_options.yaml:1`，`fvm flutter analyze --no-pub`
- 问题：`include: package:flutter_lints/flutter.yaml` 被注释，现有 analyzer 仍有 51 个 issue。
- 影响：`must_call_super`、无效 null-aware、dead code、未使用字段等问题没有被作为阻断处理。
- 建议：恢复基础 lint，先把 51 个 issue 分批归零，再把 analyze 加入 CI。

### 21. 默认 widget test 与当前 app 完全不匹配

- 位置：`test/widget_test.dart:14-28`
- 问题：测试仍是 Flutter 默认 counter 示例，却直接 pump `WePeiYangApp()`。
- 影响：测试既找不到 counter，也没有执行 `CommonPreferences.init()` / `StorageUtil.init()` 等真实初始化，当前测试必失败。
- 建议：删除 counter 断言；新增 app smoke test 前先完成必要 mock/初始化。

### 22. 失物招领子页在 `deactivate()` 中刷新数据且没调用 super

- 位置：`lib/lost_and_found/view/lost_and_found_sub_page.dart:37-43`
- 问题：`deactivate()` 未调用 `super.deactivate()`，还对 `ModalRoute.of(context)?.isCurrent` 结果强制 `bool!`，并在生命周期回调里触发 `_onRefresh()`。
- 影响：切 tab、路由切换、widget 移动时可能触发意外网络刷新；`ModalRoute` 为 null 时会崩。
- 建议：调用 `super.deactivate()`；不要在 `deactivate` 里刷新业务数据，改为明确的页面可见事件。

### 23. 失物招领分页失败会跳页

- 位置：`lib/lost_and_found/view/lost_and_found_sub_page.dart:75-96`
- 问题：`page: ++curPage` 在请求前自增，失败时没有回滚。
- 影响：第 N+1 页加载失败后，下次会直接请求 N+2 页，漏掉一页数据。
- 建议：用局部 `nextPage = curPage + 1`，成功后再 `curPage = nextPage`。

### 24. 失物招领搜索结果加载更多永远请求第一页

- 位置：`lib/lost_and_found/view/lost_and_found_search_result_page.dart:78-102`
- 问题：`_onLoading()` 固定 `page: 1`。
- 影响：用户上拉加载时会重复第一页，列表重复或无法继续分页。
- 建议：增加当前页状态，并在成功加载后递增。

### 25. 失物招领搜索结果页在 build 中触发刷新

- 位置：`lib/lost_and_found/view/lost_and_found_search_result_page.dart:106-112`
- 问题：`build()` 内根据 provider 状态直接调用 `_onRefresh()`。
- 影响：重建期间触发网络和 provider 写入，可能造成重复请求、build 循环或状态错乱。
- 建议：把首次刷新放入 `initState()` / post-frame，并加 loading 状态防重入。

### 26. 青年湖 tab 控制器和刷新控制器没有释放

- 位置：`lib/feedback/view/lake_home_page/lake_notifier.dart:112-123`，`lib/feedback/view/lake_home_page/lake_notifier.dart:266-286`，`lib/feedback/view/lake_home_page/lake_notifier.dart:226-232`
- 问题：`LakePageController` 内部创建 `ScrollController`、`RefreshController`、`ValueNotifier`、`LakePosts`，`clearAll()` 只是 clear map，没有 dispose。
- 影响：登录切换、tab 重建、长期使用后会泄漏 controller/listener，并可能保留旧滚动状态。
- 建议：给 `LakePageController` 增加 `dispose()`，`clearAll()` 先逐个释放。

### 27. 青年湖刷新定时器和 setState 缺少 mounted 保护

- 位置：`lib/feedback/view/lake_home_page/normal_sub_page.dart:92-120`
- 问题：`Timer` 回调和刷新结束后都直接 `setState()`。
- 影响：刷新过程中退出页面，Timer 或 await 后的 setState 会打到已销毁 State。
- 建议：Timer 回调和 await 后都检查 `mounted`；在 `dispose()` 中取消挂起 timer。

### 28. 青年湖列表 Future 在 build 内创建，重建会重复初始化

- 位置：`lib/feedback/view/lake_home_page/normal_sub_page.dart:282-288`
- 问题：`FutureBuilder(future: LakeUtil.initPostList(index), ...)` 每次 build 都创建新的 Future。
- 影响：父级状态变化会反复触发初始化检查/请求，造成闪烁或额外网络调用。
- 建议：在 `initState()` 缓存 `Future`，刷新时显式替换。

### 29. `RefreshSkeleton` 在 Stateless build 中创建 ScrollController

- 位置：`lib/feedback/view/lake_home_page/normal_sub_page.dart:362-370`
- 问题：`ListView(controller: ScrollController(...))` 每次 build 新建 controller，且无法 dispose。
- 影响：骨架屏多次创建会泄漏 controller；滚动状态也不可控。
- 建议：改为不用 controller，或把它改成 StatefulWidget 并在 `dispose()` 释放。

### 30. 论坛搜索页 `_prefs` 初始化存在竞态，ValueNotifier 也未释放

- 位置：`lib/feedback/view/search_page.dart:22-45`，`lib/feedback/view/search_page.dart:203-208`
- 问题：`_prefs` 是 `late final`，在 post-frame async 里赋值；`_searchHistoryList` listener 可能在 `_prefs` 初始化前调用 `_addHistory()`。页面也没有 dispose notifier。
- 影响：用户快速输入/删除历史时可能触发 late-init 崩溃；页面反复进入会泄漏 listener。
- 建议：先 await prefs 再挂 listener，或让 `_addHistory` 判空；补充 `dispose()`。

### 31. 失物招领搜索页有同样的 `_prefs` 竞态

- 位置：`lib/lost_and_found/view/lost_and_found_search_page.dart:23-76`
- 问题：`_prefs` post-frame async 初始化，`_foundSearchHistoryList` listener 立刻挂上，`confirmFun` 也会调用 `_addHistory()`。
- 影响：页面打开后立即操作搜索历史，可能访问未初始化 `_prefs`。
- 建议：和论坛搜索页一样，把 prefs 初始化和 listener 注册顺序调整清楚，并释放 notifier。

### 32. 论坛和失物招领共用同一个微口令偏好 key

- 位置：`lib/commons/preferences/common_prefs.dart:50-52`
- 问题：`feedbackLastWeCo` 和 `feedbackLastLostAndFoundWeCo` 都使用 `'feedbackLastWeKo'`。
- 影响：两个模块会互相覆盖“上次处理的微口令”，导致某些分享口令不弹窗或重复弹窗。
- 建议：给失物招领单独 key，例如 `lostAndFoundLastWeKo`，并做旧 key 迁移。

### 33. 首页工具栏的 `List<CardBean>` 偏好实际不会被持久化

- 位置：`lib/commons/preferences/common_prefs.dart:124-144`，`lib/commons/preferences/common_prefs.dart:224-252`，`lib/auth/view/settings/toolbar_manage_page.dart:217-221`，`lib/auth/view/settings/toolbar_manage_page.dart:354-359`
- 问题：`PrefsBean<List<CardBean>>` 读写走的是 `SharedPreferences.get()` / `_setValue()`，但 `_setValue` 只支持 `List<String>`，不支持对象列表。
- 影响：用户调整首页工具栏后，变更只在内存中有效，重启后丢失。
- 建议：把工具栏配置序列化成 JSON 字符串或 `List<String>` id 列表，只存可持久化数据。

### 34. `PrefsBean<T>.value` 对无默认值 key 可能返回 null 并触发类型崩溃

- 位置：`lib/commons/preferences/common_prefs.dart:39`，`lib/commons/preferences/common_prefs.dart:209-216`，`lib/home/view/home_page.dart:100-106`
- 问题：很多 `PrefsBean<String/List>` 没传默认值；`T get value => _getValue(_key) ?? _default` 在 `_default == null` 时仍返回 null 给非空 T。
- 影响：例如 `accountUpgrade.value.isNotEmpty` 在首次安装没有 key 时可能变成 `Null is not a subtype of List`。
- 建议：所有非空泛型必须提供默认值；或把 `PrefsBean` 改成显式 nullable API。

### 35. 失物招领微口令仍使用论坛路由文案和 URL scheme

- 位置：`lib/feedback/view/lake_home_page/lake_notifier.dart:217-223`，`lib/lost_and_found/view/lost_and_found_notifier.dart:124-153`，`lib/lost_and_found/view/lost_and_found_detail_page.dart:469-475`
- 问题：两个模块都解析 `wpy://school_project/(\d*)`；失物招领分享文案也写“求实论坛打开问题”，并写入论坛 last key。
- 影响：两个模块 id 空间冲突时会打开错模块；失物招领分享体验和去重状态都会错。
- 建议：失物招领使用独立 scheme/path，例如 `wpy://lost_and_found/<id>`，并独立记录 last key。

### 36. 图片压缩失败分支永远不可达

- 位置：`lib/feedback/view/post_detail_page.dart:1501-1506`，`lib/feedback/view/new_post_page.dart:1092-1097`，`lib/lost_and_found/view/lost_and_found_post_page.dart:475-480`
- 问题：循环条件是 `j < 10`，循环体内判断 `if (j == 10)`，该分支永远不会执行。
- 影响：压缩 10 次后仍大于 2MB 的图片不会被拦截，后续上传可能失败或卡住。
- 建议：循环结束后再检查文件大小；或判断 `if (j == 9 && stillTooLarge)`。

### 37. JWT 本地解析使用普通 base64，合法 token 可能被误判失效

- 位置：`lib/commons/token/token_manager.dart:4-20`
- 问题：JWT payload 是 base64url 编码，并且经常省略 padding；代码使用 `base64.decode(payloadString)`。
- 影响：部分合法 token 会解析失败，然后本地认为 token 失效，导致频繁刷新或登录态异常。
- 建议：使用 `base64Url.normalize()` + `base64Url.decode()`，并校验 token split 长度。

### 38. `AvatarBox.id` 默认值类型错误

- 位置：`lib/feedback/network/post.dart:534-548`
- 问题：`id` 声明为 `late int`，但缺失时赋值 `json['id'] ?? ''`。
- 影响：接口缺字段或字段为 null 时，运行时会把 `String` 赋给 `int`，直接崩溃。
- 建议：缺失时给 `0` 或把字段改成 `int?`，并在 UI 层处理缺省。

### 39. 多个消息/帖子模型解析缺少 null 和格式保护

- 位置：`lib/lost_and_found/network/lost_and_found_post.dart:43-63`，`lib/message/model/message_model.dart:80-87`，`lib/message/model/message_model.dart:125-131`，`lib/feedback/network/post.dart:33-42`
- 问题：`LostAndFoundPost.fromJson` 直接把 json 字段赋给非空字段；`NoticeMessage` / `Reply` 直接 `DateTime.parse`；`Reply.image_urls` 和 `VoteDetail.options` 直接 `.map()`。
- 影响：后端字段为 null、日期格式变化或列表缺失时，列表页/详情页会整体崩溃。
- 建议：模型层做 typed parsing 和默认值；对日期使用 `DateTime.tryParse`，列表字段使用 `List.from(json['x'] ?? const [])`。

### 40. 缓存和用户输入解析过于乐观，坏数据会让页面打不开

- 位置：`lib/home/view/wpy_page.dart:294-310`，`lib/schedule/model/course_provider.dart:172-179`，`lib/schedule/model/exam_provider.dart:114-119`，`lib/gpa/model/gpa_notifier.dart:166-173`，`lib/studyroom/model/studyroom_provider.dart:59-60`，`lib/feedback/view/search_page.dart:52-57`，`lib/feedback/view/components/widget/linkify_text.dart:39-56`
- 问题：`displayOrder` 直接 `int.parse` 并索引工具栏；课表/考表/GPA 缓存直接 `json.decode`；自习室 `firstWhere` 无 fallback；`#MP` 校验只要求前缀数字，`#MP123abc` 会通过 regex 后在 `int.parse` 崩溃。
- 影响：SharedPreferences 被旧版本/异常写坏、后端返回变化、用户输入畸形微口令时，对应页面会直接不可用。
- 建议：所有本地缓存解析都加 try/catch 和 reset fallback；搜索和微口令使用完整正则 `^#MP\\d+$` 或 `int.tryParse`。

## 建议修复顺序

1. 先修 P0/P1 启动和测试阻断：问题 1、2、7、11、15、17、21。
2. 再集中处理生命周期和 controller 泄漏：问题 5、6、8、12、13、14、22、26、27、29、30、31。
3. 然后修功能逻辑：问题 23、24、25、32、33、35、36、37。
4. 最后补齐解析韧性和工具链：问题 18、19、20、34、38、39、40。
