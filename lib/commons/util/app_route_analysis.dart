import 'package:flutter/material.dart';
import 'package:umeng_sdk/umeng_sdk.dart';

/// 友盟SDK统计用户路径
class AppRouteAnalysis extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute?.settings?.name != null) {
      UmengSdk.onPageEnd(previousRoute.settings.name);
    }
    if (route.settings.name != null) {
      UmengSdk.onPageStart(route.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      UmengSdk.onPageEnd(route.settings.name);
    }
    if (previousRoute?.settings?.name != null) {
      UmengSdk.onPageStart(previousRoute.settings.name);
    }
  }
}
