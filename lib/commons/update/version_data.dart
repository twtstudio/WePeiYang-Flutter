// @dart = 2.12

class VersionData {
  final int success;
  final Info? info;

  VersionData._(this.success, this.info);

  factory VersionData.fromJson(Map<String, dynamic> json) {
    return VersionData._(
      json["success"] as int,
      json["info"] != null ? Info.fromJson(json["info"]) : null,
    );
  }
}

class Info {
  final Version release;
  final Version beta;

  Info._(this.release, this.beta);

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info._(
      Version.fromJson(json["release"]),
      Version.fromJson(json["beta"]),
    );
  }
}

class Production {
  final int id;
  final String name;
  final String description;
  final String slogan;
  final int picId;

  Production._(this.id, this.name, this.description, this.slogan, this.picId);

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production._(
      json["id"],
      json["name"],
      json["description"],
      json["slogan"],
      json["picId"],
    );
  }
}

class Version {
  final int id;
  final Production production;
  final int pid;
  final String content;
  final String time;
  final String version;
  final int versionCode;
  final String type;
  final String path;
  final int flutterFixCode;
  final String flutterFixSoFile;

  Version._(
    this.id,
    this.production,
    this.pid,
    this.content,
    this.time,
    this.version,
    this.versionCode,
    this.type,
    this.path,
    this.flutterFixCode,
    this.flutterFixSoFile,
  );

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version._(
      json["id"],
      Production.fromJson(json["production"]),
      json["pid"],
      json["content"],
      json["time"],
      json["version"],
      int.parse(json["versionCode"]),
      json["type"],
      json["path"],
      json['flutter_fix_code'] ?? 0,
      json['flutter_fix_so'] ?? ''
    );
  }
}

// {
//   "success": 1,
//   "info": {
//     "release": {
//       "id": 66,
//       "production": {
//         "id": 2,
//         "name": "微北洋",
//         "description": "汇聚校园重要资讯——校务专区、校园新闻、课表查看、GPA查询、党建系统……学习、娱乐、生活尽在掌握！",
//         "slogan": "学在北洋，一手掌握",
//         "picId": 37
//       },
//       "pid": 2,
//       "content": "v4.1.7\n- 新增短信登陆方式\n- 修复了疫情填报日期不准确的问题\n- 优化了应用内toast的逻辑",
//       "time": "2022-01-13 21:53:00",
//       "version": "v4.1.7",
//       "versionCode": "82",
//       "type": "android",
//       "path": "https://mobile-api.twt.edu.cn/storage/android_apk/gtW8HL1ZvbUHQT0Qym3xGDkbaRpzWg0q.apk"
//       "flutter_fix_code": 2,
//       "flutter_fix_so": "https://mobile-api.twt.edu.cn/storage/android_apk/2022-1-21-libapp.so"
//     },
//     "beta": {
//       "id": 72,
//       "production": {
//         "id": 2,
//         "name": "微北洋",
//         "description": "汇聚校园重要资讯——校务专区、校园新闻、课表查看、GPA查询、党建系统……学习、娱乐、生活尽在掌握！",
//         "slogan": "学在北洋，一手掌握",
//         "picId": 37
//       },
//       "pid": 2,
//       "content": "v4.1.7\n- 新增短信登陆方式\n- 修复了疫情填报日期不准确的问题\n- 优化了应用内toast的逻辑",
//       "time": "2022-01-13 21:53:49",
//       "version": "4.1.7",
//       "versionCode": "82",
//       "path": "https://mobile-api.twt.edu.cn/storage/android_apk_beta/gtW8HL1ZvbUHQT0Qym3xGDkbaRpzWg0q.apk",
//       "type": "android"
//       "flutter_fix_code": 2,
//       "flutter_fix_so": "https://mobile-api.twt.edu.cn/storage/android_apk/2022-1-21-libapp.so"
//     }
//   }
// }
