import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:umeng_sdk/umeng_sdk.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/local/local_model.dart';
import 'package:wei_pei_yang_demo/commons/new_network/net_status_listener.dart';
import 'package:wei_pei_yang_demo/commons/update/update.dart';
import 'package:wei_pei_yang_demo/commons/util/router_manager.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/feedback/model/feedback_notifier.dart';
import 'package:wei_pei_yang_demo/feedback/util/http_util.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/lounge/lounge_providers.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/message/message_provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

import 'commons/preferences/common_prefs.dart';
import 'commons/util/app_analysis.dart';
import 'gpa/model/gpa_notifier.dart';
import 'home/model/home_model.dart';

/// 在醒目的地方写一下对android文件夹的修改
/// 1. 在 AndroidManifest.xml 中添加了 android:screenOrientation ="portrait" 强制竖屏
/// 2. 添加外部存储读写和摄像头使用权限，[MultiImagePicker]所需
/// 3. 在资源文件夹添加完成图片选择图标

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(debug: true);
  await CommonPreferences.initPrefs();
  await NetStatusListener.init();
  runApp(WeiPeiYangApp());
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
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
    // await FlutterDownloader.initialize(debug: true);
    await CommonPreferences.initPrefs();
    runApp(WeiPeiYangApp());
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ));
    }
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
 */

class WeiPeiYangApp extends StatefulWidget {
  /// 用于全局获取当前context
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();

  @override
  _WeiPeiYangAppState createState() => _WeiPeiYangAppState();
}

final messageChannel = MethodChannel('com.example.wei_pei_yang_demo/message');

class _WeiPeiYangAppState extends State<WeiPeiYangApp> {
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
          WeiPeiYangApp.navigatorState.currentState.overlay.context;
      UpdateManager.init(context: baseContext);
      GlobalModel().init(baseContext);
      messageChannel
        ..setMethodCallHandler((call) async {
          switch (call.method) {
            case 'showMessage':
              print("*****************************************");
              String content = await call.arguments;
              print(
                  "*******************${content} + ${content != null && content.isNotEmpty}*****************");
              if (content != null && content.isNotEmpty) {
                print("????");
                await showMessageDialog(
                  baseContext,
                  content,
                );
                ToastProvider.success(content);
                return "success";
              } else {
                throw PlatformException(
                    code: 'error', message: '失败', details: 'content is null');
              }
              break;
            case 'getReply':
              print("******************  get reply ***********************");
              print("******************  get reply ***********************");
              print("******************  get reply ***********************");
              await Navigator.pushNamed(baseContext, FeedbackRouter.detail);
              return "success";
              break;
            default:
              print("???????????????????????????????????????????");
          }
        });
      await HiveManager.init();
      await getToken(onSuccess: (token) {
        ToastProvider.success("token : $token");
      }, onFailure: () {
        ToastProvider.error("获取token失败");
      });
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
            create: (context) => MessageProvider()..refreshFeedbackCount())
      ],
      child: Consumer<LocaleModel>(builder: (context, localModel, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WeiPeiYangDemo',
          navigatorKey: WeiPeiYangApp.navigatorState,
          // theme: ThemeData(fontFamily: 'Montserrat'),
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
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

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
