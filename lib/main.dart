import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/auth/network/auth_service.dart';
import 'package:wei_pei_yang_demo/commons/local/local_model.dart';
import 'package:wei_pei_yang_demo/commons/router_manager.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/favourite_model.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

import 'commons/preferences/common_prefs.dart';
import 'feedback/model/feedback_notifier.dart';
import 'gpa/model/gpa_notifier.dart';
import 'home/model/home_model.dart';

/// 在醒目的地方写一下对android文件夹的修改
/// 1. 在 AndroidManifest.xml 中添加了 android:screenOrientation ="portrait" 强制竖屏
/// 2. 添加外部存储读写和摄像头使用权限，[MultiImagePicker]所需
/// 3. 在资源文件夹添加完成图片选择图标

void main() async =>
    await _initializeApp().then((_) => runApp(WeiPeiYangApp()));

// 全局捕获异常，还没想好
//runZoned(
//       () async => await _initializeApp()
//           .then((_) => runApp(WeiPeiYangApp()))
//           .catchError((e) {
//         print(e);
//       }),
//       zoneSpecification: ZoneSpecification(
//         print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
//           print(line);
//         },
//       ),
//     );

Future<void> _initializeApp() async {
  await HiveManager.init();
  await CommonPreferences.initPrefs();
  if (Platform.isAndroid) {
    var dark = SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarDividerColor: null,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(dark);
  }
}

class WeiPeiYangApp extends StatefulWidget {
  /// 用于全局获取当前context
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();

  @override
  _WeiPeiYangAppState createState() => _WeiPeiYangAppState();
}

class _WeiPeiYangAppState extends State<WeiPeiYangApp> {
  @override
  void dispose() async {
    await HiveManager.instance.closeBoxes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GPANotifier()),
        ChangeNotifierProvider(create: (context) => ScheduleNotifier()),
        ChangeNotifierProvider(create: (context) => SRTimeModel()..setTime()),
        ChangeNotifierProvider(create: (context) => SRFavouriteModel()),
        ChangeNotifierProvider(create: (context) => LocaleModel()),
        ChangeNotifierProvider(create: (context) => FeedbackNotifier()),
      ],
      child: Consumer<LocaleModel>(builder: (context, localModel, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WeiPeiYangDemo',
          navigatorKey: WeiPeiYangApp.navigatorState,
          theme: ThemeData(
              // fontFamily: 'Montserrat'
              ),
          onGenerateRoute: RouterManager.create,
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
class StartUpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    GlobalModel().screenWidth = width;
    GlobalModel().screenHeight = height;

    _autoLogin(context);

    return ConstrainedBox(
      child: Image(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/splash_screen.png')),
      constraints: BoxConstraints.expand(),
    );
  }

  void _autoLogin(BuildContext context) async {
    /// 初始化sharedPrefs
    await CommonPreferences.initPrefs();

    /// 读取gpa和课程表的缓存
    Provider.of<ScheduleNotifier>(context, listen: false).readPref();
    Provider.of<GPANotifier>(context, listen: false).readPref();
    var prefs = CommonPreferences();
    if (!prefs.isLogin.value ||
        prefs.account.value == "" ||
        prefs.password.value == "") {
      /// 既然没登陆过就多看会启动页吧
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

    /// 稍微显示一会启动页，不然它的意义是什么555
    else {
      // TODO 为啥会请求两次呢 迷
      Timer(Duration(milliseconds: 500), () {
        /// 用缓存中的数据自动登录，失败则仍跳转至login页面
        login(prefs.account.value, prefs.password.value, onSuccess: (_) {
          if (context != null)
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
        }, onFailure: (_) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        });
      });
    }
  }
}
