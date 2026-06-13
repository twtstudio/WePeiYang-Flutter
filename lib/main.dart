import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show DiagnosticsTreeStyle, TextTreeRenderer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/xiaotian/model/xiaotian_state.dart';
import 'package:window_manager/window_manager.dart';

import 'auth/network/auth_service.dart';
import 'auth/network/message_service.dart';
import 'auth/network/splash_service.dart';
import 'auth/view/message/message_router.dart';
import 'commons/channel/local_setting/local_setting.dart';
import 'commons/channel/push/push_manager.dart';
import 'commons/channel/remote_config/remote_config_manager.dart';
import 'commons/environment/config.dart';
import 'commons/local/animation_provider.dart';
import 'commons/network/wpy_dio.dart';
import 'commons/preferences/common_prefs.dart';
import 'commons/themes/wpy_theme.dart';
import 'commons/update/update_manager.dart';
import 'commons/util/logger.dart';
import 'commons/util/navigator_observers.dart';
import 'commons/util/router_manager.dart';
import 'commons/util/storage_util.dart';
import 'commons/util/text_util.dart';
import 'commons/util/toast_provider.dart';
import 'feedback/model/feedback_providers.dart';
import 'feedback/network/post.dart';
import 'gpa/model/gpa_notifier.dart';
import 'lost_and_found/module/lost_and_found_providers.dart';
import 'message/model/message_provider.dart';
import 'schedule/model/course_provider.dart';
import 'schedule/model/exam_provider.dart';
import 'schedule/schedule_providers.dart';

/// 应用入口
final _entry = WePeiYangApp();

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    /// 初始化环境变量
    EnvConfig.init();
    await StorageUtil.init();

    /// 高刷
    if (Platform.isAndroid) {
      unawaited(FlutterDisplayMode.setHighRefreshRate().catchError((_) {
        print('[INFO]: This device isn\'t support high refresh rate');
      }));
    }

    /// 设置桌面端窗口适配, 依赖为 window_manager
    if (Platform.isWindows) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = WindowOptions(
        minimumSize: Size(640, 400),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }

    /// 初始化sharedPreference
    await CommonPreferences.init();

    /// 初始化Connectivity
    NetStatusListener.init();

    /// 初始化高德API 暂时干掉 之后重新启用
    // await AmapLocation.instance.updatePrivacyAgree(true);
    // await AmapLocation.instance.updatePrivacyShow(true);
    // await AmapLocation.instance
    //     .init(iosKey: '02b9aee6190b4afe20b0ddd7ec0eb374');

    WpyTheme.init();

    /// 设置哪天微北洋全部变灰
    var now = DateTime.now().toLocal();
    var importantDates = [
      DateTime(now.year, 5, 12),
      DateTime(now.year, 12, 13),
    ];
    bool isSpecialDate = importantDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);

    if (isSpecialDate) {
      runApp(
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.color),
          child: _entry,
        ),
      );
    } else {
      runApp(_entry);
    }

    /// 设置沉浸式状态栏
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ));

    /// 修改debugPrint
    debugPrint = (message, {wrapWidth}) => print(message);

    /// 程序中的同步（sync）错误交给zone处理
    FlutterError.onError = (FlutterErrorDetails details) async {
      // 生成错误信息
      String text = TextTreeRenderer(
              wrapWidth: FlutterError.wrapWidth,
              wrapWidthProperties: FlutterError.wrapWidth,
              maxDescendentsTruncatableNode: 5)
          .render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.flat))
          .trimRight();
      Zone.current.handleUncaughtError(text, details.stack ?? StackTrace.empty);
    };
  }, (Object error, StackTrace stack) {
    /// 这里是处理所有 unhandled sync & async error 的地方
    Logger.reportError(error, stack);
  }, zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
    /// 覆盖zone中的所有[print]，统一日志格式
    Logger.reportPrint(parent, zone, line);
  }));
}

String _shortcutActionType = "";
String _shortcutResumeActionType = "";

String? _routeForShortcutAction(String actionType) {
  return switch (actionType) {
    "com.twt.service.courses" => ScheduleRouter.course,
    "com.twt.service.qr" => HomeRouter.casQR,
    _ => null,
  };
}

