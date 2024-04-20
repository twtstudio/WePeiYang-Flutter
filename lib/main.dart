import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show DiagnosticsTreeStyle, PlatformDispatcher, TextTreeRenderer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'auth/network/auth_service.dart';
import 'auth/network/message_service.dart';
import 'auth/view/message/message_router.dart';
import 'commons/channel/local_setting/local_setting.dart';
import 'commons/channel/push/push_manager.dart';
import 'commons/channel/remote_config/remote_config_manager.dart';
import 'commons/channel/statistics/umeng_statistics.dart';
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
    StorageUtil.init();

    /// 高刷
    try {
      if (Platform.isAndroid) await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      print('[INFO]: This device isn\'t support high refresh rate');
    }

    /// 初始化友盟 TODO: fix this or remove this
    await UmengCommonSdk.initCommon();

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
    await NetStatusListener.init();

    /// 初始化高德API 暂时干掉 之后重新启用
    // await AmapLocation.instance.updatePrivacyAgree(true);
    // await AmapLocation.instance.updatePrivacyShow(true);
    // await AmapLocation.instance
    //     .init(iosKey: '02b9aee6190b4afe20b0ddd7ec0eb374');

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

    WpyTheme.init();

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

final _messageChannel = MethodChannel('com.twt.service/message');
final _pushChannel = MethodChannel('com.twt.service/push');

class IntentEvent {
  static const FeedbackPostPage = 1;
  static const FeedbackSummaryPage = 2;
  static const WBYMailBox = 3;
  static const SchedulePage = 4;
  static const UpdateDialog = 5;
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
      WbyFontLoader.initFonts();
      ToastProvider.init(baseContext);
      TextUtil.init(baseContext);
      if (CommonPreferences.token.value != '') {
        LakeTokenManager().refreshToken();
      }
    });
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        _onBrightnessChanged;
  }

  void _onBrightnessChanged() async =>
      await Future.delayed(Duration(milliseconds: 400)).then(
        (_) => WpyTheme.updateAutoDarkTheme(context),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkEventList();
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
        ChangeNotifierProvider(create: (_) => RemoteConfig()),
        ChangeNotifierProvider(create: (_) => GPANotifier()),
        ChangeNotifierProvider(create: (_) => PushManager()),
        ChangeNotifierProvider(create: (_) => UpdateManager()),
        ChangeNotifierProvider(create: (_) => AnimationProvider()),
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
        // 获取友盟在线参数
        context.read<RemoteConfig>().getRemoteConfig();

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
                    child: StartUpWidget(),
                    builder: ((context, child) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        color: WpyTheme.of(context).primary,
                        theme: ThemeData(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            brightness: WpyTheme.of(context).brightness,
                            primaryColor: WpyTheme.of(context).primary,
                            useMaterial3: true,
                            switchTheme: SwitchThemeData(
                              thumbColor: MaterialStateProperty.all(
                                  WpyTheme.of(context).primary),
                              trackColor: MaterialStateProperty.all(
                                  WpyTheme.of(context).primary),
                              trackOutlineWidth: MaterialStateProperty.all(1),
                              trackOutlineColor: MaterialStateProperty.all(
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
class StartUpWidget extends StatefulWidget {
  @override
  _StartUpWidgetState createState() => _StartUpWidgetState();
}

class _StartUpWidgetState extends State<StartUpWidget> {
  late var _isFoolDay = now.month == 4 && now.day == 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appInitProcess(context);
    });
  }

  var now = DateTime.now().toLocal();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = WpyTheme.of(context).brightness == Brightness.dark;

    // 根据当前主题和日期选择背景颜色
    Color backgroundColor =
        isDarkMode && !_isFoolDay ? Colors.black : Colors.white;

    // 根据条件选择图标路径
    String iconPath = isDarkMode
        ? 'assets/images/splash_screen_dark.png'
        : 'assets/images/splash_screen.png';

    // 根据条件选择图标颜色
    Color? iconColor = _isFoolDay
        ? null // 愚人节 使用图片自带颜色
        : WpyTheme.of(context).primary; // 适配主题

    // 构建splash界面
    final splash = Container(
      color: backgroundColor,
      padding: EdgeInsets.all(30),
      constraints: BoxConstraints.expand(),
      child: Center(
        child: ColoredIcon(
          iconPath,
          color: iconColor,
        ),
      ),
    );

    // 否则直接splash screen
    return splash;
  }

  void _appInitProcess(BuildContext context) {
    /// 初始化友盟
    UmengCommonSdk.initCommon();

    // 检查更新
    context.read<UpdateManager>().checkUpdate();

    // 恢复截屏和亮度默认值，这两句代码不能放在更早的地方
    LocalSetting.changeSecurity(false);

    /// 这里是为了在修改课程表和gpa的逻辑之后，旧的缓存不会影响新版本逻辑
    if (CommonPreferences.updateTime.value == "") {
      CommonPreferences.updateTime.value = "20221019";
    } else if (CommonPreferences.updateTime.value != "20221019") {
      CommonPreferences.clearAllPrefs();
      Navigator.pushReplacementNamed(context, AuthRouter.login);
      return;
    }

    /// 读取gpa、考表、课程表的缓存
    context.read<GPANotifier>().readPref();
    context.read<ExamProvider>().readPref();
    context.read<CourseProvider>().readPref();

    /// 如果登陆过，尝试刷新token
    if (CommonPreferences.isLogin.value &&
        CommonPreferences.token.value != '') {
      Future.delayed(
        _isFoolDay
            ? Duration(seconds: 2) // fool splash screen time control
            : Duration(milliseconds: 0),
      ).then(
        (_) => AuthService.getInfo(
          onSuccess: () {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
          onFailure: (_) {
            if (CommonPreferences.account.value != '' &&
                CommonPreferences.password.value != '') {
              /// 如果存过账密，尝试用账密刷新token，无论成功与否均进入主页
              AuthService.pwLogin(CommonPreferences.account.value,
                  CommonPreferences.password.value,
                  onResult: (_) {}, onFailure: (_) {});
            }
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
        ),
      );
    } else {
      /// 没登陆过的话，多看一会的启动页再跳转到登录页
      Future.delayed(const Duration(seconds: 1)).then(
          (_) => Navigator.pushReplacementNamed(context, AuthRouter.login));
    }
  }
}
//一次gitcommit的演示