/// success : 1
/// info : {"release":{"id":15,"production":{"id":1,"name":"求实BBS","description":"天大自由的交友空间，毕业校友的聚集胜地，沟通校务的有效平台。","slogan":"结识天大人，畅议天下事","picId":5},"pid":1,"content":"本次更新 :  <br>1. 多账号登录缓存优化  <br>2. 修复论坛区点击闪退问题 <br>近期更新 :  <br>1. 帖子回复支持@用户 <br>2. 添加图片缓存, 网络缓存 <br>3. 优化使用体验, 修复已知bug","time":"2017-12-02 23:50:50","version":"1.6.2","versionCode":"15","type":"android","path":"https://mobile-api.twt.edu.cn/storage/android_apk/Cbcjm7fjpIxEuPLqsWkdpk1351GM8vIkEQMcqHXQ.apk"},"beta":{"id":33,"production":{"id":1,"name":"求实BBS","description":"天大自由的交友空间，毕业校友的聚集胜地，沟通校务的有效平台。","slogan":"结识天大人，畅议天下事","picId":5},"pid":1,"content":"","time":"2018-05-25 15:39:22","version":"3.2.7","versionCode":"27","path":"https://mobile-api.twt.edu.cn/storage/android_apk/k5FdPzEo8DcwMoxEcOZhW5KQXCd761yxiSAcJBTM.apk","type":"android"}}

class VersionData {
  int _success;
  Info _info;

  int get success => _success;

  Info get info => _info;

  VersionData({int success, Info info}) {
    _success = success;
    _info = info;
  }

  VersionData.fromJson(dynamic json) {
    _success = json["success"];
    _info = json["info"] != null ? Info.fromJson(json["info"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["success"] = _success;
    if (_info != null) {
      map["info"] = _info.toJson();
    }
    return map;
  }
}

/// release : {"id":15,"production":{"id":1,"name":"求实BBS","description":"天大自由的交友空间，毕业校友的聚集胜地，沟通校务的有效平台。","slogan":"结识天大人，畅议天下事","picId":5},"pid":1,"content":"本次更新 :  <br>1. 多账号登录缓存优化  <br>2. 修复论坛区点击闪退问题 <br>近期更新 :  <br>1. 帖子回复支持@用户 <br>2. 添加图片缓存, 网络缓存 <br>3. 优化使用体验, 修复已知bug","time":"2017-12-02 23:50:50","version":"1.6.2","versionCode":"15","type":"android","path":"https://mobile-api.twt.edu.cn/storage/android_apk/Cbcjm7fjpIxEuPLqsWkdpk1351GM8vIkEQMcqHXQ.apk"}
/// beta : {"id":33,"production":{"id":1,"name":"求实BBS","description":"天大自由的交友空间，毕业校友的聚集胜地，沟通校务的有效平台。","slogan":"结识天大人，畅议天下事","picId":5},"pid":1,"content":"","time":"2018-05-25 15:39:22","version":"3.2.7","versionCode":"27","path":"https://mobile-api.twt.edu.cn/storage/android_apk/k5FdPzEo8DcwMoxEcOZhW5KQXCd761yxiSAcJBTM.apk","type":"android"}

class Info {
  Version _release;
  Version _beta;

  Version get release => _release;

  Version get beta => _beta;

  Info({Version release, Version beta}) {
    _release = release;
    _beta = beta;
  }

  Info.fromJson(dynamic json) {
    _release =
        json["release"] != null ? Version.fromJson(json["release"]) : null;
    _beta = json["beta"] != null ? Version.fromJson(json["beta"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_release != null) {
      map["release"] = _release.toJson();
    }
    if (_beta != null) {
      map["beta"] = _beta.toJson();
    }
    return map;
  }
}

/// id : 1
/// name : "求实BBS"
/// description : "天大自由的交友空间，毕业校友的聚集胜地，沟通校务的有效平台。"
/// slogan : "结识天大人，畅议天下事"
/// picId : 5

class Production {
  int _id;
  String _name;
  String _description;
  String _slogan;
  int _picId;

  int get id => _id;

  String get name => _name;

  String get description => _description;

  String get slogan => _slogan;

  int get picId => _picId;

  Production(
      {int id, String name, String description, String slogan, int picId}) {
    _id = id;
    _name = name;
    _description = description;
    _slogan = slogan;
    _picId = picId;
  }

  Production.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _description = json["description"];
    _slogan = json["slogan"];
    _picId = json["picId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["description"] = _description;
    map["slogan"] = _slogan;
    map["picId"] = _picId;
    return map;
  }
}

/// id : 15
/// production : {"id":1,"name":"求实BBS","description":"天大自由的交友空间，毕业校友的聚集胜地，沟通校务的有效平台。","slogan":"结识天大人，畅议天下事","picId":5}
/// pid : 1
/// content : "本次更新 :  <br>1. 多账号登录缓存优化  <br>2. 修复论坛区点击闪退问题 <br>近期更新 :  <br>1. 帖子回复支持@用户 <br>2. 添加图片缓存, 网络缓存 <br>3. 优化使用体验, 修复已知bug"
/// time : "2017-12-02 23:50:50"
/// version : "1.6.2"
/// versionCode : "15"
/// type : "android"
/// path : "https://mobile-api.twt.edu.cn/storage/android_apk/Cbcjm7fjpIxEuPLqsWkdpk1351GM8vIkEQMcqHXQ.apk"

class Version {
  int _id;
  Production _production;
  int _pid;
  String _content;
  String _time;
  String _version;
  int _versionCode;
  String _type;
  String _path;

  int get id => _id;

  Production get production => _production;

  int get pid => _pid;

  String get content => _content;

  String get time => _time;

  String get version => _version;

  int get versionCode => _versionCode;

  String get type => _type;

  String get path => _path;

  Version(
      {int id,
      Production production,
      int pid,
      String content,
      String time,
      String version,
      int versionCode,
      String type,
      String path}) {
    _id = id;
    _production = production;
    _pid = pid;
    _content = content;
    _time = time;
    _version = version;
    _versionCode = versionCode;
    _type = type;
    _path = path;
  }

  Version.fromJson(dynamic json) {
    _id = json["id"];
    _production = json["production"] != null
        ? Production.fromJson(json["production"])
        : null;
    _pid = json["pid"];
    _content = json["content"];
    _time = json["time"];
    _version = json["version"];
    _versionCode = int.parse(json["versionCode"]);
    _type = json["type"];
    _path = json["path"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    if (_production != null) {
      map["production"] = _production.toJson();
    }
    map["pid"] = _pid;
    map["content"] = _content;
    map["time"] = _time;
    map["version"] = _version;
    map["versionCode"] = _versionCode;
    map["type"] = _type;
    map["path"] = _path;
    return map;
  }
}
