import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:umeng_sdk/umeng_sdk.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/local/local_model.dart';
import 'package:we_pei_yang_flutter/commons/network/net_status_listener.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_providers.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/urgent_report/main_page.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/app_route_analysis.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';

/// 列一下各种东西的初始化：
/// 1. run app 之前：
/// [CommonPreferences.initPrefs]初始化shared_preferences, 初次调用为启动页的[build]函数之后
/// [NetStatusListener.init]初始化网络状态监听, 初次调用为WePeiYangApp的[build]函数
/// 2. App build 前后：
/// [HiveManager.init]初始化自习室数据库, 初次调用为HomePage的[build]函数之后
/// [UmengSdk.setPageCollectionModeManual]开启埋点

void main() async {
  /// 程序中的同步（sync）错误也交给zone处理
  FlutterError.onError = (FlutterErrorDetails details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await CommonPreferences.initPrefs();
    await NetStatusListener.init();
    runApp(WePeiYangApp());
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ));
    }
  }, (Object error, StackTrace stack) {
    /// 这里是处理所有 unhandled sync & async error 的地方
    Logger.reportError(error, stack);
  }, zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
    /// 覆盖zone中的所有[print]和[debugPrint]，统一日志格式
    Logger.reportPrint(parent, zone, line);
  }));
}

class WePeiYangApp extends StatefulWidget {
  static double screenWidth;
  static double screenHeight;
  static double paddingTop;

  /// 用于全局获取当前context
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();

  @override
  WePeiYangAppState createState() => WePeiYangAppState();
}

final messageChannel = MethodChannel('com.twt.service/message');

class IntentEvent {
  static const FeedbackPostPage = 1;
  static const WBYPushOnlyText = 2;
  static const WBYPushHtml = 3;
  static const SchedulePage = 4;
  static const NoSuchEvent = -1;
}

var pageStack = <String>[];

class WePeiYangAppState extends State<WePeiYangApp>
    with WidgetsBindingObserver {

  @override
  void dispose() async {
    await HiveManager.instance.closeBoxes();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var baseContext =
          WePeiYangApp.navigatorState.currentState.overlay.context;
      var mediaQueryData = MediaQuery.of(baseContext);
      WePeiYangApp.screenWidth = mediaQueryData.size.width;
      WePeiYangApp.screenHeight = mediaQueryData.size.height;
      WePeiYangApp.paddingTop = mediaQueryData.padding.top;
      HiveManager.init();
      FeedbackService.getToken();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("WBYINTENT ${state.toString()}");
    if (state == AppLifecycleState.resumed) {
      checkEventList();
    }
  }

  checkEventList() async {
    var baseContext = WePeiYangApp.navigatorState.currentState.overlay.context;
    await messageChannel?.invokeMethod<Map>("getLastEvent")?.then((eventMap) {
      print("WBYINTENT ${eventMap.toString()}");
      switch (eventMap['event']) {
        case IntentEvent.FeedbackPostPage:
          // TODO: 传入id ,等更新完项目之后
          Navigator.pushNamed(baseContext, FeedbackRouter.detail);
          break;
        case IntentEvent.WBYPushOnlyText:
          String content = eventMap['data'];
          showDialog(content);
          break;
        case IntentEvent.WBYPushHtml:
          break;
        case IntentEvent.SchedulePage:
          print("IntentEvent.SchedulePage");
          if (!pageStack.contains(ScheduleRouter.schedule)) {
            Navigator.pushNamed(baseContext, ScheduleRouter.schedule);
          }
          break;
        default:
      }
    });
  }

  showDialog(String content) {
    if (content != null && content.isNotEmpty) {
      showMessageDialog(
        WePeiYangApp.navigatorState.currentState.overlay.context,
        content,
      );
    } else {
      throw PlatformException(
          code: 'error', message: '失败', details: 'content is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    UmengSdk.setPageCollectionModeManual();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GPANotifier()),
        ChangeNotifierProvider(create: (context) => ScheduleNotifier()),
        ChangeNotifierProvider(create: (context) => LocaleModel()),
        ...loungeProviders,
        ChangeNotifierProvider(create: (context) => FeedbackNotifier()),
        ChangeNotifierProvider(
          create: (context) {
            var messageProvider = MessageProvider()..refreshFeedbackCount();
            messageChannel
              ..setMethodCallHandler((call) async {
                switch (call.method) {
                  case 'refreshFeedbackMessageCount':
                    await messageProvider.refreshFeedbackCount();
                    return "success";
                    break;
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '微北洋',
          navigatorKey: WePeiYangApp.navigatorState,
          onGenerateRoute: RouterManager.create,
          navigatorObservers: [AppRouteAnalysis(),PageStackObserver()],
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeListResolutionCallback: (List<Locale> preferredLocales,
              Iterable<Locale> supportedLocales) {
            var supportedLanguages =
                supportedLocales.map((e) => e.languageCode).toList();
            var preferredLanguages =
                preferredLocales.map((e) => e.languageCode).toList();
            var availableLanguages = preferredLanguages
                .where((element) => supportedLanguages.contains(element))
                .toList();
            return Locale(availableLanguages.first);
          },
          locale: localModel.locale(),
          home: StartUpWidget(),
          builder: (context, child) => GestureDetector(
            onTapDown: (TapDownDetails details) {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus.unfocus();
              }
            },
            child: child,
          ),
        );
      }),
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
    // TODO 合并
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(systemNavigationBarColor: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image(
            fit: BoxFit.contain,
            image: AssetImage('assets/images/splash_screen.png')),
      ),
      constraints: BoxConstraints.expand(),
    );
  }

  void _autoLogin(BuildContext context) {
    var prefs = CommonPreferences();

    /// 这里是为了在修改课程表和gpa的逻辑之后，旧的缓存不会影响新版本逻辑
    if (prefs.updateTime.value != "20210906") {
      prefs.updateTime.value = "20210906";
      prefs.clearTjuPrefs();
      prefs.clearUserPrefs();
      Navigator.pushReplacementNamed(context, AuthRouter.login);
      return;
    }
    /// 读取gpa和课程表的缓存
    Provider.of<ScheduleNotifier>(context, listen: false).readPref();
    Provider.of<GPANotifier>(context, listen: false).readPref();
    if (!prefs.isLogin.value ||
        prefs.account.value == "" ||
        prefs.password.value == "") {
      /// 既然没登陆过就多看会启动页吧
      Future.delayed(Duration(seconds: 1)).then(
          (_) => Navigator.pushReplacementNamed(context, AuthRouter.login));
    } else {
      /// 如果登陆过的话，短暂显示启动页后尝试自动登录，无论成功与否都进入主页
      Future.delayed(Duration(milliseconds: 500)).then(
        (_) => AuthService.login(
          prefs.account.value,
          prefs.password.value,
          onResult: (_) {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
          onFailure: (_) {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
        ),
      );
    }
  }
}

class PageStackObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      pageStack.add(route.settings.name);
    }
    print("pageStack:didPush ${pageStack.toString()}");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      pageStack.remove(route.settings.name);
    }
    print("pageStack:didPop ${pageStack.toString()}");
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      pageStack.remove(route.settings.name);
    }
    print("pageStack:didStartUserGesture ${pageStack.toString()}");

  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    if (oldRoute.settings.name != null) {
      pageStack.remove(oldRoute.settings.name);
    }
    if (newRoute.settings.name != null) {
      pageStack.add(newRoute.settings.name);
    }
    print("pageStack:didReplace ${pageStack.toString()}");

  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      pageStack.remove(route.settings.name);
    }
    print("pageStack:didRemove ${pageStack.toString()}");

  }
}
