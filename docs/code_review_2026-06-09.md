# WePeiYang-Flutter 全仓代码审查报告

审查时间：2026-06-09
审查范围：`lib/` 全部 Dart 源码（~290 文件），覆盖 network、preferences、token、auth、feedback、studyroom、schedule、xiaotian 等核心模块。
验证命令：未执行（仅静态审查）。

## 总体结论

本次审查发现 42 个问题，按严重度分为四档。最突出的横向问题是：(1) 网络层 Dio 初始化 crash 和错误拦截链断裂、(2) 多处 `build()` 中直接调用 async 方法造成请求风暴、(3) Preference 持久化层静默丢弃数据、(4) AsyncTimer 无 finally 导致功能永久死锁、(5) Cookie 多实例覆盖、(6) Token 刷新无互斥、(7) SSE 连接泄漏。以下按严重度排列。

---

## 问题清单

### 1. `_SpiderDio` 初始化时 crash

- 位置：`lib/commons/network/dio_abstract.dart:51-56`，`lib/commons/network/classes_service.dart:17-22`
- 作者：待 git blame 确认最初 DioAbstract 的创建者
- 问题：`_SpiderDio` 用 field initializer 覆盖 `interceptors`：
  ```dart
  @override
  List<Interceptor> interceptors = [cookieCachedHandler(), ClassesErrorInterceptor()];
  ```
  Dart 子类 field initializer 在父类构造函数体**之后**执行。`DioAbstract()` 体内 `...interceptors` 运行时 `this.interceptors` 为 null，`...null` 导致 `TypeError` 崩溃。拦截器链从未建立。（注：`LibraryDio`/`LibraryUserDio` 使用 getter override，正确。）
- 影响：所有课表查询（Spider）相关的 Dio 请求无 cookie、无错误拦截。
- 建议：与 `LibraryDio` 一致改为 getter override，或在父类构造完成后再初始化拦截器。

---

### 2. Cookie 多实例共享同一文件，互相覆盖

- 位置：`lib/commons/network/dio_cookie_cached_handler/dio_cookie_interceptor.dart:7-9`，`lib/commons/network/classes_service.dart:21`，`lib/commons/network/library_service.dart:45,83`
- 作者：待 git blame 确认 cookie handler 模块的创建者
- 问题：每次调用 `cookieCachedHandler()` 创建独立 `CookieStorage` 实例，但都指向 `getApplicationSupportDirectory()/.dio.cookies`。`_SpiderDio`、`LibraryDio`、`LibraryUserDio` 各有独立实例。任一写盘即覆盖其他实例的 cookie。
- 影响：登录态（JSESSIONID 等）在不同 Dio 实例之间持续丢失和损坏，表现为随机掉登录。
- 建议：将 `CookieStorage` 改为单例或由上层注入同一实例，确保所有 Dio 共享同一份 cookie 存储。

---

### 3. `ErrorInterceptor` 丢弃错误类型，使下游错误拦截死代码化

- 位置：`lib/commons/network/error_interceptor.dart:3-24`，`lib/commons/network/dio_abstract.dart:51-56`
- 作者：待 git blame 确认
- 问题：Dio 错误拦截器按**逆序**执行，`ErrorInterceptor` 最先运行。其创建新 `DioException` 时未传递 `type`（line 19-23），丢弃了原始 `DioExceptionType`。后续 `ClassesErrorInterceptor` 的 401/500/302 分支基于 `e.type` 判断，永远不匹配。
- 影响：401 未登录、500 服务器错误等关键错误处理成为死代码，用户看到空白错误提示。
- 建议：创建 `WpyDioException` 时传入 `type: err.type`，保持错误类型信息。

---

### 4. 重试机制完全无效

