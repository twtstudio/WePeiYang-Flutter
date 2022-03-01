// @dart = 2.12
import 'dart:async';
import 'dart:math';

import 'package:package_info/package_info.dart';

class UpdateUtil {
  static int? _versionCode;

  static int _flutterCodeVersion = 88;

  /// 获取应用版本号，由于有热更新的存在，所以每次打包时请无比修改 _flutterCodeVersion
  /// 如果获取不到安卓端的 versionCode，则默认返回 _flutterCodeVersion
  static FutureOr<int> getVersionCode() async {
    if (_versionCode == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final _androidCodeVersion =
          int.tryParse(packageInfo.buildNumber) ?? _flutterCodeVersion;
      _versionCode = max(_androidCodeVersion, _flutterCodeVersion);
    }
    return _versionCode!;
  }

  static Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version;
    if (!version.startsWith('v')) version = 'v' + version;
    return version;
  }
}
