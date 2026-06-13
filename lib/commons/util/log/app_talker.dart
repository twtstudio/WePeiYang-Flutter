import 'package:talker_flutter/talker_flutter.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';

import 'file_log_output.dart';

/// 全局 Talker 单例：所有日志、网络拦截、未捕获错误最终都汇聚到这里。
///
/// - 控制台输出仅在测试 / debug 版开启（正式版静默，避免性能与泄露）。
/// - history 保留在内存供查看器使用。
/// - 通过 [_FileTalkerObserver] 同步落地到本地文件（重启不丢、可导出）。
final Talker appTalker = TalkerFlutter.init(
  settings: TalkerSettings(
    useConsoleLogs: EnvConfig.isTest,
    useHistory: true,
    maxHistoryItems: 1000,
  ),
  observer: _FileTalkerObserver(),
);

/// 在 app 启动早期调用一次，初始化文件持久化。
Future<void> initAppLogger() => FileLogOutput.instance.init();

/// 把每条日志 / 错误 / 异常同步写入本地文件。
class _FileTalkerObserver extends TalkerObserver {
  @override
  void onLog(TalkerData log) =>
      FileLogOutput.instance.write(log.generateTextMessage());

  @override
  void onError(TalkerError err) =>
      FileLogOutput.instance.write(err.generateTextMessage());

  @override
  void onException(TalkerException err) =>
      FileLogOutput.instance.write(err.generateTextMessage());
}