- 位置：`lib/commons/network/dio_abstract.dart:82-85`
- 作者：待 git blame 确认
- 问题：`retryIf: (e) => e is SocketException || e is TimeoutException`。Dio 的 retry 回调收到的 `e` 是 `DioException`，永远不满足 `is SocketException`。
- 影响：所有网络抖动、超时场景无自动重试。
- 建议：检查 `e is DioException` 后判断 `e.type`（如 `connectionError`、`connectionTimeout`）或 `e.error`。

---

### 5. `ClassroomsPage` 和 `ClassroomDetailPage` 在 `build()` 中发起 async 请求

- 位置：`lib/studyroom/view/page/classrooms_page.dart:45,55`，`lib/studyroom/view/page/classroom_detail_page.dart:185,213`
- 作者：steven12138（`7e2bba2d` 2024-01-20，`91624e95` 2024-01-20）
- 问题：
  ```dart
  void initRooms(int session, DateTime date) async { ... }
  // build() 中直接调用：
  initRooms(_session, _date);
  ```
  `StatelessWidget.build()` 每次重建都触发一次 API 请求（`getRoomList` / `getSchedule`），而 `TimeProvider` 状态变化会导致重建。
- 影响：每次切换日期/时段产生大量并发重复 API 请求，造成请求风暴和状态竞态覆盖。`classroom_detail_page.dart:188` 中 `initSchedule` 还不清空 schedule map，数据无限累计。
- 建议：将数据加载移到 provider 初始化逻辑中，或使用 `initState`/post-frame callback 并加防重入标志；`build()` 中只读取已缓存数据。

---

### 6. `FavourRoomCard` 导航参数类型不匹配（100% crash）

- 位置：`lib/studyroom/view/widget/favour_room_card.dart:28-29`，`lib/studyroom/model/studyroom_router.dart:15`
- 作者：待 git blame 确认
- 问题：
  ```dart
  // favour_room_card.dart — 传递 Room 对象
  Navigator.of(context).pushNamed(StudyRoomRouter.detail, arguments: room);
  // studyroom_router.dart — 强转为 Map
  var args = arguments as Map<String, dynamic>;
  ```
- 影响：从收藏房间点击进入详情页**每次必 crash**。
- 建议：统一参数类型，要么 router 接收 `Room` 对象，要么调用方把 `Room` 转成 `Map`。

---

### 7. `AsyncTimer.runRepeatChecked` 无 finally，异常后永久死锁

- 位置：`lib/commons/network/async_timer.dart:8-15`
- 作者：待 git blame 确认
- 问题：
  ```dart
  _map[key] = false;
  await body();
  _map[key] = true;  // body 抛异常时永远执行不到
  ```
  任何 `body()` 内部未被 catch 的异常（包括 JSON 解析错误、null 错误等非 `DioException`）会导致 key 永久锁死。
- 影响：论坛发帖、点赞、删除、上传头像等使用该 mixin 的功能，异常后**后续所有同 key 操作静默丢弃**，无任何用户反馈。
- 建议：用 `try { await body(); } finally { _map[key] = true; }`。

---

### 8. SSE 连接泄漏

- 位置：`lib/xiaotian/network/xiaotian_service.dart:79-158`，`lib/xiaotian/view/widget/bubble_widget.dart:92-147`
- 作者：待 git blame 确认
- 问题：`bubbleFromAi.dispose()` 取消了 `StreamSubscription`，但内部 HTTP SSE 响应的 `stream.listen` 仍在运行，`StreamController` 未关闭，底层 `http.Client` 也未 close。
- 影响：每次 AI 对话离开页面后 SSE 连接持续消耗，`http.Client` 泄漏直到 GC；长时间使用后连接数累积。
- 建议：在 `StreamController` 设置 `onCancel` 关闭 HTTP 连接和 client；或 `dispose` 时显式清理内层 listener。

---

### 9. 生产环境打印明文密码

- 位置：`lib/commons/network/library_service.dart:105`
- 作者：待 git blame 确认
- 问题：`print("loging in with $username, $password");`
- 影响：图书馆/办公网凭证泄露到系统日志、ADB logcat。
- 建议：立即删除。

