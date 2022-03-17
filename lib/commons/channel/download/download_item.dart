// @dart = 2.12
import 'dart:convert';

class DownloadItem {
  final String url;
  final String fileName;
  final String? title;
  final String? description;
  final bool showNotification;
  final DownloadType type;
  String resultPath = "";
  final String id;
  late String listenerId;

  DownloadItem({
    required this.url,
    required this.fileName,
    required this.showNotification,
    required this.type,
    this.title,
    this.description,
  }) : id = "${DateTime.now().millisecondsSinceEpoch}-$type-$fileName";

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'fileName': fileName,
      'showNotification': showNotification,
      'type': type.path,
      'title': title,
      'description': description,
      'id': id,
      'listenerId': listenerId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return toJson();
  }
}

class DownloadList {
  final List<DownloadItem> list;

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
  String get path => ['apk', 'font', 'hotfix', 'other'][index];
}
