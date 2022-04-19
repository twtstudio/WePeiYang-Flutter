// @dart = 2.12

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_item.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/path_util.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/update/update_service.dart';

class VersionData {
  final Version data;

  VersionData._({required this.data});

  factory VersionData.fromJson(Map json) {
    return VersionData._(
      data: Version.fromJson(json['data']),
    );
  }
}

class Version {
  final int versionCode;
  final String version;
  final String content;
  final bool isForced;
  final String time;
  final String path;
  final String apkSize;
  final int flutterFixCode;
  final String flutterFixSo;
  final String flutterSoFileSize;
  bool canHotFix;

  Version._({
    required this.versionCode,
    required this.version,
    required this.content,
    required this.isForced,
    required this.time,
    required this.path,
    required this.apkSize,
    required this.flutterFixCode,
    required this.flutterFixSo,
    required this.flutterSoFileSize,
    required this.canHotFix,
  });

  factory Version.fromJson(Map json) {
    final fixCode = json['flutterFixCode'] ?? 0;
    final canHotFix = (fixCode <= EnvConfig.VERSIONCODE) && !kDebugMode;
    return Version._(
      versionCode: json["versionCode"] ?? 0,
      version: json["version"] ?? '',
      content: json["content"] ?? '',
      isForced: json['isForced'] == 0 ? false : true,
      time: json["time"] ?? '',
      path: json["path"] ?? '',
      apkSize: json['apkSize'] ?? '',
      flutterFixCode: fixCode,
      flutterFixSo: json['flutterFixSo'] ?? '',
      flutterSoFileSize: json['fileSize'] ?? '',
      canHotFix: canHotFix,
    );
  }

  String get apkName {
    return "$versionCode-wby.apk";
  }

  String get zipName {
    return "$versionCode-libapp.zip";
  }

  String get soName {
    return "$versionCode-libapp.so";
  }

  String get apkPath {
    return DownloadType.apk.path + Platform.pathSeparator + apkName;
  }

  String get soPath {
    return PathUtil.filesDir.path +
        Platform.pathSeparator +
        DownloadType.hotfix.text +
        Platform.pathSeparator +
        soName;
  }

  String get apkUrl => "${UpdateService.BASEURL}downloadFile/1$path";

  String get zipUrl => "${UpdateService.BASEURL}downloadFile/1$flutterFixSo";

  bool operator <(Version? other) {
    return this.versionCode < (other?.versionCode ?? 0);
  }
}