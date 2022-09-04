class NAcidInfo {
  NAcidInfo({
    this.id,
    this.nAcidInfoOperator,
    this.percentage,
    this.campus,
    this.type,
    this.title,
    this.content,
    this.url,
    this.createdAt,
    this.startTime,
    this.endTime,
  });

  int id;
  String nAcidInfoOperator;
  String percentage;
  String campus;
  String type;
  String title;
  String content;
  String url;
  DateTime createdAt;
  DateTime startTime;
  DateTime endTime;

  factory NAcidInfo.fromJson(Map<String, dynamic> json) => NAcidInfo(
    id: json["id"],
    nAcidInfoOperator: json["operator"],
    percentage: json["percentage"],
    campus: json["campus"],
    type: json["type"],
    title: json["title"],
    content: json["content"],
    url: json["url"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    startTime: DateTime.parse(json["startTime"]),
    endTime: DateTime.parse(json["endTime"]),
  );
}