//iOS快捷操作
Future<void> _listenForShortcutActions() async {
  const methodChannel = MethodChannel('com.twt.service/shortcutItem');
  // Dart端的方法监听
  methodChannel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'onShortcutAction':
        _shortcutActionType = call.arguments;
        _shortcutResumeActionType = call.arguments;
        break;
      default:
        print('No action for ${call.method}');
    }
  });
}

final _messageChannel = MethodChannel('com.twt.service/message');
final _pushChannel = MethodChannel('com.twt.service/push');

class IntentEvent {
  static const FeedbackPostPage = 1;
  static const FeedbackSummaryPage = 2;
  static const WBYMailBox = 3;
  static const SchedulePage = 4;
  static const UpdateDialog = 5;
  static const EntryQrPage = 6;
  static const NoSuchEvent = -1;
}

class WePeiYangApp extends StatefulWidget {
  static late double screenWidth;
  static late double screenHeight;

  /// 用于全局获取当前context
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();

  @override
  WePeiYangAppState createState() => WePeiYangAppState();
}

class WePeiYangAppState extends State<WePeiYangApp>
    with WidgetsBindingObserver {
  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var baseContext =
          WePeiYangApp.navigatorState.currentState?.overlay?.context ?? context;
      var mediaQueryData = MediaQuery.of(baseContext);
      WePeiYangApp.screenWidth = mediaQueryData.size.width;
      WePeiYangApp.screenHeight = mediaQueryData.size.height;
      // 判断屏幕状态
      bool isInnerScreen =
          (mediaQueryData.size.height / mediaQueryData.size.width) < 1.4;
      TextUtil.updateScreenState(isInnerScreen);

      WbyFontLoader.initFonts();
      ToastProvider.init(baseContext);
      TextUtil.init(baseContext);
      if (CommonPreferences.token.value != '') {
        LakeTokenManager().refreshToken();
      }
    });
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        _onBrightnessChanged;
    _listenForShortcutActions();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    var mediaQueryData = MediaQuery.of(context);

    bool isInnerScreen =
        (mediaQueryData.size.height / mediaQueryData.size.width) < 1.4;
    TextUtil.updateScreenState(isInnerScreen);
    setState(() {});
  }

  void _onBrightnessChanged() async {
    await Future.delayed(Duration(milliseconds: 400));
    if (!mounted) return;
    WpyTheme.updateAutoDarkTheme(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _listenForShortcutActions();
      final shortcutRoute = _routeForShortcutAction(_shortcutResumeActionType);
      if (shortcutRoute != null) {
        WePeiYangApp.navigatorState.currentState?.pushNamed(shortcutRoute);
        _shortcutResumeActionType = "";
      }
      checkEventList();
      WpyTheme.updateAutoDarkTheme(context);
    }
  }

  checkEventList() async {
    if (Platform.isIOS) return;
    var baseContext =
        WePeiYangApp.navigatorState.currentState?.overlay?.context ?? context;
    await _messageChannel.invokeMethod<Map>("getLastEvent").then((eventMap) {
      if (eventMap == null) {
        return;
      }
      switch (eventMap['event']) {
        case IntentEvent.FeedbackPostPage:
          Navigator.pushNamed(
            baseContext,
            FeedbackRouter.detail,
            arguments: Post.nullExceptId(eventMap['data']),
          );
          break;
        case IntentEvent.FeedbackSummaryPage:
          Navigator.pushNamed(baseContext, FeedbackRouter.summary);
          break;
        case IntentEvent.WBYMailBox:
          final data = eventMap['data'] as Map;
          Navigator.pushNamed(
            baseContext,
            MessageRouter.mailPage,
            arguments: UserMail.fromJson(data),
          );
          break;
        case IntentEvent.SchedulePage:
          if (!PageStackObserver.pageStack.contains(ScheduleRouter.course)) {
            Navigator.pushNamed(baseContext, ScheduleRouter.course);
          }
          break;
        case IntentEvent.UpdateDialog:
          // final data = eventMap['data'] as Map;
          // final versionCode = data['versionCode'] ?? 0;
          // final fixCode = data['fixCode'] ?? 0;
          // final url = data['url'] ?? "";
          // TODO
          break;
        case IntentEvent.EntryQrPage:
          if (!PageStackObserver.pageStack.contains(HomeRouter.casQR)) {
            Navigator.pushNamed(baseContext, HomeRouter.casQR);
          }
          break;
        default:
      }
    });
  }

  showDialog(String content) {
    if (content.isNotEmpty) {
      showMessageDialog(
        WePeiYangApp.navigatorState.currentState?.overlay?.context ?? context,
        content,
      );
    } else {
      throw PlatformException(
          code: 'error', message: '失败', details: 'content is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => RemoteConfig()..getRemoteConfig()),
        ChangeNotifierProvider(create: (_) => GPANotifier()),
        ChangeNotifierProvider(create: (_) => PushManager()),
        ChangeNotifierProvider(create: (_) => UpdateManager()),
        ChangeNotifierProvider(create: (_) => AnimationProvider()),
        ChangeNotifierProvider(create: (_) => xiaotianChatState()),
        ...scheduleProviders,
        ...studyroomProviders,
        ...feedbackProviders,
        ...lostAndFoundProviders,
        ChangeNotifierProvider(
          create: (context) {
            var messageProvider = MessageProvider()..refreshFeedbackCount();
            _pushChannel
              ..setMethodCallHandler((call) async {
                switch (call.method) {
                  case 'refreshFeedbackMessageCount':
                    await messageProvider.refreshFeedbackCount();
                    return "success";
                  case 'showMessageDialogOnlyText':
                    String content = call.arguments['data'];
                    showDialog(content);
                    break;
                }
              });
            return messageProvider;
          },
        ),
      ],
      child: Builder(builder: (context) {
        //TODO:每年春节都判断一次
        // if(!CommonPreferences.happenSpring.value) {
        //   globalTheme.value = RedScheme();
        //   CommonPreferences.happenSpring.value = true;
        // }

        return ListenableBuilder(
            listenable: globalTheme,
            builder: (context, _) {
              return WpyTheme(
                themeData: globalTheme.value,
                child: ScreenUtilInit(
                    key: ValueKey(1),
                    designSize: const Size(390, 844),
                    useInheritedMediaQuery: true,
                    minTextAdapt: true,
                    child: SplashScreen(),
                    builder: ((context, child) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        color: WpyTheme.of(context).primary,
                        theme: ThemeData(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            brightness: WpyTheme.of(context).brightness,
                            primaryColor: WpyTheme.of(context).primary,
                            switchTheme: SwitchThemeData(
                              thumbColor: WidgetStateProperty.all(
                                  WpyTheme.of(context).primary),
                              trackColor: WidgetStateProperty.all(
                                  WpyTheme.of(context).primary),
                              trackOutlineWidth: WidgetStateProperty.all(1),
                              trackOutlineColor: WidgetStateProperty.all(
                                  WpyTheme.of(context)
                                      .get(WpyColorKey.oldHintColor)),
                            )),
                        title: '微北洋',
                        navigatorKey: WePeiYangApp.navigatorState,
                        onGenerateRoute: RouterManager.create,
                        navigatorObservers: [
                          AppRouteAnalysis(),
                          PageStackObserver(),
                          FlutterSmartDialog.observer
                        ],
                        home: child,
                        // builder: (context, child) => Overlay(
                        //   initialEntries: [
                        //     if (child != null) ...[
                        //       OverlayEntry(
                        //         builder: (context) => child,
                        //       ),
                        //     ],
                        //   ],
                        // ),
                        builder: FlutterSmartDialog.init(builder: _builder),
                        // builder: FToastBuilder(),
                      );
                    })),
              );
            });
      }),
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    // 点击空白区域取消TextField焦点
    return GestureDetector(
      child: child,
      onTapUp: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }
}

