import 'app_talker.dart';

export 'app_talker.dart' show appTalker, initAppLogger;

/// 全局日志门面。业务代码统一用 [Log]，不要直接调用 talker。
///
/// ```dart
/// Log.i('用户进入自习室页面', tag: 'studyroom');
/// Log.e(e, stack, 'studyroom');   // 记录异常
/// ```
class Log {
  Log._();

  /// 调试细节（仅开发期关心）。
  static void d(Object? msg, {String? tag}) => appTalker.debug(_fmt(msg, tag));

  /// 普通信息。
  static void i(Object? msg, {String? tag}) => appTalker.info(_fmt(msg, tag));

  /// 警告：非致命但需要关注。
  static void w(Object? msg, {String? tag}) => appTalker.warning(_fmt(msg, tag));

  /// 记录错误 / 异常。[error] 可为异常对象或描述字符串。
  static void e(Object error, [StackTrace? stack, String? tag]) =>
      appTalker.handle(error, stack, tag);

  static String _fmt(Object? msg, String? tag) =>
      tag == null ? '$msg' : '[$tag] $msg';
}
