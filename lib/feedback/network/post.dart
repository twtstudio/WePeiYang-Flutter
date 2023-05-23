// @dart = 2.12
class Post {
  int id;
  DateTime? createAt;
  int uid;
  int type;
  int campus;
  int solved;
  String title;
  String content;
  int favCount;
  int likeCount;
  int rating;
  Tag? tag;
  List<Floor> floors;
  int commentCount;
  bool isLike;
  bool isDis;
  bool isFav;
  bool isOwner;
  List<String> imageUrls;
  Department? department;
  int visitCount;
  int level;
  String avatar;
  String avatarBox;
  String eTag;
  String nickname;

  bool fromNotify = false; // 是否从通知栏点过来

  bool operator ==(Object other) => other is Post && other.id == id;

  Post.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.createAt = (json["created_at"] == '')
            ? null
            : DateTime.parse(json["created_at"]),
        this.uid = json["uid"],
        this.type = json["type"],
        this.campus = json["campus"],
        this.solved = json["solved"],
        this.title = json["title"],
        this.content = json["content"],
        this.favCount = json["fav_count"],
        this.likeCount = json["like_count"],
        this.rating = json["rating"],
        this.tag = (json["tag"] == null) ? null : Tag.fromJson(json["tag"]),
        this.floors = (json["floors"] == null)
            ? <Floor>[]
            : List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
        this.commentCount = json["comment_count"],
        this.isLike = json["is_like"],
        this.isDis = json["is_dis"],
        this.isFav = json["is_fav"],
        this.isOwner = json["is_owner"],
        this.imageUrls = (json["image_urls"] == null)
            ? <String>[]
            : List<String>.from(json["image_urls"].map((x) => x)),
        this.department = (json["department"] == null)
            ? null
            : Department.fromJson(json["department"]),
        this.visitCount = json["visit_count"],
        this.eTag = json["e_tag"],
        this.nickname = json["nickname"],
        this.level = json["user_info"]["level"],
        this.avatar = json["user_info"]["avatar"],
        this.avatarBox = json["user_info"]["avatar_frame"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createAt?.toIso8601String(),
        "uid": uid,
        "type": type,
        "campus": campus,
        "solved": solved,
        "title": title,
        "content": content,
        "fav_count": favCount,
        "like_count": likeCount,
        "rating": rating,
        "tag": tag?.toJson(),
        "floors": List<dynamic>.from(floors.map((x) => x.toJson())),
        "comment_count": commentCount,
        "is_like": isLike,
        "is_dis": isDis,
        "is_fav": isFav,
        "is_owner": isOwner,
        "image_urls": List<dynamic>.from(imageUrls.map((x) => x)),
        "department": department?.toJson(),
        "visit_count": visitCount,
        "e_tag": eTag,
        "nickname": nickname,
        "level": level,
        "avatar": avatar,
        "avatar_frame": avatarBox,
      };

  Post.nullExceptId(int questionId)
      : this.fromNotify = true,
        this.id = questionId,
        this.uid = -1,
        this.type = -1,
        this.campus = -1,
        this.solved = -1,
        this.title = '',
        this.content = '',
        this.favCount = -1,
        this.likeCount = -1,
        this.rating = -1,
        this.floors = [],
        this.commentCount = -1,
        this.isLike = false,
        this.isDis = false,
        this.isFav = false,
        this.isOwner = false,
        this.imageUrls = [],
        this.visitCount = -1,
        this.level = -1,
        this.avatar = '',
        this.avatarBox = '',
        this.eTag = '',
        this.nickname = '';
}

class Department {
  int id;
  String name;
  String introduction;

  Department({this.id = 0, this.name = '', this.introduction = ''});

  Department.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.name = json["name"],
        this.introduction = json["introduction"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "introduction": introduction,
      };
}

class FloorList {
  FloorList(this._list);

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
  int id;
  DateTime? createAt;
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

