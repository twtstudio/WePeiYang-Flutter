import 'package:path/path.dart' as p;
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class UpdateDio extends DioAbstract {}

final updateDio = UpdateDio();

class UpdateService with AsyncTimer {
  static const BASEURL = 'https://upgrade.twt.edu.cn/androidupdate/';

  /// 获取最新版本，如果失败则返回null
  static Future<AndroidVersion?> get latestAndroidVersion async {
    try {
      var code = UpdateUtil.apkType == ApkType.release ? 1 : 0;
      var response = await updateDio.get(p.join(BASEURL, "check/$code"));
      return VersionData.fromJson(response.data).data;
    } catch (error, stack) {
      Logger.reportError(error, stack);
      return null;
    }
  }

  /// 获取最新版本，如果失败则返回null
  static Future<IOSVersion?> get latestIOSVersion async {
    try {
      var response =
          await updateDio.get("https://upgrade.twt.edu.cn/iosupdate/check");
      return VersionData.fromJson(response.data, iOS: true).data;
    } catch (error, stack) {
      Logger.reportError(error, stack);
      return null;
    }
  }
}
