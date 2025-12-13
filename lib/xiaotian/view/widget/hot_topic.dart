class HotTopic {
  final String topic;
  final String tag;
  final int count;
  final String summary;
  final String type;

  HotTopic({
    required this.topic,
    required this.tag,
    required this.count,
    required this.summary,
    required this.type,
  });

  factory HotTopic.fromJson(Map<String, dynamic> json) {
    return HotTopic(
      topic: json['topic'] ?? '',
      tag: json['tag'] ?? '',
      count: json['count'] ?? 0,
      summary: json['summary'] ?? '',
      type: json['type'] ?? '',
    );
  }
}