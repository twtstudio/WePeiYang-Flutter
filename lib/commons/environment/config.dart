// @dart = 2.12

/// 动态打包配置
class EnvConfig {
  /// 应用获取渠道 "HUAWEI", "XIAOMI", "OPPO", "VIVO", "DOWNLOAD", "OTHER"（默认）
  static const CHANNEL = String.fromEnvironment(
    "CHANNEL",
    defaultValue: "OTHER",
  );

  static bool get isDevelop => ENVIRONMENT == "DEVELOP";

  /// 测试版还是正式版 "RELEASE", "DEVELOP"（默认）
  static const ENVIRONMENT = String.fromEnvironment(
    "ENVIRONMENT",
    defaultValue: "DEVELOP",
  );

  /// 青年湖底域名（默认为天外天服务器）
  static const QNHD = String.fromEnvironment(
    "QNHD",
    defaultValue: "https://qnhd.twt.edu.cn/",
  );

  /// 青年湖底图片域名（默认为天外天服务器）
  static const QNHDPIC = String.fromEnvironment(
    "QNHDPIC",
    defaultValue: "https://qnhdpic.twt.edu.cn/",
  );
}
