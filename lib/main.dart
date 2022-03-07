import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show DiagnosticsTreeStyle, TextTreeRenderer;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_service.dart';
import 'package:we_pei_yang_flutter/commons/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/local/local_model.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show NetStatusListener;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/navigator_observers.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_providers.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_notifier.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_providers.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';
import 'package:we_pei_yang_flutter/message/model/message_provider.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_router.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';

import 'commons/util/text_util.dart';

/// 列一下各种东西的初始化：
/// 1. run app 之前：
/// [CommonPreferences.initPrefs]初始化shared_preferences, 初次调用为启动页的[build]函数之后
/// [NetStatusListener.init]初始化网络状态监听, 初次调用为WePeiYangApp的[build]函数
/// 2. App build 前后：
/// [HiveManager.init]初始化自习室数据库, 初次调用为HomePage的[build]函数之后
/// 3. 用户登录时（调用AuthService.login），此时用户已同意隐私权先
/// [UmengSdk.setPageCollectionModeManual]开启埋点

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    /// 程序中的同步（sync）错误也交给zone处理
    FlutterError.onError = (FlutterErrorDetails details) async {
      /// 生成错误信息
      String text = TextTreeRenderer(
              wrapWidth: FlutterError.wrapWidth,
              wrapWidthProperties: FlutterError.wrapWidth,
              maxDescendentsTruncatableNode: 5)
          .render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.flat))
          .trimRight();
      Zone.current.handleUncaughtError(text, null);
    };
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
final pushChannel = MethodChannel('com.twt.service/push');

class IntentEvent {
  static const FeedbackPostPage = 1;
  static const WBYMailBox = 3;
  static const SchedulePage = 4;
  static const UpdateDialog = 5;
  static const NoSuchEvent = -1;
}

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
      FeedbackService.getToken(forceRefresh: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkEventList();
    }
  }

  checkEventList() async {
    var baseContext = WePeiYangApp.navigatorState.currentState.overlay.context;
    await messageChannel.invokeMethod<Map>("getLastEvent")?.then((eventMap) {
      debugPrint('resume -----------$eventMap--------- resume');
      switch (eventMap['event']) {
        case IntentEvent.FeedbackPostPage:
          Navigator.pushNamed(
            baseContext,
            FeedbackRouter.detail,
            arguments: Post.nullExceptId(eventMap['data']),
          );
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
          if (!PageStackObserver.pageStack.contains(ScheduleRouter.schedule)) {
            Navigator.pushNamed(baseContext, ScheduleRouter.schedule);
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GPANotifier()),
        ChangeNotifierProvider(create: (context) => ScheduleNotifier()),
        ChangeNotifierProvider(create: (context) => ExamNotifier()),
        ChangeNotifierProvider(create: (context) => LocaleModel()),
        ChangeNotifierProvider(create: (_) => UpdateManager()),
        ChangeNotifierProvider(create: (_) => PushManager()),
        ...loungeProviders,
        ...feedbackProviders,
        ChangeNotifierProvider(
          create: (context) {
            var messageProvider = MessageProvider()..refreshFeedbackCount();
            pushChannel
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
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
          builder: FlutterSmartDialog.init(builder: _builder),
        );
      }),
    );
  }

  Widget _builder(BuildContext context, Widget child) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(390, 844),
        context: context,
        orientation: Orientation.portrait);
    TextUtil.init(context);
    return GestureDetector(
      child: child,
      onTapDown: (TapDownDetails details) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
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
    /// 这里是为了在修改课程表和gpa的逻辑之后，旧的缓存不会影响新版本逻辑
    if (CommonPreferences.updateTime.value != "20210906") {
      CommonPreferences.updateTime.value = "20210906";
      CommonPreferences.clearTjuPrefs();
      CommonPreferences.clearUserPrefs();
      Navigator.pushReplacementNamed(context, AuthRouter.login);
      return;
    }

    /// 读取gpa和课程表的缓存
    Provider.of<ScheduleNotifier>(context, listen: false).readPref();
    Provider.of<ExamNotifier>(context, listen: false).readPref();
    Provider.of<GPANotifier>(context, listen: false).readPref();

    /// 如果存过账号密码，优先用账密刷新token
    if (CommonPreferences.account.value != '' &&
        CommonPreferences.password.value != '') {
      Future.delayed(Duration(milliseconds: 500)).then((_) =>
          AuthService.pwLogin(
              CommonPreferences.account.value, CommonPreferences.password.value,
              onResult: (_) {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          }, onFailure: (_) {
            Navigator.pushNamedAndRemoveUntil(
                context, AuthRouter.login, (route) => false);
          }));
    } else if (CommonPreferences.isLogin.value &&
        CommonPreferences.token.value != '') {
      /// 如果是短信登陆的，尝试用token刷新
      Future.delayed(Duration(milliseconds: 500)).then(
        (_) => AuthService.getInfo(
          onSuccess: () {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
          onFailure: (_) {
            Navigator.pushNamedAndRemoveUntil(
                context, AuthRouter.login, (route) => false);
          },
        ),
      );
    } else {
      /// 没登陆过的话，多看一会的启动页再跳转到登录页
      Future.delayed(Duration(seconds: 1)).then(
          (_) => Navigator.pushReplacementNamed(context, AuthRouter.login));
    }
  }
}
