// @dart = 2.12
import 'dart:convert';
import 'dart:io';

import 'path_util.dart';

class DownloadTask {
  final String url;
  final String fileName;
  final String? title;
  final String? description;
  final bool showNotification;
  final String type;
  final String path;
  final String id;
  late String listenerId;

  DownloadTask._({
    required this.url,
    required this.fileName,
    required this.showNotification,
    required this.type,
    required this.id,
    required this.path,
    this.title,
    this.description,
  });

  factory DownloadTask({
    required String url,
    String? fileName,
    bool? showNotification,
    String? type,
    String? title,
    String? description,
  }) {
    url = "http://152.136.148.227:8001/androidupdate/downloadFile/$url";
    fileName ??= url.split("/").last;
    type ??= DownloadType.other;
    showNotification ??= false;
    String id = "${DateTime.now().millisecondsSinceEpoch}-$type-$fileName";
    String path = PathUtil.downloadDir.path +
        Platform.pathSeparator +
        type +
        Platform.pathSeparator +
        fileName;

    return DownloadTask._(
        url: url,
        fileName: fileName,
        showNotification: showNotification,
        type: type,
        id: id,
        path: path);
  }

  bool get exist => File(path).existsSync();

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'fileName': fileName,
      'title': title,
      'description': description,
      'showNotification': showNotification,
      'type': type,
      'path': path,
      'id': id,
      'listenerId': listenerId,
    };
  }

  @override
  String toString() {
    return json.encode(toMap());
  }
}

class DownloadList {
  final List<DownloadTask> list;

  DownloadList(this.list);

  Map<String, dynamic> toMap() {
    return {
      'list': list.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class DownloadType {
  static final String apk = 'apk';
  static final String font = 'font';
  static final String hotfix = 'hotfix';
  static final String other = 'other';
}
