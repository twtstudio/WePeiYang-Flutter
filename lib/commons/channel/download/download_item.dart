import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';

class DownloadTask {
  final String url;
  final String fileName;
  final bool showNotification;
  final String path;
  final String id;
  late String listenerId;

  DownloadTask._({
    required this.url,
    required this.fileName,
    required this.showNotification,
    required this.id,
    required this.path,
  });

  factory DownloadTask.updateApk(AndroidVersion _version) {
    return DownloadTask(
      url: _version.apkUrl,
      fileName: _version.apkName,
      title: '微北洋',
      description: _version.apkName,
      showNotification: false,
      type: DownloadType.apk,
    );
  }

  factory DownloadTask.updateZip(AndroidVersion _version) {
    return DownloadTask(
      url: _version.zipUrl,
      fileName: _version.zipName,
      showNotification: false,
      type: DownloadType.hotfix,
    );
  }

  factory DownloadTask({
    required String url,
    String? fileName,
    bool? showNotification,
    DownloadType? type,
    String? title,
    String? description,
  }) {
    fileName ??= p.split(url).last;
    type ??= DownloadType.other;
    showNotification ??= false;
    String id = "${DateTime.now().millisecondsSinceEpoch}-$type-$fileName";
    String path = type.path + Platform.pathSeparator + fileName;

    return DownloadTask._(
      url: url,
      fileName: fileName,
      showNotification: showNotification,
      id: id,
      path: path,
    );
  }

  bool get exist => File(path).existsSync();

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'fileName': fileName,
      'showNotification': showNotification,
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

enum DownloadType { apk, font, hotfix, other }

extension DownloadTypeExt on DownloadType {
  String get text => ['apk', 'font', 'hotfix', 'other'][index];

  String get path =>
      StorageUtil.downloadDir.path + Platform.pathSeparator + text;
}