---

### 10. 反馈拦截器无声挂起请求

- 位置：`lib/feedback/network/feedback_service.dart:40-42`
- 作者：待 git blame 确认
- 问题：错误响应拦截中，当 `data` 或 `data['error']` 为 null 时直接 `return`，既没调用 `handler.next()` 也没 `handler.reject()`。
- 影响：调用方的 Future 永远不完成，UI 永久停留在 loading 状态。
- 建议：补充 `return handler.next(response);`。

---

### 11. 上传头像 fire-and-forget 且触发 AsyncTimer 死锁

- 位置：`lib/feedback/network/feedback_service.dart:185`
- 作者：待 git blame 确认
- 问题：
  ```dart
  feedbackDio.post("user/avatar", formData: data);  // 未 await
  onSuccess();  // 请求未完成即回调
  ```
- 影响：(1) `onSuccess` 在请求实际完成前调用，上传失败时 UI 误以为成功；(2) 配合问题 7，在 `AsyncTimer.runRepeatChecked` 内直接返回（未 await body），导致 key `'avatar'` 被永久锁定。
- 建议：添加 `await`。

---

### 12. `CommonPreferences.cookies` getter null crash

- 位置：`lib/commons/preferences/common_prefs.dart:97-101`
- 作者：待 git blame 确认
- 问题：
  ```dart
  var jSessionId = 'J' + ((gSessionId.value.length > 0) ? ...)
  ```
  `gSessionId` 无默认值，未登录时 `.value` 为 null，`.length` 调用 crash。
- 影响：未登录状态下访问 cookies 属性直接崩溃。
- 建议：`gSessionId.value?.length ?? 0 > 0`。

---

### 13. `feedbackLastWeKo` 重复 key，论坛和失物招领互相覆盖

- 位置：`lib/commons/preferences/common_prefs.dart:52-54`
- 作者：待 git blame 确认
- 问题：
  ```dart
  static final feedbackLastWeCo = PrefsBean<String>('feedbackLastWeKo');            // 论坛
  static final feedbackLastLostAndFoundWeCo = PrefsBean<String>('feedbackLastWeKo'); // 失物招领
  ```
- 影响：两个功能模块的"已处理微口令"状态互相覆盖，导致某些微口令漏弹或重复弹窗。
- 建议：给失物招领独立的 key，如 `'feedbackLastLostWeKo'`，并做旧 key 迁移。

---

### 14. `_setValue` 静默丢弃 `List` / `List<CardBean>` 写入

- 位置：`lib/commons/preferences/common_prefs.dart:267-288`
- 作者：待 git blame 确认
- 问题：`_setValue` 只处理 `List<String>`、`String`、`bool`、`int`、`double`。以下字段写入被静默丢弃：
  - `accountUpgrade` (List, line 41)
  - `lafGetNum` (List, line 81)
  - `lafGetNumId` (List, line 82)
  - `displayedTool` (List\<CardBean\>, line 134)
  - `userTool` (List\<CardBean\>, line 152)
- 影响：首页工具栏自定义配置和 laf 联系人数据重启后丢失；`_getDefaultValue` 对此类泛型返回 null，读取时也可能触发类型错误。
- 建议：为 List 和对象列表增加 JSON 序列化/反序列化分支，并提供非空默认值。

---

### 15. `postsList` 更新非原子，并发监听可能看到不一致状态

- 位置：`lib/feedback/view/lake_home_page/lake_notifier.dart:241-248`
- 作者：待 git blame 确认
- 问题：`_posts` map 和 `_postsList` 分步更新，`notifyListeners()` 在两者之间调用。
- 影响：并发场景下监听者可能看到 posts map 已更新但 postsList 仍是旧值。
- 建议：在 `notifyListeners()` 之前一次性完成所有修改。

---

### 16. Token 刷新无互斥 / dedup 机制

