// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
  Post({
    this.id,
    this.createAt,
    this.uid,
    this.type,
    this.campus,
    this.solved,
    this.title,
    this.content,
    this.favCount,
    this.likeCount,
    this.rating,
    this.tag,
    this.floors,
    this.commentCount,
    this.isLike,
    this.isDis,
    this.isFav,
    this.isOwner,
    this.imageUrls,
    this.department,
    this.visitCount,
    this.eTag,
    this.nickname,
    this.level,
    this.avatar,
    this.avatarBox,
  });

  int id;
  DateTime createAt;
  int uid;
  int type;
  int campus;
  int solved;
  String title;
  String content;
  int favCount;
  int likeCount;
  int rating;
  Tag tag;
  List<Floor> floors;
  int commentCount;
  bool isLike;
  bool isDis;
  bool isFav;
  bool isOwner;
  List<String> imageUrls;
  Department department;
  int visitCount;
  int level;
  String avatar;
  String avatarBox;
  String eTag;
  String nickname;

  bool operator ==(Object other) => other is Post && other.id == id;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      id: json["id"],
      createAt:
          json["created_at"] == "" ? null : DateTime.parse(json["created_at"]),
      uid: json["uid"],
      type: json["type"],
      campus: json["campus"],
      solved: json["solved"],
      title: json["title"],
      content: json["content"],
      favCount: json["fav_count"],
      likeCount: json["like_count"],
      rating: json["rating"],
      tag: json["tag"] == null ? null : Tag.fromJson(json["tag"]),
      floors: json["floors"] == null
          ? null
          : List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
      commentCount: json["comment_count"],
      isLike: json["is_like"],
      isDis: json["is_dis"],
      isFav: json["is_fav"],
      isOwner: json["is_owner"],
      imageUrls: json["image_urls"] == null
          ? null
          : List<String>.from(json["image_urls"].map((x) => x)),
      department: json["department"] == null
          ? null
          : Department.fromJson(json["department"]),
      visitCount: json["visit_count"],
      eTag: json["e_tag"],
      nickname: json["nickname"],
      level: json["user_info"]["level"],
      avatar: json["user_info"]["avatar"],
      avatarBox:
          json["user_info"] == null ? "" : json["user_info"]["avatar_frame"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createAt.toIso8601String(),
        "uid": uid,
        "type": type,
        "campus": campus,
        "solved": solved,
        "title": title,
        "content": content,
        "fav_count": favCount,
        "like_count": likeCount,
        "rating": rating,
        "tag": tag.toJson(),
        "floors": List<dynamic>.from(floors.map((x) => x.toJson())),
        "comment_count": commentCount,
        "is_like": isLike,
        "is_dis": isDis,
        "is_fav": isFav,
        "is_owner": isOwner,
        "image_urls": List<dynamic>.from(imageUrls.map((x) => x)),
        "department": department.toJson(),
        "visit_count": visitCount,
        "e_tag": eTag,
        "nickname": nickname,
        "level": level,
        "avatar": avatar,
        "avatar_frame": avatarBox,
      };

  Post.nullExceptId(int questionId) {
    id = questionId;
  }
}

class Department {
  Department({
    this.id,
    this.name,
    this.introduction,
  });

  int id;
  String name;
  String introduction;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json["id"],
        name: json["name"],
        introduction: json["introduction"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "introduction": introduction,
      };
}

class FloorList {
  FloorList(
    List<Floor> list,
  ) {
    _list = list;
  }

  factory FloorList.fromJson(Map<String, dynamic> json) {
    final list = <Floor>[];
    if (json['list'] != null) {
      (json['list'] as List).forEach((v) {
        list.add(Floor.fromJson(v));
      });
    }
    return FloorList(list);
  }

  List<Floor> _list;

  List<Floor> get list => _list;
}

class Floor {
  Floor({
    this.id,
    this.createAt,
    this.uid,
    this.postId,
    this.content,
    this.nickname,
    this.imageUrl,
    this.sender,
    this.replyTo,
    this.value,
    this.replyToName,
    this.subTo,
    this.likeCount,
    this.subFloors,
    this.subFloorCnt,
    this.rating,
    this.isLike,
    this.isDis,
    this.isOwner,
    this.avatar,
    this.avatarBox,
    this.level,
  });

