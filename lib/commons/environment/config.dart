// @dart = 2.12

import 'package:flutter/foundation.dart';

/// 动态打包配置
class EnvConfig {
  static void init() {
    QNHD = _QNHD != ''
        ? _QNHD
        : isDevelop
            ? "https://www.zrzz.site:7013/"
            : "https://qnhd.twt.edu.cn/";
    QNHDPIC = _QNHDPIC != ''
        ? _QNHDPIC
        : isDevelop
            ? "https://www.zrzz.site:7015/"
            : "https://qnhdpic.twt.edu.cn/";
  }

  /// 应用获取渠道 "HUAWEI", "XIAOMI", "OPPO", "VIVO", "DOWNLOAD", "OTHER"（默认）
  static const CHANNEL = String.fromEnvironment(
    "CHANNEL",
    defaultValue: "OTHER",
  );

  static bool get isDevelop =>
      ENVIRONMENT == "DEVELOP" || ENVIRONMENT == "ONLINE_TEST" || kDebugMode;

  /// 测试版还是正式版 "RELEASE", "DEVELOP"（默认）, "ONLINE_TEST"
  static const ENVIRONMENT = String.fromEnvironment(
    "ENVIRONMENT",
    defaultValue: "DEVELOP",
  );

  static const _QNHD = String.fromEnvironment('QNHD');

  static const _QNHDPIC = String.fromEnvironment('QNHDPIC');

  /// 青年湖底域名 "https://www.zrzz.site:7013/" (DEFAULT) 或 "https://qnhd.twt.edu.cn/"
  static late String QNHD;

  /// 青年湖底图片域名 "https://www.zrzz.site:7015/" (DEFAULT) 或 "https://qnhdpic.twt.edu.cn/"
  static late String QNHDPIC;
}
