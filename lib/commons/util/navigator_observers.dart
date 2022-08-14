// @dart = 2.12
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';

/// 友盟SDK统计用户路径
class AppRouteAnalysis extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) return;
    if (previousRoute?.settings.name != null) {
      UmengCommonSdk.onPageEnd(previousRoute!.settings.name!);
    }
    if (route.settings.name != null) {
      UmengCommonSdk.onPageStart(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) return;
    if (route.settings.name != null) {
      UmengCommonSdk.onPageEnd(route.settings.name!);
    }
    if (previousRoute?.settings.name != null) {
      UmengCommonSdk.onPageStart(previousRoute!.settings.name!);
    }
  }
}

class PageStackObserver extends NavigatorObserver {
  static var pageStack = <String>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pageStack.add(route.settings.name!);
    }
    print("pageStack:didPush ${pageStack.toString()}");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pageStack.remove(route.settings.name);
    }
    print("pageStack:didPop ${pageStack.toString()}");
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pageStack.remove(route.settings.name);
    }
    print("pageStack:didStartUserGesture ${pageStack.toString()}");
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute?.settings.name != null) {
      pageStack.remove(oldRoute!.settings.name);
    }
    if (newRoute?.settings.name != null) {
      pageStack.add(newRoute!.settings.name!);
    }
    print("pageStack:didReplace ${pageStack.toString()}");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      pageStack.remove(route.settings.name);
    }
    print("pageStack:didRemove ${pageStack.toString()}");
  }
}