  Floor.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.createAt = json["created_at"] == ''
            ? null
            : DateTime.parse(json["created_at"]),
        this.uid = json["uid"],
        this.postId = json["post_id"],
        this.content = json["content"],
        this.nickname = json["nickname"],
        this.sender = json["sender"],
        this.imageUrl = json["image_url"],
        this.replyTo = json["reply_to"],
        this.replyToName = json["reply_to_name"],
        this.rating = json["rating"],
        this.subTo = json["sub_to"],
        this.value = json["value"],
        this.likeCount = json["like_count"],
        this.subFloors = json["sub_floors"] == null
            ? <Floor>[]
            : List<Floor>.from(
                json["sub_floors"].map((x) => Floor.fromJson(x))),
        this.subFloorCnt = json["sub_floor_cnt"],
        this.isLike = json["is_like"],
        this.isDis = json["is_dis"],
        this.avatar =
            json["user_info"] == null ? null : json["user_info"]["avatar"],
        this.avatarBox = json["user_info"] == null
            ? null
            : json["user_info"]["avatar_frame"],
        this.level =
            json["user_info"] == null ? null : json["user_info"]["level"],
        this.isOwner = json["is_owner"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createAt?.toIso8601String(),
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
        "sub_floors": List<dynamic>.from(subFloors.map((x) => x.toJson())),
        "sub_floor_cnt": subFloorCnt,
        "is_like": isLike,
        "is_dis": isDis,
        "is_owner": isOwner,
        "avatar": avatar,
        "avatar_frame": avatarBox
      };

  @override
  String toString() => toJson().toString();
}

class Notice {
  int id;
  String sender;
  String title;
  String content;
  int is_read;
  String createdAt;

  Notice.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.sender = json["sender"],
        this.title = json["title"],
        this.is_read = json["is_read"],
        this.content = json["content"],
        this.createdAt = json["created_at"];

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
  int id;
  String name;
  String title;
  String image;
  String url;
  int ord;
  String createdAt;

  Festival.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.name = json["name"],
        this.title = json["title"],
        this.image = json["image"],
        this.url = json["url"],
        this.ord = json["ord"],
        this.createdAt = json["createdAt"];

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
    this.id = -1,
    this.shortname = '',
    this.name = '',
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
    required this.id,
    this.tagId = -1,
    this.point = -1,
    this.name = '',
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
  int id;
  String name;

  SearchTag.fromJson(Map<String, dynamic> json)
      : this.id = json["id"],
        this.name = json["name"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class PostTagId {
  int id;

  PostTagId.fromJson(Map<String, dynamic> json) : this.id = json["id"];

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}

class Error {
  String error;

  Error.fromJson(Map<String, dynamic> json) : this.error = json["error"];

  Map<String, dynamic> toJson() => {
        "error": error,
      };
}

class AvatarBoxList {
  AvatarBoxList({
    required this.avatarFrameList,
    required this.total,
  });

  List<AvatarBox> avatarFrameList = [];
  int total = 0;

  AvatarBoxList.fromJson(Map<String, dynamic> json) {
    avatarFrameList = List.from(json['avatar_frame_list'])
        .map((e) => AvatarBox.fromJson(e))
        .toList();
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['avatar_frame_list'] =
        avatarFrameList.map((e) => e.toJson()).toList();
    _data['total'] = total;
    return _data;
  }
}

class AvatarBox {
  late int id;
  late String addr;
  late String createdAt;

  /// 在comment里面上传的对应头像框能够被使用的最低等级。例 11-15 则为11
  late String comment;
  late String type;
  late String name;
  late String hidden;

  AvatarBox.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addr = json['addr'];
    createdAt = json['created_at'];
    comment = json['comment'];
    type = json['type'];
    name = json['name'];
    hidden = json['hidden'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['addr'] = addr;
    _data['created_at'] = createdAt;
    _data['comment'] = comment;
    _data['type'] = type;
    _data['name'] = name;
    _data['hidden'] = hidden;
    return _data;
  }
}
