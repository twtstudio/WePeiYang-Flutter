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

class ReplyMessage {
  ReplyMessage({
    this.isRead,
    this.post,
    this.reply,
  });

  bool isRead;
  Post post;
  Reply reply;

  factory ReplyMessage.fromJson(Map<String, dynamic> json) => ReplyMessage(
    isRead: json["is_read"],
    post: Post.fromJson(json["post"]),
    reply: Reply.fromJson(json["reply"]),
  );

  Map<String, dynamic> toJson() => {
    "is_read": isRead,
    "post": post.toJson(),
    "reply": reply.toJson(),
  };
}

class Reply {
  Reply({
    this.id,
    this.createdAt,
    this.postId,
    this.sender,
    this.content,
    this.imageUrls,
  });

  int id;
  DateTime createdAt;
  int postId;
  int sender;
  String content;
  List<String> imageUrls;

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    id: json["id"],
    createdAt: DateTime.parse(json["created_at"]),
    postId: json["post_id"],
    sender: json["sender"],
    content: json["content"],
    imageUrls: List<String>.from(json["image_urls"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt.toIso8601String(),
    "post_id": postId,
    "sender": sender,
    "content": content,
    "image_urls": List<dynamic>.from(imageUrls.map((x) => x)),
  };
}

