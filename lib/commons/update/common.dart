import 'dart:io';

import 'package:install_plugin/install_plugin.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class CommonUtils {
  CommonUtils._internal();

  static String getTargetSize(double kbSize) {
    if (kbSize <= 0) {
      return "";
    } else if (kbSize < 1024) {
      return "${kbSize.toStringAsFixed(1)}KiB";
    } else if (kbSize < 1048576) {
      return "${(kbSize / 1024).toStringAsFixed(1)}MiB";
    } else {
      return "${(kbSize / 1048576).toStringAsFixed(1)}GiB";
    }
  }

  ///根据更新信息获取apk安装文件
  static Future<File> getApkFileWithTemporaryName(Version version) async {
    String path = await getApkPath(version);
    return File(path);
  }

  static Future<String> getApkPath(Version version) async {
    String apkName = getApkNameByDownloadUrl(version.path);
    Directory dir = await getExternalStorageDirectory();
    var dirPath = dir.path;
    try {
      var matchDirs = dir
          .listSync()
          .where((element) => element.path.endsWith(version.version))
          .toList();
      // debugPrint(matchDirs.length.toString());
      var children = (matchDirs.first as Directory).listSync();
      // debugPrint(children.first.absolute.path);
      if (children.length > 0 && children.first.absolute.path.endsWith('apk')) {
        return children.first.absolute.path;
      } else {
        return "$dirPath/${version.version}/$apkName.temporary";
      }
    } catch (e) {
      // debugPrint(e.toString());
      return "$dirPath/${version.version}/$apkName.temporary";
    }
  }

  ///根据下载地址获取文件名
  static String getApkNameByDownloadUrl(String downloadUrl) {
    if (downloadUrl.isEmpty) {
      return "temp_$currentTimeMillis.apk";
    } else {
      String appName = downloadUrl.substring(downloadUrl.lastIndexOf("/") + 1);
      if (!appName.endsWith(".apk")) {
        appName = "temp_$currentTimeMillis.apk";
      }
      return appName;
    }
  }

  static int get currentTimeMillis => DateTime.now().millisecondsSinceEpoch;

  ///获取应用包信息
  static Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  ///获取应用版本号
  static Future<String> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  static Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  ///获取应用包名
  static Future<String> getPackageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  /// 安装apk
  static void installAPP(String uri) async {
    if (Platform.isAndroid) {
      String packageName = await CommonUtils.getPackageName();
      InstallPlugin.installApk(uri, packageName);
    } else {
      // InstallPlugin.gotoAppStore(uri);
    }
  }
}
