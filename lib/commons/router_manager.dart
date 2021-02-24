import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/auth/auth_router.dart';
import 'package:wei_pei_yang_demo/feedback/util/feedback_router.dart';
import 'package:wei_pei_yang_demo/gpa/gpa_router.dart';
import 'package:wei_pei_yang_demo/home/home_router.dart';
import 'package:wei_pei_yang_demo/lounge/lounge_router.dart';
import 'package:wei_pei_yang_demo/schedule/schedule_router.dart';

class RouterManager {
  static Map<String, Widget Function(Object arguments)> _routers = {};

  static Route<dynamic> create(RouteSettings settings) {
    /// 这里添加其他模块的routers
    if (_routers.length == 0) {
      _routers.addAll(HomeRouter.routers);
      _routers.addAll(GPARouter.routers);
      _routers.addAll(ScheduleRouter.routers);
      _routers.addAll(AuthRouter.routers);
      _routers.addAll(FeedbackRouter.routers);
      _routers.addAll(LoungeRouter.routers);
    }
    return MaterialPageRoute(
        builder: (ctx) => _routers[settings.name](settings.arguments));
  }
}
