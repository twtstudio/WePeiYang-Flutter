// @dart = 2.12

import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';

class UpdateUtil {
  /// 今日是否还检查更新
  static bool get todayCheckAgain {
    final date = CommonPreferences.lastCheckUpdateTime.value;
    if (date == '') return false;
    final todayNotAgain =
        DateTime.tryParse(date)?.isSameDay(DateTime.now()) ?? false;
    return !todayNotAgain;
  }

  /// 设置今日不再检查更新
  static void setTodayNotCheckUpdate() {
    CommonPreferences.lastCheckUpdateTime.value = DateTime.now().toString();
  }

  /// 当前是测试版('beta')还是正式版('release')
  static ApkType get apkType {
    final type = CommonPreferences.apkType.value;
    if (type == 'release') {
      return ApkType.release;
    } else {
      return ApkType.beta;
    }
  }
}

enum ApkType { beta, release }
