// @dart = 2.12

/// 动态打包配置
class EnvConfig {
  static void init() {
    QNHD = isDevelop
        // 测试服务器域名
        ? "https://www.zrzz.site:7013/"
        // 正式服务器域名
        : "https://qnhd.twt.edu.cn/";
    QNHDPIC = isDevelop
        // 测试服务器域名
        ? "https://www.zrzz.site:7015/"
        // 正式服务器域名
        : "https://qnhdpic.twt.edu.cn/";
  }

  static bool get isDevelop =>
      ENVIRONMENT == "DEVELOP";

  /// 测试版还是正式版 "RELEASE", "DEVELOP"（默认）, "ONLINE_TEST"
  static const ENVIRONMENT = String.fromEnvironment(
    "ENVIRONMENT",
    defaultValue: "ONLINE_TEST",
  );

  /// 青年湖底域名 "https://www.zrzz.site:7013/" (DEFAULT) 或 "https://qnhd.twt.edu.cn/"
  static late String QNHD;

  /// 青年湖底图片域名 "https://www.zrzz.site:7015/" (DEFAULT) 或 "https://qnhdpic.twt.edu.cn/"
  static late String QNHDPIC;
}
