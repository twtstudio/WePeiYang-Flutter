import 'package:we_pei_yang_flutter/feedback/network/post.dart';


class MessageCount {
  MessageCount({
    this.like,
    this.floor,
    this.reply,
    this.notice,
  });

  int like;
  int floor;
  int reply;
  int notice;

  factory MessageCount.fromJson(Map<String, dynamic> json) => MessageCount(
    like: json["like"],
    floor: json["floor"],
    reply: json["reply"],
    notice: json["notice"],
  );

  Map<String, dynamic> toJson() => {
    "like": like,
    "floor": floor,
    "reply": reply,
    "notice": notice,
  };

  int get total => like + floor + reply + notice;
}

class LikeMessage {
  LikeMessage({
    this.type,
    this.post,
    this.floor,
  });

  int type;
  Post post;
  Floor floor;

  factory LikeMessage.fromJson(Map<String, dynamic> json) => LikeMessage(
    type: json["type"],
    post: Post.fromJson(json["post"]),
    floor: Floor.fromJson(json["floor"]),
  );
}

class FloorMessage {
  FloorMessage({
    this.type,
    this.isRead,
    this.toFloor,
    this.post,
    this.floor,
  });

  int type;
  bool isRead;
  Floor toFloor;
  Post post;
  Floor floor;

  factory FloorMessage.fromJson(Map<String, dynamic> json) => FloorMessage(
    type: json["type"],
    isRead: json["is_read"],
    toFloor: json["to_floor"] == null ? null : Floor.fromJson(json["to_floor"]),
    post: Post.fromJson(json["post"]),
    floor: Floor.fromJson(json["floor"]),
  );
}

class NoticeMessage {
  NoticeMessage({
    this.id,
    this.createdAt,
    this.sender,
    this.title,
    this.content,
    this.url,
    this.isRead,
  });

  int id;
  DateTime createdAt;
  String sender;
  String title;
  String content;
  String url;
  bool isRead;

  factory NoticeMessage.fromJson(Map<String, dynamic> json) => NoticeMessage(
    id: json["id"],
    createdAt: DateTime.parse(json["created_at"]),
    sender: json["sender"],
    title: json["title"],
    content: json["content"],
    url: json["url"],
    isRead: json["is_read"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt.toIso8601String(),
    "sender": sender,
    "title": title,
    "content": content,
    "url": url,
    "is_read": isRead,
  };
}
