// @dart = 2.12
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// release模式下在内存中存储log信息，debug模式下直接打印
class Logger {
  static List<String> logs = [];

  static void reportPrint(ZoneDelegate parent, Zone zone, String str) {
    String line = _getFormatTime() + ' | ' + str;
    if (kDebugMode) {
      parent.print(zone, line);
    } else {
      checkList();
      logs.add(line);
    }
  }

  static void reportError(Object error, StackTrace stack) {
    // 限制错误日志的长度
    final shortError =
        error.toString().substring(0, min(3000, error.toString().length));
    final shortStack =
        stack.toString().substring(0, min(3000, stack.toString().length));
    List<String> lines = [
      '----------------------------------------------------------------------',
      _getFormatTime() + ' | ' + shortError,
      shortStack,
      '----------------------------------------------------------------------'
    ];
    if (kDebugMode) {
      for (String line in lines) debugPrint(line);
    } else {
      checkList();
      logs.addAll(lines);
    }
  }

  /// 为了防止内存占用，控制log条数在200条以内
  static void checkList() {
    if (logs.length < 200) return;
    List<String> newList = []
      ..addAll(logs.getRange(logs.length - 50, logs.length));
    logs = newList;
  }

  // TODO 上传到服务器
  static Future<void> uploadLogs() async {}

  static String _getFormatTime() {
    var now = DateTime.now();
    return "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }
}
