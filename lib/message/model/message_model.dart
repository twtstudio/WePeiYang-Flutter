import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class MessageCount {
  MessageCount({
    required this.like,
    required this.floor,
    required this.reply,
    required this.notice,
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
  int type;
  Post post;
  Floor floor;

  LikeMessage.fromJson(Map<String, dynamic> json)
      : this.type = json["type"],
        this.post = Post.fromJson(json["post"]),
        this.floor = Floor.fromJson(json["floor"]);
}

class FloorMessage {
  int type;
  bool isRead;
  Floor? toFloor;
  Post post;
  Floor floor;

  FloorMessage.fromJson(Map<String, dynamic> json)
      : this.type = json["type"],
        this.isRead = json["is_read"],
        this.toFloor =
            json["to_floor"] == null ? null : Floor.fromJson(json["to_floor"]),
        this.post = Post.fromJson(json["post"]),
        this.floor = Floor.fromJson(json["floor"]);
}

class NoticeMessage {
  int id;
  DateTime createdAt;
  String sender;
  String title;
  String content;
  String url;
  bool isRead;

  NoticeMessage.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.createdAt = DateTime.parse(json["created_at"]),
        this.sender = json["sender"],
        this.title = json["title"],
        this.content = json["content"],
        this.url = json["url"],
        this.isRead = json["is_read"];

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

class ReplyMessage {
  bool isRead;
  Post post;
  Reply reply;

  ReplyMessage.fromJson(Map<String, dynamic> json)
      : this.isRead = json["is_read"],
        this.post = Post.fromJson(json["post"]),
        this.reply = Reply.fromJson(json["reply"]);

  Map<String, dynamic> toJson() => {
        "is_read": isRead,
        "post": post.toJson(),
        "reply": reply.toJson(),
      };
}

class Reply {
  int id;
  DateTime createdAt;
  int postId;
  int sender;
  String content;
  List<String> imageUrls;

  Reply.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.createdAt = DateTime.parse(json["created_at"]),
        this.postId = json["post_id"],
        this.sender = json["sender"],
        this.content = json["content"],
        this.imageUrls = List<String>.from(json["image_urls"].map((x) => x));

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "post_id": postId,
        "sender": sender,
        "content": content,
        "image_urls": List<dynamic>.from(imageUrls.map((x) => x)),
      };
}
