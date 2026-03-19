/// 私聊功能数据模型
///
/// 数据格式说明：
///   - 所有 JSON Key 统一使用 snake_case（msg_id, sender_id, send_time 等）

/// 统一 API 响应结果
/// 后端所有接口返回的 Result 包装结构
class PrivateChatApiResult {
  final int code;
  final String msg;
  final dynamic data;

  PrivateChatApiResult({required this.code, required this.msg, this.data});

  bool get isSuccess => code == 200;

  factory PrivateChatApiResult.fromJson(Map<String, dynamic> json) {
    return PrivateChatApiResult(
      code: json['code'] ?? 0,
      msg: json['msg'] ?? '',
      data: json['data'],
    );
  }
}

/// 私信消息 VO
/// 对应后端的 PrivateChatMsgVO 结构，REST API 返回与 WebSocket 推送统一使用此结构。
///
/// msg_status 含义：
///   0 = 未读，1 = 已读，2 = 已撤回
class PrivateChatMsgVO {
  final int? msgId;
  final int? senderId;
  final int? receiverId;
  final String? content;
  final int? msgType;
  final String? sendTime;
  final int? sessionId;
  final int? msgStatus;

  PrivateChatMsgVO({
    this.msgId,
    this.senderId,
    this.receiverId,
    this.content,
    this.msgType,
    this.sendTime,
    this.sessionId,
    this.msgStatus,
  });

  factory PrivateChatMsgVO.fromJson(Map<String, dynamic> json) {
    // 处理 send_time：支持字符串或数字时间戳,如果是数字时间戳则转换为 "YYYY-MM-DD HH:MM:SS" 格式的字符串
    String? sendTime;
    final rawTime = json['send_time'] ?? json['sendTime'] ?? json['send_time_ms'] ?? json['send_time_millis'];
    if (rawTime is String) {
      final numeric = rawTime.trim();
      final numericValue = double.tryParse(numeric);
      if (numericValue != null) {
        // 如果是数字字符串，判断是秒还是毫秒（小于 1e12 认为是秒），然后转换为 DateTime
        final ms = numericValue < 1e12 ? (numericValue * 1000).toInt() : numericValue.toInt();
        final dt = DateTime.fromMillisecondsSinceEpoch(ms);
        sendTime =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      } else {
        sendTime = rawTime;
      }
    } else if (rawTime is int) {
      final ms = rawTime < 1000000000000 ? rawTime * 1000 : rawTime;
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      sendTime =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } else if (rawTime is double) {
      final ms = rawTime < 1e12 ? (rawTime * 1000).toInt() : rawTime.toInt();
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      sendTime =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }

    return PrivateChatMsgVO(
      msgId: (json['msg_id'] as int?),
      senderId: (json['sender_id'] as int?),
      receiverId: (json['receiver_id'] as int?),
      content: (json['content'] as String?),
      msgType: (json['msg_type'] as int?),
      sendTime: sendTime,
      sessionId: (json['session_id'] as int?),
      msgStatus: (json['msg_status'] as int?),
    );
  }

  /// 是否已撤回
  bool get isRecalled => msgStatus == 2;

  /// 解析发送时间
  DateTime? get sendDateTime {
    if (sendTime == null) return null;
    try {
      // 后端返回的时间格式是 "YYYY-MM-DD HH:MM:SS"，需要替换为"YYYY-MM-DDTHH:MM:SS"，
      return DateTime.parse(sendTime!.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  /// 格式化时间（仅时:分）
  String get formattedTime {
    final dt = sendDateTime;
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// 聊天会话实体
/// 对应后端的 PrivateChatSession 结构
/// 约定 userId1 < userId2
class ChatSession {
  final int sessionId;
  final int userId1;
  final int userId2;
  final String? lastMsg;
  final String? lastMsgTime;
  final int? user1Unread;
  final int? user2Unread;
  final int? isDeleted;
  int unreadCount;

  ChatSession({
    required this.sessionId,
    required this.userId1,
    required this.userId2,
    this.lastMsg,
    this.lastMsgTime,
    this.user1Unread,
    this.user2Unread,
    this.isDeleted,
    this.unreadCount = 0,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final user1Unread = json['user1_unread'] as int?;
    final user2Unread = json['user2_unread'] as int?;
    return ChatSession(
      sessionId: (json['session_id'] as int?) ?? 0,
      userId1: (json['user_id1'] as int?) ?? 0,
      userId2: (json['user_id2'] as int?) ?? 0,
      lastMsg: json['last_msg'] as String?,
      lastMsgTime: json['last_msg_time'] as String?,
      user1Unread: user1Unread,
      user2Unread: user2Unread,
      isDeleted: (json['is_deleted'] as int?),
      unreadCount: (json['unread_count'] as int?) ?? 0,
    );
  }

  /// 获取对方的用户 ID
  int getOtherUserId(int myUserId) {
    return userId1 == myUserId ? userId2 : userId1;
  }

  /// 获取当前用户的未读数（优先使用 user1_unread/user2_unread）
  int getUnreadCountForUser(int myUserId) {
    if (myUserId == userId1 && user1Unread != null) return user1Unread!;
    if (myUserId == userId2 && user2Unread != null) return user2Unread!;
    return unreadCount;
  }
}

/// 联系人（前端展示用）
/// 由 ChatSession + 用户资料 组合生成，不直接对应后端接口
class PrivateChatContact {
  final int userId;
  String username;
  String avatar;
  int? sessionId;
  String lastMsg;
  String? lastMsgTime;
  int unreadCount;

  PrivateChatContact({
    required this.userId,
    required this.username,
    this.avatar = '',
    this.sessionId,
    this.lastMsg = '',
    this.lastMsgTime,
    this.unreadCount = 0,
  });

  /// 获取头像 URL（优先自定义头像，否则用 SVG 默认头像）
  String get avatarUrl {
    if (avatar.isNotEmpty) {
      return 'https://qnhdpic.twt.edu.cn/download/origin/$avatar';
    }
    return '';
  }

  /// 格式化最后消息时间
  String get formattedLastMsgTime {
    if (lastMsgTime == null) return '';
    try {
      final dt = DateTime.parse(lastMsgTime!.replaceFirst(' ', 'T'));
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

/// 用户私信设置
/// 对应后端的 PrivateChatUserSetting 结构
class PrivateChatUserSetting {
  final int userId;
  int isEnable;
  int isAcceptStranger;
  String blockUserIds;

  PrivateChatUserSetting({
    required this.userId,
    this.isEnable = 1,
    this.isAcceptStranger = 1,
    this.blockUserIds = '',
  });

  factory PrivateChatUserSetting.fromJson(Map<String, dynamic> json) {
    return PrivateChatUserSetting(
      userId: (json['user_id'] as int?) ?? 0,
      isEnable: (json['is_enable'] as int?) ?? 1,
      isAcceptStranger: (json['is_accept_stranger'] as int?) ?? 1,
      blockUserIds: (json['block_user_ids'] as String?) ?? '',
    );
  }

  List<String> get blockList {
    if (blockUserIds.trim().isEmpty) return [];
    return blockUserIds.split(',').where((s) => s.trim().isNotEmpty).toList();
  }
}
