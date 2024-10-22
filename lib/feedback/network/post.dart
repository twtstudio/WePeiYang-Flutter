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

  /// 依赖有没有 id 来判空
  bool get isNull => this.id == 0;

  Post.fromJson(Map<String, dynamic> json)
      : id = json["id"] ?? 0,
        createAt = (json["created_at"] == '')
            ? null
            : DateTime.parse(json["created_at"]),
        uid = json["uid"] ?? 0,
        type = json["type"] ?? 0,
        campus = json["campus"] ?? 0,
        solved = json["solved"] ?? 0,
        title = json["title"] ?? '',
        content = json["content"] ?? '',
        favCount = json["fav_count"] ?? 0,
        likeCount = json["like_count"] ?? 0,
        rating = json["rating"] ?? 0,
        tag = (json["tag"] == null) ? null : Tag.fromJson(json["tag"]),
        floors = (json["floors"] == null)
            ? <Floor>[]
            : List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
        commentCount = json["comment_count"] ?? 0,
        isLike = json["is_like"] ?? false,
        isDis = json["is_dis"] ?? false,
        isFav = json["is_fav"] ?? false,
        isOwner = json["is_owner"] ?? false,
        imageUrls = (json["image_urls"] == null)
            ? <String>[]
            : List<String>.from(json["image_urls"].map((x) => x)),
        department = (json["department"] == null)
            ? null
            : Department.fromJson(json["department"]),
        visitCount = json["visit_count"] ?? 0,
        eTag = json["e_tag"] ?? '',
        nickname = json["nickname"] ?? '',
        level = json["user_info"]["level"] ?? 0,
        avatar = json["user_info"]["avatar"] ?? '',
        avatarBox = json["user_info"]["avatar_frame"] ?? '';

  Post.empty()
      : id = 0,
        createAt = null,
        uid = 0,
        type = 0,
        campus = 0,
        solved = 0,
        title = '',
        content = '',
        favCount = 0,
        likeCount = 0,
        rating = 0,
        tag = null,
        floors = <Floor>[],
        commentCount = 0,
        isLike = false,
        isDis = false,
        isFav = false,
        isOwner = false,
        imageUrls = <String>[],
        department = null,
        visitCount = 0,
        eTag = '',
        nickname = '',
        level = 0,
        avatar = '',
        avatarBox = '';

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
      : id = json["id"] ?? 0,
        createAt = json["created_at"] == ''
            ? null
            : DateTime.parse(json["created_at"]),
        uid = json["uid"] ?? 0,
        postId = json["post_id"] ?? 0,
        content = json["content"] ?? '',
        nickname = json["nickname"] ?? '',
        sender = json["sender"] ?? 0,
        imageUrl = json["image_url"] ?? '',
        replyTo = json["reply_to"] ?? 0,
        replyToName = json["reply_to_name"] ?? '',
        rating = json["rating"] ?? 0,
        subTo = json["sub_to"] ?? 0,
        value = json["value"] ?? 0,
        likeCount = json["like_count"] ?? 0,
        subFloors = json["sub_floors"] == null
            ? <Floor>[]
            : List<Floor>.from(
                json["sub_floors"].map((x) => Floor.fromJson(x))),
        subFloorCnt = json["sub_floor_cnt"] ?? 0,
        isLike = json["is_like"] ?? false,
        isDis = json["is_dis"] ?? false,
        avatar =
            json["user_info"] == null ? '' : json["user_info"]["avatar"] ?? '',
        avatarBox = json["user_info"] == null
            ? ''
            : json["user_info"]["avatar_frame"] ?? '',
        isOwner = json["is_owner"] ?? false,
        level = json["user_info"] == null ? 0 : json["user_info"]["level"] ?? 0;

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
      : this.id = json["id"] ?? 0,
        this.sender = json["sender"] ?? '',
        this.title = json["title"] ?? '',
        this.content = json["content"] ?? '',
        this.is_read = json["is_read"] ?? 0,
        this.createdAt = json["created_at"] ?? '';

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
      : this.id = json["id"] ?? -1,
        this.name = json["name"] ?? '',
        this.title = json["title"] ?? '',
        this.image = json["image"] ?? '',
        this.url = json["url"] ?? '',
        this.ord = json["ord"] ?? 1,
        this.createdAt = json["createdAt"] ?? '';

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

  @override
  String toString() {
    return 'WPYTab{id: $id, shortname: $shortname, name: $name}';
  }

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
        id: json["id"] ?? 1,
        tagId: json["tag_id"] ?? 0,
        point: json["point"] ?? 0,
        name: json["name"] ?? "",
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
    total = json['total'] ?? 0;
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
    id = json['id'] ?? '';
    addr = json['addr'] ?? '';
    createdAt = json['created_at'] ?? '';
    comment = json['comment'] ?? '';
    type = json['type'] ?? '';
    name = json['name'] ?? '';
    hidden = json['hidden'] ?? '';
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
