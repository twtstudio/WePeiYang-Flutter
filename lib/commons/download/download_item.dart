import 'dart:convert';

class DownloadItem {
  final String url;
  final String fileName;
  final String title;
  final bool showNotification;

  DownloadItem(this.url, this.fileName, this.title, this.showNotification);

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'fileName': fileName,
      'title': title,
      'showNotification': showNotification,
    };
  }

  String toJson() => json.encode(toMap());

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      map['url'] ?? '',
      map['fileName'] ?? '',
      map['title'] ?? '',
      map['showNotification'] ?? false,
    );
  }

  factory DownloadItem.fromJson(String source) =>
      DownloadItem.fromMap(json.decode(source));
}

class DownloadList {
  final List<DownloadItem> list;

  DownloadList(this.list);

  Map<String, dynamic> toMap() {
    return {
      'list': list.map((x) => x.toMap()).toList(),
    };
  }

  factory DownloadList.fromMap(Map<String, dynamic> map) {
    return DownloadList(
      List<DownloadItem>.from(map['list']?.map((x) => DownloadItem.fromMap(x))),
    );
  }

  factory DownloadList.fromList(List<Map<String, dynamic>> map) {
    return DownloadList.fromMap({"list": map});
  }

  String toJson() => json.encode(toMap());
}