- 位置：`lib/commons/token/laf_token_manager.dart:30-36`，`lib/commons/token/lake_token_manager.dart:30-34`
- 作者：待 git blame 确认
- 问题：`token` getter 发现过期后各自调用 `refreshToken()`，没有缓存 in-flight 的 Future。
- 影响：多个并发请求同时触发 refresh，发起多次网络请求，可能拿到不同 token。
- 建议：缓存 refresh Future，后续调用方复用同一 Future；或用 Mutex 串行化。

---

### 17. `response.data` 无类型守卫，`TypeError` 逃逸 catch

- 位置：`lib/commons/token/laf_token_manager.dart:46-49`，`lib/commons/token/lake_token_manager.dart:41-57`
- 作者：待 git blame 确认
- 问题：`response.data['result']` — `response.data` 是 `dynamic`，非 Map 时抛出 `TypeError`，它不是 `DioException` 子类，绕过 `on DioException catch`。
- 影响：未处理异常导致 token 刷新静默失败，用户可能进入认证异常状态。
- 建议：先检查 `response.data is Map`。

---

### 18. `_calculateStat` 字符串索引越界

- 位置：`lib/commons/network/classes_backend_service.dart:114-116`
- 作者：待 git blame 确认
- 问题：`semester[5]` 对 `semester.split('-').last` 的结果做索引访问，未检查长度。
- 影响：后端返回非标准学期格式时 crash。
- 建议：添加长度检查。

---

### 19. `getFavouriteIds()` 缺少 try/catch

- 位置：`lib/studyroom/model/studyroom_service.dart:71-79`
- 作者：待 git blame 确认
- 问题：整个方法正文无异常保护，与同文件其他方法风格不一致。
- 影响：API 失败时异常直接传播到 UI 层。
- 建议：添加 try/catch 和错误处理。

---

### 20. `loadedCampus` 在 building 加载完成前就设为 true

- 位置：`lib/studyroom/model/studyroom_provider.dart:49-57`
- 作者：待 git blame 确认
- 问题：`init()` 中 `loadedCampus = true` 在 `forEach` 发起 building 异步加载之前就设置。
  ```dart
  loadedCampus = true;        // 提前设为 true
  notifyListeners();
  _campusList.forEach((campus) async {  // fire-and-forget
    final buildings = await StudyroomService.getBuildingList(campus.id);
    ...
  });
  ```
- 影响：UI 检查 `loadedCampus` 后使用 `buildings`，可能拿到空数据。
- 建议：在所有 building 加载完成后再设置 `loadedCampus = true`；或改为 `await Future.forEach`。

---

### 21. 发帖上传图片后提前清除，验证失败时图片丢失

- 位置：`lib/feedback/view/new_post_page.dart:86`
- 作者：待 git blame 确认
- 问题：
  ```dart
  dataModel.images.clear();  // 先清除
  if (dataModel.check) { ... }  // 再验证
  ```
- 影响：图片上传成功但表单验证失败时，用户需重新选择图片。
- 建议：验证通过后再清除。

---

### 22. `history_widget` async gap 后使用已销毁 context

- 位置：`lib/xiaotian/view/widget/history_widget.dart:22-46`
- 作者：待 git blame 确认
- 问题：`onTap` 先 `Navigator.pop()` 关闭 drawer，然后 `await` 两个网络请求，再访问 `context.read<>()`。如果网络请求失败 `isLoading(false)` 永不调用。
- 影响：widget 可能已销毁导致 crash；异常时 UI 永久卡在 loading 状态。
- 建议：添加 `mounted` 检查；loading 状态修改放在 try/finally 中。

---

### 23. 多处 `setState` 无 `mounted` 检查

- 位置：
  - `lib/main.dart:246` — `didChangeMetrics` 中 setState
  - `lib/main.dart:249-252` — `_onBrightnessChanged` 400ms 延迟后使用 context 和 setState
  - `lib/feedback/view/lake_home_page/normal_sub_page.dart:117` — async refresh 完成后
  - `lib/feedback/view/post_detail_page.dart:236` — async callback 中
