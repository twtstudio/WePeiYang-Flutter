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
  });

  int id;
  DateTime createAt;
  int uid;
  int type;
  int campus;
  bool solved;
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

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    createAt: json["created_at"] == "" ? null : DateTime.parse(json["created_at"]),
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
    floors: json["floors"] == null ? null : List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
    commentCount: json["comment_count"],
    isLike: json["is_like"],
    isDis: json["is_dis"],
    isFav: json["is_fav"],
    isOwner: json["is_owner"],
    imageUrls: json["image_urls"] == null ? null : List<String>.from(json["image_urls"].map((x) => x)),
    department: json["department"] == null ? null : Department.fromJson(json["department"]),
  );

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
    this.replyTo,
    this.replyToName,
    this.subTo,
    this.likeCount,
    this.subFloors,
    this.subFloorCnt,
    this.rating,
    this.isLike,
    this.isDis,
    this.isOwner,
  });

  int id;
  DateTime createAt;
  int uid;
  int postId;
  String content;
  String nickname;
  String imageUrl;
  int replyTo;
  String replyToName;
  int subTo;
  int likeCount;
  List<Floor> subFloors;
  int subFloorCnt;
  int rating;
  bool isLike;
  bool isDis;
  bool isOwner;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"] ,
        createAt: json["created_at"] == "" ? null : DateTime.parse(json["created_at"]),
        uid: json["uid"],
        postId: json["post_id"],
        content: json["content"],
        nickname: json["nickname"],
        imageUrl: json["image_url"],
        replyTo: json["reply_to"],
        replyToName: json["reply_to_name"],
        rating:json["rating"],
        subTo: json["sub_to"],
        likeCount: json["like_count"],
        subFloors: json["sub_floors"] == null
            ? null
            : List<Floor>.from(
                json["sub_floors"].map((x) => Floor.fromJson(x))),
        subFloorCnt: json["sub_floor_cnt"],
        isLike: json["is_like"],
        isDis: json["is_dis"],
        isOwner: json["is_owner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createAt.toIso8601String(),
        "uid": uid,
        "post_id": postId,
        "content": content,
        "nickname": nickname,
        "image_url": imageUrl,
        "reply_to": replyTo,
        "reply_to_name": replyToName,
        "sub_to": subTo,
        "like_count": likeCount,
        "sub_floors": subFloors == null
            ? null
            : List<dynamic>.from(subFloors.map((x) => x.toJson())),
        "sub_floor_cnt": subFloorCnt,
        "is_like": isLike,
        "is_dis": isDis,
        "is_owner": isOwner,
      };

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}

class Tag {
  Tag({
    this.id,
    this.point,
    this.name,
  });

  int id;
  int point;
  String name;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["tag_id"],
        point: json["point"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
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
class PostTagId{
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