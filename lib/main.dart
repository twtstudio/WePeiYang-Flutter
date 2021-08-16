import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:umeng_sdk/umeng_sdk.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/local/local_model.dart';
import 'package:we_pei_yang_flutter/commons/new_network/net_status_listener.dart';
import 'package:we_pei_yang_flutter/commons/update/update.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/http_util.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_providers.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';
import 'package:we_pei_yang_flutter/message/message_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/urgent_report/main_page.dart';

import 'commons/preferences/common_prefs.dart';
import 'commons/util/app_analysis.dart';
import 'gpa/model/gpa_notifier.dart';
import 'home/model/home_model.dart';
import 'message/user_mails_page.dart';

/// 在醒目的地方写一下对android文件夹的修改
/// 1. 在 AndroidManifest.xml 中添加了 android:screenOrientation ="portrait" 强制竖屏
/// 2. 添加外部存储读写和摄像头使用权限，[MultiImagePicker]所需
/// 3. 在资源文件夹添加完成图片选择图标

/// 列一下各种东西的初始化：
/// 1. run app 之前：
/// [CommonPreferences.initPrefs]初始化shared_preferences, 初次调用为启动页的[build]函数
/// [NetStatusListener.init]初始化网络状态监听，初次调用为WePeiYangApp的[initState]函数
/// ...
/// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CommonPreferences.initPrefs();
  await NetStatusListener.init();
  runApp(WePeiYangApp());
  if (Platform.isAndroid) {
    /// !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    /// 这个逻辑之后重写，有大隐患，和他的实现有关
    /// !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
    ));
  }
}

// 全局捕获异常，想好了一半了
/*
FlutterError.onError = (FlutterErrorDetails details) async {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await CommonPreferences.initPrefs();
    runApp(WePeiYangApp());
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ));
    }
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
 */

class WePeiYangApp extends StatefulWidget {
  /// 用于全局获取当前context
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();

  @override
  _WePeiYangAppState createState() => _WePeiYangAppState();
}

final messageChannel = MethodChannel('com.twt.service/message');

class _WePeiYangAppState extends State<WePeiYangApp> {
  @override
  void dispose() async {
    await HiveManager.instance.closeBoxes();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var baseContext =
          WePeiYangApp.navigatorState.currentState.overlay.context;
      UpdateManager.init(context: baseContext);
      GlobalModel().init(baseContext);
      await HiveManager.init();
      // 获取feedback的token
      await getToken(onSuccess: (token) {
        // assert(() {
        //   ToastProvider.success("token : $token");
        // }());
      }, onFailure: () {
        // assert(() {
        //   ToastProvider.error("获取token失败");
        // }());
      });
      var id = await messageChannel?.invokeMethod<int>("getPostId");
      if (id != -1) {
        await Navigator.pushNamed(baseContext, FeedbackRouter.detail);
      }
    });
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
            var baseContext =
                WePeiYangApp.navigatorState.currentState.overlay.context;
            messageChannel
              ..setMethodCallHandler((call) async {
                switch (call.method) {
                  case 'showMessage':
                    // print("*****************************************");
                    String content = await call.arguments;
                    // print(
                    //     "*******************$content + ${content != null && content.isNotEmpty}*****************");
                    if (content != null && content.isNotEmpty) {
                      // print("????");
                      await showMessageDialog(
                        baseContext,
                        content,
                      );
                      assert(() {
                        ToastProvider.success(content);
                      }());
                      return "success";
                    } else {
                      throw PlatformException(
                          code: 'error',
                          message: '失败',
                          details: 'content is null');
                    }
                    break;
                  case 'getReply':
                    // print(
                    //     "******************  get reply ***********************");
                    // print(
                    //     "******************  get reply ***********************");
                    // print(
                    //     "******************  get reply ***********************");
                    await Navigator.pushNamed(
                        baseContext, FeedbackRouter.detail);
                    return "success";
                    break;
                  case 'refreshFeedbackMessageCount':
                    log("refreshFeedbackMessageCount");
                    await messageProvider.refreshFeedbackCount();
                    return "success";
                    break;
                  default:
                  // print("???????????????????????????????????????????");
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
          title: 'WePeiYangFlutter',
          navigatorKey: WePeiYangApp.navigatorState,
          // theme: ThemeData(fontFamily: 'WeiYuanYaHei'),
          onGenerateRoute: RouterManager.create,
          navigatorObservers: [AppAnalysis()],
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _autoLogin(context);
    });
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
    /// 读取gpa和课程表的缓存
    Provider.of<ScheduleNotifier>(context, listen: false).readPref();
    Provider.of<GPANotifier>(context, listen: false).readPref();
    var prefs = CommonPreferences();
    if (!prefs.isLogin.value ||
        prefs.account.value == "" ||
        prefs.password.value == "") {
      /// 既然没登陆过就多看会启动页吧
      Future.delayed(Duration(seconds: 1)).then(
          (_) => Navigator.pushReplacementNamed(context, AuthRouter.login));
    } else {
      /// 稍微显示一会启动页，不然它的意义是什么555
      /// 用缓存中的数据自动登录，无论失败与否都进入主页
      Future.delayed(Duration(milliseconds: 500)).then(
        (_) => login(
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