- 作者：待 git blame 确认
- 影响：widget 销毁后 setState 抛出异常。
- 建议：所有 await/Delayed/Timer 回调后调用 setState 前检查 `mounted`。

---

### 24. 平台通道调用未处理错误

- 位置：`lib/main.dart:272`
- 作者：待 git blame 确认
- 问题：`_messageChannel.invokeMethod<Map>("getLastEvent").then(...)` 无 `.catchError`。
- 影响：原生平台通道调用失败时异常未处理。
- 建议：添加 `.catchError` 或使用 try/catch 包裹 await。

---

### 25. `onPlatformBrightnessChanged` 回调未在 dispose 中移除

- 位置：`lib/main.dart:230-231`
- 作者：待 git blame 确认
- 问题：`initState` 中赋值 `SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged`，但 `dispose` 未恢复。
- 影响：widget 销毁后系统亮度变化触发回调，使用失效 context 导致 crash。
- 建议：dispose 中将回调恢复为 null 或原始值。

---

### 26. `KeyPair.copyWith` 调用歧义构造函数

- 位置：`lib/commons/network/cas_service.dart:60-67`
- 作者：待 git blame 确认
- 问题：`KeyPair` 有一个命名构造函数 `KeyPair.CasService(...)`，而 `copyWith` 调用 `CasService(key: ..., iv: ...)`。类 `CasService` 也存在于同一文件（line 154）。Dart 可能解析到错误的构造函数。
- 影响：可能返回错误类型实例。
- 建议：重命名构造函数避免与类名冲突，如 `KeyPair.fromAesParts(...)`。

---

### 27. `_getIdentity` force-unwrap nullable header

- 位置：`lib/commons/network/classes_service.dart:191`
- 作者：待 git blame 确认
- 问题：`ret.headers.value('location')!` — 302 响应可能缺少 Location header。
- 影响：特定 CAS 重定向场景下 crash。
- 建议：使用 `?? ''` 或 null 检查。

---

### 28. `_initializeIfNeeded` fire-and-forget

- 位置：`lib/feedback/view/lake_home_page/lake_notifier.dart:313`
- 作者：待 git blame 确认
- 问题：`initFestivalList()` 是 async，但调用处未 await。getter 返回时数据可能仍为空。
- 影响：节日弹窗列表数据不完整。
- 建议：添加 await 或改为同步初始化后再返回。

---

### 29. `session=0` 导致数组越界

- 位置：`lib/studyroom/model/studyroom_provider.dart:25-26`
- 作者：待 git blame 确认
- 问题：`session == -1 ? null : SessionIndexUtil.periods[session - 1]` — session 无下限验证，设为 0 时访问 `periods[-1]`。
- 影响：`RangeError` crash。
- 建议：添加 session 范围验证 `session > 0`。

---

### 30. `initSchedule()` 不清空 schedule map 导致数据累计

- 位置：`lib/studyroom/view/page/classroom_detail_page.dart:188`
- 作者：steven12138（`91624e95` 2024-01-20）
- 问题：每次 `initSchedule()` 不清空 `schedule`，直接追加。配合问题 5（在 build 中调用），数据持续累加。
- 影响：schedule 数据无限膨胀，内存占用增大。
- 建议：调用时先 `schedule.clear()`。

---

### 31. `FocusNode` / `TextEditingController` / `ScrollController` 未 dispose — 多处

- 位置：
  - `lib/schedule/view/edit_bottom_sheet.dart:29` — `_focusNode` (FocusNode)
  - `lib/schedule/view/edit_bottom_sheet.dart:28` — `_inputSerial` (ValueNotifier)
  - `lib/schedule/view/week_select_widget.dart:39` — ScrollController (build 内创建)
  - `lib/schedule/view/edit_widgets.dart:341,423` — FixedExtentScrollController
  - `lib/feedback/view/post_detail_page.dart:1988` — SearchableDropdownDialog (FocusNode + TextEditingController)
  - `lib/feedback/view/components/normal_comment_card.dart:831` — AdminPopUp (TextEditingController)
  - `lib/schedule/view/wpy_exam_widget.dart:16` — ScrollController (StatelessWidget 字段)
