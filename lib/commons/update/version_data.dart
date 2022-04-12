// @dart = 2.12

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
  });

  factory Version.fromJson(Map json) {
    return Version._(
      versionCode: json["versionCode"] ?? 0,
      version: json["version"] ?? '',
      content: json["content"] ?? '',
      isForced: json['isForced'] == 0 ? false : true,
      time: json["time"] ?? '',
      path: json["path"] ?? '',
      apkSize: json['apkSize'] ?? '',
      flutterFixCode: json['flutterFixCode'] ?? 0,
      flutterFixSo: json['flutterFixSo'] ?? '',
      flutterSoFileSize: json['fileSize'] ?? '',
    );
  }

  String get apkName {
    return "$version-${versionCode}-wby.apk";
  }

  bool operator <(Version? other) {
    return this.versionCode < (other?.versionCode ?? 0);
  }
}
