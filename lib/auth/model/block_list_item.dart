/// 黑名单条目，UID和昵称
class BlockListItem {
  final int uid;
  final String nickname;

  BlockListItem.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] as int,
        nickname = (json['user_info'] as Map<String, dynamic>)['nickname']
            as String;
}