- 作者：待 git blame 确认
- 影响：controller 泄漏，内存增长，监听器残留。
- 建议：在对应 State 的 `dispose` 中统一释放；StatelessWidget 中不应持有需要 dispose 的对象。

---

### 32. `_getDefaultValue` 对 `List`/`List<CardBean>` 返回 null

- 位置：`lib/commons/preferences/common_prefs.dart:292-299`
- 作者：待 git blame 确认
- 问题：
  ```dart
  if (T == List<String>) return <String>[];
  return null;  // List / List<CardBean> 走这里
  ```
- 影响：配合问题 14，读取此类预存值时返回 null，而字段类型为非空，可能触发类型错误。
- 建议：增加对应分支返回空列表，或统一改为可空类型并在 UI 层处理。

---

### 33. `xiaotian_page` 使用 `context.read` 而非 `context.watch`

- 位置：`lib/xiaotian/view/page/xiaotian_page.dart:78`
- 作者：待 git blame 确认
- 问题：`context.read<xiaotianChatState>().sessionId != '0'` 不会在 sessionId 变化时重建 widget。
- 影响：Suggestion widget 的可见性不响应 sessionId 变化，UI 状态陈旧。
- 建议：改为 `context.watch`，或用 `Consumer`/`Selector`。

---

### 34. 多处 `print()` 未移除，含敏感信息

- 位置：
  - `lib/commons/network/cas_service.dart:102`
  - `lib/commons/network/classes_service.dart:215-227`
  - `lib/commons/network/library_service.dart:105`（打印密码）
  - `lib/commons/network/library_service.dart:151, 157-158`
  - `lib/schedule/network/schdule_service.dart:147-149, 165-167`
- 作者：待 git blame 确认
- 影响：敏感信息（密码、token、课程数据）进入 logcat/系统日志；release build 中 print 可能被 zone 捕获进入内存日志（`debug_page.dart` 可查看）。
- 建议：全部替换为 `Logger.reportError` 或条件编译日志；密码相关立即删除。

---

### 35. AI 对话 `searchTime` 拼写错误

- 位置：`lib/xiaotian/model/xiaotian_state.dart:65`
- 作者：待 git blame 确认
- 问题：`clear()` 中将 `searchTime` 设为 `'onLimit'`（应为 `'noLimit'`）。
- 影响：下一次消息请求发送无效值给 API，可能导致查询异常。
- 建议：改为 `'noLimit'`，并考虑用 enum 替代字符串常量。

---

### 36. `clearTjuPrefs()` fire-and-forget async 竞态

- 位置：`lib/commons/preferences/common_prefs.dart:228-237`
- 作者：待 git blame 确认
- 问题：每个 `.clear()` 是 async 但未 await，与 `clearAllPrefs` 中的同步 `sharedPref.clear()` 产生竞态。
- 影响：非确定行为 — 无 await 的 remove 操作可能与 clear 交叠。
- 建议：改为 `await` 或批量 remove。

---

### 37. `EnvConfig` 测试/生产 URL 相同

- 位置：`lib/commons/environment/config.dart:13-14,21`
- 作者：待 git blame 确认
- 问题：`QNHDPIC` 和 `LAF` 的 isDevelop 三元表达式两端完全相同，`QNHDPIC` 为 HTTPS，`LAF` 为 HTTP 且是 IP 直连。
- 影响：测试环境与生产无隔离；`LAF` 生产使用 HTTP 明文（安全问题）。
- 建议：配置不同环境 URL；`LAF` 生产切 HTTPS。

---

### 38. 阿里云语音 API key 硬编码

