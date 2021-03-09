import 'package:flutter/material.dart';
import 'package:umeng_sdk/umeng_sdk.dart';

class AppAnalysis extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      print("push route ${route.settings.name} detected");
      UmengSdk.onPageStart(route.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      print("pop route ${route.settings.name} detected");
      UmengSdk.onPageEnd(route.settings.name);
    }
  }
}