import 'package:we_pei_yang_flutter/feedback/network/post.dart';


class MessageCount {
  MessageCount({
    this.floor,
    this.reply,
    this.notice,
  });

  int floor;
  int reply;
  int notice;

  factory MessageCount.fromJson(Map<String, dynamic> json) => MessageCount(
    floor: json["floor"],
    reply: json["reply"],
    notice: json["notice"],
  );

  Map<String, dynamic> toJson() => {
    "floor": floor,
    "reply": reply,
    "notice": notice,
  };

  int get total => floor + reply + notice;
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
    toFloor: Floor.fromJson(json["to_floor"]),
    post: Post.fromJson(json["post"]),
    floor: Floor.fromJson(json["floor"]),
  );
}
