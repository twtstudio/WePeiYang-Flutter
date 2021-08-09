import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
import 'package:we_pei_yang_flutter/gpa/gpa_router.dart';
import 'package:we_pei_yang_flutter/home/home_router.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/schedule/schedule_router.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_router.dart';

export 'package:we_pei_yang_flutter/auth/auth_router.dart';
export 'package:we_pei_yang_flutter/feedback/util/feedback_router.dart';
export 'package:we_pei_yang_flutter/gpa/gpa_router.dart';
export 'package:we_pei_yang_flutter/home/home_router.dart';
export 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
export 'package:we_pei_yang_flutter/schedule/schedule_router.dart';
export 'package:we_pei_yang_flutter/urgent_report/report_router.dart';

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
      _routers.addAll(ReportRouter.routers);
    }
    return MaterialPageRoute(
        builder: (ctx) => _routers[settings.name](settings.arguments),
        settings: settings);
  }
}
