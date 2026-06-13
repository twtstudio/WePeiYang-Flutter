import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';

/// 日志查看页：直接复用 talker 自带查看器，
/// 自带按级别 / tag 过滤、搜索、复制、分享导出。
class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TalkerScreen(talker: appTalker);
  }
}
