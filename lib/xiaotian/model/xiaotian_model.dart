import 'package:uuid/uuid.dart';
/// ================ 模型 ===============

//ai传回的回答结构
class ChatEvent {
  final String type; // token / source / followup / trace_id / error
  final dynamic data;
  ChatEvent._(this.type, this.data);

  factory ChatEvent.token(String text) => ChatEvent._('token', {'token': text});
  factory ChatEvent.source(List<Source> list) => ChatEvent._('source', list);
  factory ChatEvent.followup(String question) =>
      ChatEvent._('followup', {'question': question});
  factory ChatEvent.traceId(String id) =>
      ChatEvent._('trace_id', {'trace_id': id});
  factory ChatEvent.error(String msg) => ChatEvent._('error', {'message': msg});

  @override
  String toString() => 'ChatEvent($type,$data)';
}

//文件来源的结构
class Source {
  final String title, link, pubTime, contentType;
  Source.fromJson(Map<String, dynamic> m)
      : title = m['title'] ?? '',
        link = m['link'] ?? '',
        pubTime = m['publication_time'] ?? '',
        contentType = m['content_type'] ?? '';
}

//历史会话记录的结构
class HistorySession {
  final String sessionId, title, creationTime;
  HistorySession.fromJson(Map<String, dynamic> m)
      : sessionId = m['session_id'],
        title = m['title'],
        creationTime = m['creation_time'];

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'title': title,
    'creation_time': creationTime,
  };
}

//请求历史消息时返回的消息类型/接口模型
class HistoryChatMessage {
  final String role;
  final String content;
  final bool file;
  final int likeCount;
  final String? traceId;

  HistoryChatMessage({
    required this.role,
    required this.content,
    required this.file,
    required this.likeCount,
    this.traceId,
  });

  factory HistoryChatMessage.fromJson(Map<String, dynamic> m) {
    return HistoryChatMessage(
      role: m['role'],
      content: m['content'],
      file: m['file'] == true,
      likeCount: int.tryParse(m['likeCount']?.toString() ?? '0') ?? 0,
      traceId: m['trace_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'file': file,
    'likeCount': likeCount,
    'trace_id': traceId,
  };
}

//消息类型的抽象类
abstract class ChatMessage {
  final String role;
  final String id;
  ChatMessage(this.role) : id = const Uuid().v4();
}

//用户消息类
class UserMessage extends ChatMessage {
  final String content;
  final List<String>? files;

  UserMessage({
    required this.content,
    this.files,
  }) : super('user');
}

class AiMessage extends ChatMessage {
  String? text;
  final int likeCount;
  final String? traceId;

  final Stream<ChatEvent>? stream;

  AiMessage({
    this.text,
    this.likeCount = 0,
    this.traceId,
    this.stream,
  }) : super('ai');
}