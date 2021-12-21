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
    this.imageUrls,
    this.department,
  });

  int id;
  DateTime createAt;
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
  List<String> imageUrls;
  Department department;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    createAt: DateTime.parse(json["create_at"]),
    type: json["type"],
    campus: json["campus"],
    solved: json["solved"],
    title: json["title"],
    content: json["content"],
    favCount: json["fav_count"],
    likeCount: json["like_count"],
    rating: json["rating"],
    tag: Tag.fromJson(json["tag"]),
    floors: List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
    commentCount: json["comment_count"],
    isLike: json["is_like"],
    isDis: json["is_dis"],
    isFav: json["is_fav"],
    imageUrls: List<String>.from(json["image_urls"].map((x) => x)),
    department: Department.fromJson(json["department"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_at": createAt.toIso8601String(),
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
    this.likeCount,
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
  int likeCount;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
    id: json["id"],
    createAt: DateTime.parse(json["create_at"]),
    uid: json["uid"],
    postId: json["post_id"],
    content: json["content"],
    nickname: json["nickname"],
    imageUrl: json["image_url"],
    replyTo: json["reply_to"],
    replyToName: json["reply_to_name"],
    likeCount: json["like_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_at": createAt.toIso8601String(),
    "uid": uid,
    "post_id": postId,
    "content": content,
    "nickname": nickname,
    "image_url": imageUrl,
    "reply_to": replyTo,
    "reply_to_name": replyToName,
    "like_count": likeCount,
  };

  // changeLikeStatus() {
  //   if (isLiked)
  //     likeCount -= 1;
  //   else
  //     likeCount += 1;
  //   isLiked = !isLiked;
  // }
}

class Tag {
  Tag({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
