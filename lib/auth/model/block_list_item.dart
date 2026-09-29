/// 黑名单条目，对应 GET /api/v1/f/blocklist 的 data.list 元素。
///
/// 接口契约见青年湖底接口文档：
///   POST /api/v1/f/blocklist/add
///   GET  /api/v1/f/blocklist/delete
///   GET  /api/v1/f/blocklist
class BlockListItem {
  BlockListItem({
    required this.uid,
    required this.userInfo,
    required this.createdAt,
  });

  /// 被屏蔽用户的 ID
  int uid;

  /// 用户展示信息；用户已注销或被删除时后端返回非空占位值
  BlockUserInfo userInfo;

  /// 加入黑名单的时间
  DateTime? createdAt;

  factory BlockListItem.fromJson(Map<String, dynamic> json) => BlockListItem(
        uid: json["uid"] ?? 0,
        userInfo: BlockUserInfo.fromJson(json["user_info"] ?? {}),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "user_info": userInfo.toJson(),
        "created_at": createdAt?.toIso8601String(),
      };
}

/// 被屏蔽用户的展示信息
class BlockUserInfo {
  BlockUserInfo({
    required this.nickname,
    required this.avatar,
    required this.avatarFrame,
    required this.levelName,
    required this.level,
  });

  String nickname;
  String avatar;
  String avatarFrame;
  String levelName;
  int level;

  factory BlockUserInfo.fromJson(Map<String, dynamic> json) => BlockUserInfo(
        nickname: json["nickname"] ?? '',
        avatar: json["avatar"] ?? '',
        avatarFrame: json["avatar_frame"] ?? '',
        levelName: json["level_name"] ?? '',
        level: json["level"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "avatar": avatar,
        "avatar_frame": avatarFrame,
        "level_name": levelName,
        "level": level,
      };
}