/// 启动页Widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// 远程开屏图地址；为空时显示本地默认 logo。
  String? _remoteUrl;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appInitProcess();
      _loadSplashIcon();
    });
  }

  /// 远程开屏图：复用 haitang 的 banner 接口，取第一张 picUrl。
  /// 拉不到 / 未配置 / 网络环境不可达（如校园网外）都属预期内 ——
  /// 静默保留本地默认图，不上报、不阻塞启动。
  Future<void> _loadSplashIcon() async {
    try {
      final banners =
          await SplashService.getBanner().timeout(const Duration(seconds: 3));
      if (!mounted || banners.isEmpty) return;

      final url = banners.first.picUrl.trim();
      if (url.isEmpty) return;

      // 先把网络图预缓存好再切换，避免开屏先闪一下占位图。
      await precacheImage(CachedNetworkImageProvider(url), context);
      if (!mounted) return;
      setState(() => _remoteUrl = url);
    } catch (_) {
      // 忽略：保持本地默认开屏图。
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = WpyTheme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    final Widget content;
    if (_remoteUrl != null) {
      // 远程开屏图：整屏铺满，保留原图配色（不做主题着色）。
      content = WpyPic(
        _remoteUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        withHolder: false,
      );
    } else {
      // 本地默认 logo：居中、随主题色着色。
      final asset = isDarkMode
          ? 'assets/images/splash_screen_dark.png'
          : 'assets/images/splash_screen.png';
      content = Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: ColoredIcon(asset, color: WpyTheme.of(context).primary),
        ),
      );
    }

    // 本地图 → 远程图之间用淡入过渡，配合上面的预缓存，切换不闪。
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(_remoteUrl ?? 'local'),
        color: backgroundColor,
        constraints: const BoxConstraints.expand(),
        child: content,
      ),
    );
  }

  void _handleLaunchShortcut() {
    final route = _routeForShortcutAction(_shortcutActionType);
    if (route == null) return;
    _shortcutActionType = "";
    _shortcutResumeActionType = "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WePeiYangApp.navigatorState.currentState?.pushNamed(route);
    });
  }

  void _navigateHome() {
    final didNavigate = _navigateOnce(
      (navigator) =>
          navigator.pushNamedAndRemoveUntil(HomeRouter.home, (route) => false),
    );
    if (didNavigate && Platform.isIOS) _handleLaunchShortcut();
  }

  void _navigateLogin() {
    _navigateOnce(
        (navigator) => navigator.pushReplacementNamed(AuthRouter.login));
  }

  bool _navigateOnce(void Function(NavigatorState navigator) navigate) {
    if (!mounted || _hasNavigated) return false;
    final navigator = WePeiYangApp.navigatorState.currentState;
    if (navigator == null) return false;
    _hasNavigated = true;
    navigate(navigator);
    return true;
  }

  Future<void> _appInitProcess() async {
    // 检查更新
    context.read<UpdateManager>().checkUpdate();

    // 恢复截屏和亮度默认值，这两句代码不能放在更早的地方
    LocalSetting.changeSecurity(false);

    /// 这里是为了在修改课程表和gpa的逻辑之后，旧的缓存不会影响新版本逻辑
    if (CommonPreferences.updateTime.value == "") {
      CommonPreferences.updateTime.value = "20221019";
    } else if (CommonPreferences.updateTime.value != "20221019") {
      CommonPreferences.clearAllPrefs();
      _navigateLogin();
      return;
    }

    /// 读取gpa、考表、课程表的缓存
    context.read<GPANotifier>().readPref();
    context.read<ExamProvider>().readPref();
    context.read<CourseProvider>().readPref();

    /// 如果登录过，尝试刷新token
    if (CommonPreferences.isLogin.value &&
        CommonPreferences.token.value != '') {
      await Future.delayed(Duration.zero);
      if (!mounted || _hasNavigated) return;
      AuthService.getInfo(
        onSuccess: _navigateHome,
        onFailure: (_) {
          if (CommonPreferences.account.value != '' &&
              CommonPreferences.password.value != '') {
            /// 如果存过账密，尝试用账密刷新token，无论成功与否均进入主页
            AuthService.pwLogin(CommonPreferences.account.value,
                CommonPreferences.password.value,
                onResult: (_) {}, onFailure: (_) {});
          }
          _navigateHome();
        },
      );
    } else {
      /// 没登录过的话，多看一会的启动页再跳转到登录页
      await Future.delayed(const Duration(seconds: 1));
      _navigateLogin();
    }
  }
}
