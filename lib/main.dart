import 'dart:async';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/foundation.dart'
    show DiagnosticsTreeStyle, TextTreeRenderer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';

import 'auth/network/auth_service.dart';
import 'auth/view/message/message_router.dart';
import 'auth/view/message/message_service.dart';
import 'commons/channel/local_setting/local_setting.dart';
import 'commons/channel/push/push_manager.dart';
import 'commons/channel/remote_config/remote_config_manager.dart';
import 'commons/channel/statistics/umeng_statistics.dart';
import 'commons/environment/config.dart';
import 'commons/local/local_model.dart';
import 'commons/network/wpy_dio.dart';
import 'commons/preferences/common_prefs.dart';
import 'commons/update/update_manager.dart';
import 'commons/util/logger.dart';
import 'commons/util/navigator_observers.dart';
import 'commons/util/router_manager.dart';
import 'commons/util/storage_util.dart';
import 'commons/util/text_util.dart';
import 'commons/util/toast_provider.dart';
import 'feedback/model/feedback_providers.dart';
import 'feedback/network/feedback_service.dart';
import 'feedback/network/post.dart';
import 'generated/l10n.dart';
import 'gpa/model/gpa_notifier.dart';
import 'message/model/message_provider.dart';
import 'schedule/model/course_provider.dart';
import 'schedule/model/exam_provider.dart';
import 'schedule/schedule_providers.dart';
import 'urgent_report/report_server.dart';

/// 应用入口
final _entry = WePeiYangApp();

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    /// 初始化环境变量
    EnvConfig.init();
    StorageUtil.init();

    /// 初始化友盟
    await UmengCommonSdk.initCommon();

    /// 初始化sharedPreference
    await CommonPreferences.init();

    /// 初始化Connectivity
    await NetStatusListener.init();

    /// 初始化高德API
    await AmapLocation.instance.updatePrivacyAgree(true);
    await AmapLocation.instance.updatePrivacyShow(true);
    await AmapLocation.instance
        .init(iosKey: '02b9aee6190b4afe20b0ddd7ec0eb374');

    /// 设置哪天微北洋全部变灰
    var now = DateTime.now().toLocal();
    if ((now.month == 5 && now.day == 12) ||
        (now.month == 12 && now.day == 13)) {
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
        statusBarBrightness: Brightness.light));

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
        FeedbackService.getToken(forceRefresh: true);
      }
    });
  }

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
        ChangeNotifierProvider(create: (_) => LocaleModel()),
        ChangeNotifierProvider(create: (_) => GPANotifier()),
        ChangeNotifierProvider(create: (_) => PushManager()),
        ChangeNotifierProvider(create: (_) => UpdateManager()),
        ...scheduleProviders,
        ...studyroomProviders,
        ...feedbackProviders,
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
        Provider.value(value: ReportDataModel()),
      ],
      child: Consumer<LocaleModel>(builder: (context, localModel, _) {
        // 获取友盟在线参数
        context.read<RemoteConfig>().getRemoteConfig();

        return ScreenUtilInit(
            designSize: const Size(390, 844),
            useInheritedMediaQuery: true,
            minTextAdapt: true,
            child: StartUpWidget(),
            builder: ((context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                title: '微北洋',
                navigatorKey: WePeiYangApp.navigatorState,
                onGenerateRoute: RouterManager.create,
                navigatorObservers: [
                  AppRouteAnalysis(),
                  PageStackObserver(),
                  FlutterSmartDialog.observer
                ],
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                localeListResolutionCallback: (List<Locale>? preferredLocales,
                    Iterable<Locale>? supportedLocales) {
                  var supportedLanguages =
                      supportedLocales?.map((e) => e.languageCode).toList() ??
                          [];
                  var preferredLanguages =
                      preferredLocales?.map((e) => e.languageCode).toList() ??
                          [];
                  var availableLanguages = preferredLanguages
                      .where((element) => supportedLanguages.contains(element))
                      .toList();
                  return Locale(availableLanguages.first);
                },
                locale: localModel.locale(),
                home: child,
                builder: FlutterSmartDialog.init(builder: _builder),
                // builder: FToastBuilder(),
              );
            }));
      }),
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    // 点击空白区域取消TextField焦点
    return GestureDetector(
      child: child,
      onTapDown: (TapDownDetails details) {
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLogin(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(30),
      child: Center(
        child: Image(
            fit: BoxFit.contain,
            image: AssetImage('assets/images/splash_screen.png')),
      ),
      constraints: BoxConstraints.expand(),
    );
  }

  void _autoLogin(BuildContext context) {
    /// 初始化友盟
    UmengCommonSdk.initCommon();

    // 检查更新
    context.read<UpdateManager>().checkUpdate();

    // 恢复截屏和亮度默认值，这两句代码不能放在更早的地方
    LocalSetting.changeSecurity(false);

    /// 这里是为了在修改课程表和gpa的逻辑之后，旧的缓存不会影响新版本逻辑
    if (CommonPreferences.updateTime.value != "20221019") {
      CommonPreferences.updateTime.value = "20221019";
      CommonPreferences.clearTjuPrefs();
      CommonPreferences.clearUserPrefs();
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
      Future.delayed(const Duration(milliseconds: 500)).then(
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