- 位置：`lib/xiaotian/view/widget/chat_widget.dart:288-292`
- 作者：待 git blame 确认
- 问题：`accessKeyId`、`accessKeySecret`、`appKey` 编译进 APK。
- 影响：密钥可被逆向提取，存在滥用和账单风险。
- 建议：密钥从服务端或远程配置下发，不在客户端硬编码。

---

### 39. `dispose()` 标记 `async` 但无 `await`

- 位置：`lib/main.dart:203`
- 作者：待 git blame 确认
- 问题：`void dispose() async { ... }` 内无 await 语句，async 多余。Flutter 不会 await dispose 返回的 Future。
- 影响：如果后续在此添加 await，开发者可能误以为会被框架等待。
- 建议：删除 `async` 关键字。

---

### 40. `course_page.dart` 重复条件判断

- 位置：`lib/schedule/page/course_page.dart:60`
- 作者：待 git blame 确认
- 问题：`if (widget.pairs.isNotEmpty && widget.pairs.isNotEmpty)` 条件重复。
- 影响：无害，但表明可能有遗漏的检查。
- 建议：确认第二处是否应检查其他条件。

---

### 41. `CustomCourseService` mixin `AsyncTimer` 未使用

- 位置：`lib/schedule/network/custom_course_service.dart:24`
- 作者：待 git blame 确认
- 问题：`class CustomCourseService with AsyncTimer` 但 mixin 的防重入功能在该类中实际未使用（使用 `.then()` 链而非 `runRepeatChecked`）。
- 影响：无功能影响，但增加混淆。
- 建议：若无实际使用，移除 mixin。

---

### 42. 日志记录不一致

- 位置：`lib/main.dart:477`
- 作者：待 git blame 确认
- 问题：使用 `print` 而非项目统一的 `Logger.reportError`。
- 影响：该异常不会进入统一的日志体系和 debug 日志页。
- 建议：统一为 `Logger.reportError`。

---

## 其他值得排期的风险

- `lib/commons/token/token_manager.dart:8` 使用普通 `base64.decode` 解析 JWT payload，JWT 使用 base64url 且常省略 padding，部分合法 token 可能被判为失效导致频繁刷新。
- `lib/feedback/network/post.dart:546` 中 `AvatarBox.id` 是 `int` 但缺省值给 `''`，服务端缺字段时类型崩溃。
- `lib/lost_and_found/network/lost_and_found_post.dart:45` 模型解析无默认值或类型兜底，接口字段缺失直接崩溃。
- `lib/feedback/view/lake_home_page/lake_notifier.dart:117,150,161` 多处对 `lakePageControllers[currentTabId]` 和 `LakeUtil.lakePageControllers[index]` 使用 `!` 强制解包，tab 未初始化时 crash。
- `lib/feedback/view/post_detail_page.dart:1155,1159` 对 `launchKey.currentState!` 强制解包，child widget 未构建时 crash。
- `lib/feedback/view/components/normal_comment_card.dart:698` 对 `widget.comment.createAt!` 强制解包，但 `createAt` 可能为 null（API 返回空字符串时）。
- `lib/commons/channel/download/download_manager.dart:55-66` 对 static map 中的 listener/task 强制解包，原生回调携带错误 id 时 crash。
- 图片压缩循环 `j < 10` 内判断 `if (j == 10)` 永远不可达（`lib/feedback/view/post_detail_page.dart:1501` 等 3 处），压缩超过上限的图片无法被拦截。

---

## 建议修复顺序

1. **P0 优先**：问题 1（Dio crash）、5/6（studyroom crash/请求风暴）、7（AsyncTimer 死锁）、10（请求挂起）、2（cookie 覆盖）
2. **P1**：问题 12/13/14（preferences 数据丢失）、16/17（token 刷新竞态）、3/4（错误拦截/重试）
3. **P2**：问题 22/23（mounted 检查）、31（controller dispose）、21（发帖图片丢失）
4. **P3**：问题 36-42（代码质量和维护债），恢复 lint 规则逐步清理
