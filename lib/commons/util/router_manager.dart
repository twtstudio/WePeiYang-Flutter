import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/test/test_router.dart';
import 'package:we_pei_yang_flutter/auth/auth_router.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/gpa/gpa_router.dart';
import 'package:we_pei_yang_flutter/home/home_router.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_router.dart';
import 'package:we_pei_yang_flutter/schedule/schedule_router.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_router.dart';

export 'package:we_pei_yang_flutter/auth/auth_router.dart';
export 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
export 'package:we_pei_yang_flutter/gpa/gpa_router.dart';
export 'package:we_pei_yang_flutter/home/home_router.dart';
export 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
export 'package:we_pei_yang_flutter/schedule/schedule_router.dart';
export 'package:we_pei_yang_flutter/urgent_report/report_router.dart';

/// WePeiYangApp Route统一管理
class RouterManager {
  static final Map<String, Widget Function(Object arguments)> _routers = {};

  static Route<dynamic> create(RouteSettings settings) {
    /// 这里添加其他模块的routers
    if (_routers.isEmpty) {
      _routers.addAll(AuthRouter.routers);
      _routers.addAll(FeedbackRouter.routers);
      _routers.addAll(GPARouter.routers);
      _routers.addAll(HomeRouter.routers);
      _routers.addAll(LoungeRouter.routers);
      _routers.addAll(ScheduleRouter.routers);
      _routers.addAll(ReportRouter.routers);
      _routers.addAll(MessageRouter.routers);
      _routers.addAll(TestRouter.routers);
    }
    return MaterialPageRoute(
        builder: (ctx) => _routers[settings.name](settings.arguments),
        settings: settings);
  }
}
