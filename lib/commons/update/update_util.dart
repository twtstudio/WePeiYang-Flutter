// @dart = 2.12
import 'dart:async';
import 'dart:math';

import 'package:package_info/package_info.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

class UpdateUtil {
  static int? _versionCode;

  /// 获取应用版本号，由于有热更新的存在，所以每次打包时请无比修改 _flutterCodeVersion
  /// 如果获取不到安卓端的 versionCode，则默认返回 _flutterCodeVersion
  static FutureOr<int> getVersionCode() async {
    if (_versionCode == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final _androidCodeVersion =
          int.tryParse(packageInfo.buildNumber) ?? EnvConfig.VERSIONCODE;
      _versionCode = max(_androidCodeVersion, EnvConfig.VERSIONCODE);
    }
    return _versionCode!;
  }

  /// 默认今日是否还弹出对话框
  static bool get todayShow {
    final date = CommonPreferences().todayShowUpdateAgain.value;
    final todayNotAgain =
        DateTime.tryParse(date)?.isTheSameDay(DateTime.now()) ?? false;
    if (todayNotAgain) {
      return false;
    } else {
      return true;
    }
  }

  /// 当前是测试版('beta')还是正式版('release')
  static ApkType get apkType {
    final type = CommonPreferences().apkType.value;
    if (type == 'release') {
      return ApkType.release;
    } else {
      return ApkType.beta;
    }
  }
}

enum ApkType { beta, release }