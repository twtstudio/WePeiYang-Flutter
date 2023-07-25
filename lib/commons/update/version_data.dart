import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_item.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/update/update_service.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';

class VersionData {
  final data;

  VersionData._({required this.data});

  factory VersionData.fromJson(Map json, {bool iOS = false}) {
    return VersionData._(
      data: iOS
          ? IOSVersion.fromJson(json['data'])
          : AndroidVersion.fromJson(json['data']),
    );
  }
}

class AndroidVersion {
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

  AndroidVersion._({
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

  factory AndroidVersion.fromJson(Map json) {
    final fixCode = json['flutterFixCode'] ?? 0;
    final canHotFix = (fixCode <= EnvConfig.VERSIONCODE) && !kDebugMode;
    return AndroidVersion._(
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
    return StorageUtil.filesDir.path +
        Platform.pathSeparator +
        DownloadType.hotfix.text +
        Platform.pathSeparator +
        soName;
  }

  String get apkUrl => "${UpdateService.BASEURL}downloadFile/$path";

  String get zipUrl => "${UpdateService.BASEURL}downloadFile/$flutterFixSo";

  bool operator <(AndroidVersion? other) {
    return this.versionCode < (other?.versionCode ?? 0);
  }
}

class IOSVersion {
  IOSVersion(
    this.versionCode,
    this.content,
    this.isForced,
    this.time,
    this.version,
  );

  final String versionCode;
  final String content;
  final bool isForced;
  final String time;
  final String version;

  factory IOSVersion.fromRawJson(String str) =>
      IOSVersion.fromJson(json.decode(str));

  factory IOSVersion.fromJson(Map<String, dynamic> json) => IOSVersion(
        json["versionCode"] == null ? null : json["versionCode"],
        json["content"] == null ? null : json["content"],
        json['isForced'] == 0 ? false : true,
        json["time"] == null ? null : json['time'],
        (json["version"] as String).substring(1),
      );
}
