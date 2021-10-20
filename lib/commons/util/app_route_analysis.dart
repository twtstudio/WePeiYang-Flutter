import 'package:flutter/material.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

/// 友盟SDK统计用户路径
class AppRouteAnalysis extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute?.settings?.name != null) {
      UmengCommonSdk.onPageEnd(previousRoute.settings.name);
    }
    if (route.settings.name != null) {
      UmengCommonSdk.onPageStart(route.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings.name != null) {
      UmengCommonSdk.onPageEnd(route.settings.name);
    }
    if (previousRoute?.settings?.name != null) {
      UmengCommonSdk.onPageStart(previousRoute.settings.name);
    }
  }
}