  int id;
  DateTime createAt;
  int uid;
  int postId;
  int sender;
  String content;
  String nickname;
  String imageUrl;
  int replyTo;
  String replyToName;
  int subTo;
  int value;
  int likeCount;
  List<Floor> subFloors;
  int subFloorCnt;
  int rating;
  bool isLike;
  bool isDis;
  String avatar;
  String avatarBox;
  bool isOwner;
  int level;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"],
        createAt: json["created_at"] == ""
            ? null
            : DateTime.parse(json["created_at"]),
        uid: json["uid"],
        postId: json["post_id"],
        content: json["content"],
        nickname: json["nickname"],
        sender: json["sender"],
        imageUrl: json["image_url"],
        replyTo: json["reply_to"],
        replyToName: json["reply_to_name"],
        rating: json["rating"],
        subTo: json["sub_to"],
        value: json["value"],
        likeCount: json["like_count"],
        subFloors: json["sub_floors"] == null
            ? null
            : List<Floor>.from(
                json["sub_floors"].map((x) => Floor.fromJson(x))),
        subFloorCnt: json["sub_floor_cnt"],
        isLike: json["is_like"],
        isDis: json["is_dis"],
        avatar: json["user_info"] == null ? null : json["user_info"]["avatar"],
        avatarBox:
            json["user_info"] == null ? "" : json["user_info"]["avatar_frame"],
        level: json["user_info"] == null ? null : json["user_info"]["level"],
        isOwner: json["is_owner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createAt.toIso8601String(),
        "uid": uid,
        "post_id": postId,
        "content": content,
        "sender": sender,
        "nickname": nickname,
        "image_url": imageUrl,
        "reply_to": replyTo,
        "reply_to_name": replyToName,
        "sub_to": subTo,
        "value": value,
        "like_count": likeCount,
        "sub_floors": subFloors == null
            ? null
            : List<dynamic>.from(subFloors.map((x) => x.toJson())),
        "sub_floor_cnt": subFloorCnt,
        "is_like": isLike,
        "is_dis": isDis,
        "is_owner": isOwner,
        "avatar": avatar,
        "avatar_frame": avatarBox
      };

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}

class Notice {
  Notice(
      {this.id,
      this.content,
      this.title,
      this.is_read,
      this.sender,
      this.createdAt});

  int id;
  String sender;
  String title;
  String content;
  int is_read;
  String createdAt;

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json["id"],
        sender: json["sender"],
        title: json["title"],
        is_read: json["is_read"],
        content: json["content"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sender": sender,
        "title": title,
        "is_read": is_read,
        "content": content,
        "created_at": createdAt
      };
}

class Festival {
  Festival(
      {this.id,
      this.name,
      this.title,
      this.image,
      this.url,
      this.ord,
      this.createdAt});

  int id;
  String name;
  String title;
  String image;
  String url;
  int ord;
  String createdAt;

  factory Festival.fromJson(Map<String, dynamic> json) => Festival(
        id: json["id"],
        name: json["name"],
        title: json["title"],
        image: json["image"],
        url: json["url"],
        ord: json["ord"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "title": title,
        "image": image,
        "url": url,
        "ord": ord,
        "created_at": createdAt
      };
}

class WPYTab {
  WPYTab({
    this.id,
    this.shortname,
    this.name,
  });

  int id;
  String shortname;
  String name;

  factory WPYTab.fromJson(Map<String, dynamic> json) => WPYTab(
        id: json["id"],
        shortname: json["shortname"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shortname": shortname,
        "name": name,
      };
}

class Tag {
  Tag({
    this.id,
    this.tagId,
    this.point,
    this.name,
  });

  int id;
  int tagId;
  int point;
  String name;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        tagId: json["tag_id"],
        point: json["point"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tag_id": tagId,
        "point": point,
        "name": name,
      };
}

class SearchTag {
  SearchTag({
    this.id,
    this.name,
  });

  int id;
  int point;
  String name;

  factory SearchTag.fromJson(Map<String, dynamic> json) => SearchTag(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class PostTagId {
  PostTagId({
    this.id,
  });

  int id;

  factory PostTagId.fromJson(Map<String, dynamic> json) => PostTagId(
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}

class Error {
  Error({
    this.error,
  });

  String error;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "error": error,
      };
}

class AvatarBoxList {
  AvatarBoxList({
    this.avatarFrameList,
  });

  List<AvatarBox> avatarFrameList;

  AvatarBoxList.fromJson(Map<String, dynamic> json) {
    avatarFrameList = List.from(json['avatar_frame_list'])
        .map((e) => AvatarBox.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['avatar_frame_list'] =
        avatarFrameList.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AvatarBox {
  AvatarBox({
    this.id,
    this.addr,
    this.createdAt,
    this.comment,
    this.type
  });

  int id;
  String addr;
  String createdAt;
  String comment;
  String type;

  AvatarBox.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addr = json['addr'];
    createdAt = json['created_at'];
    comment = json['comment'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['addr'] = addr;
    _data['created_at'] = createdAt;
    _data['comment'] = comment;
    _data['type'] = type;
    return _data;
  }
}
