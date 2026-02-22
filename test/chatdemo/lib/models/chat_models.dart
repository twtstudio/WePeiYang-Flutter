/// 统一 API 响应结果
class ApiResult {
  final int code;
  final String msg;
  final dynamic data;

  ApiResult({required this.code, required this.msg, this.data});

  bool get isSuccess => code == 200;

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      code: json['code'] ?? 0,
      msg: json['msg'] ?? '',
      data: json['data'],
    );
  }
}

/// 私信消息 VO
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
    // 兼容处理 sendTime：
    //   REST API 返回字符串 "yyyy-MM-dd HH:mm:ss"（Spring Jackson 全局配置）
    //   WebSocket 推送返回时间戳数字（WebSocketHandler 使用独立 ObjectMapper）
    String? sendTime;
    final rawTime = json['sendTime'];
    if (rawTime is String) {
      sendTime = rawTime;
    } else if (rawTime is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(rawTime);
      sendTime = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }

    return PrivateChatMsgVO(
      msgId: json['msgId'] is int ? json['msgId'] : null,
      senderId: json['senderId'] is int ? json['senderId'] : null,
      receiverId: json['receiverId'] is int ? json['receiverId'] : null,
      content: json['content']?.toString(),
      msgType: json['msgType'] is int ? json['msgType'] : null,
      sendTime: sendTime,
      sessionId: json['sessionId'] is int ? json['sessionId'] : null,
      msgStatus: json['msgStatus'] is int ? json['msgStatus'] : null,
    );
  }

  /// 是否已撤回
  bool get isRecalled => msgStatus == 2;
}

/// 聊天会话实体
class ChatSession {
  final int sessionId;
  final int userId1;
  final int userId2;
  final String? lastMsg;
  final String? lastMsgTime;
  int unreadCount;

  ChatSession({
    required this.sessionId,
    required this.userId1,
    required this.userId2,
    this.lastMsg,
    this.lastMsgTime,
    this.unreadCount = 0,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'] ?? 0,
      userId1: json['userId1'] ?? 0,
      userId2: json['userId2'] ?? 0,
      lastMsg: json['lastMsg'],
      lastMsgTime: json['lastMsgTime'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  /// 获取对方的用户 ID
  int getOtherUserId(int myUserId) {
    return userId1 == myUserId ? userId2 : userId1;
  }
}

/// 联系人（前端展示用）
class Contact {
  final int userId;
  final String username;
  int? sessionId;
  String lastMsg;
  String? lastMsgTime;
  int unreadCount;

  Contact({
    required this.userId,
    required this.username,
    this.sessionId,
    this.lastMsg = '',
    this.lastMsgTime,
    this.unreadCount = 0,
  });
}

/// 用户私信设置
class UserSetting {
  final int userId;
  int isEnable;
  int isAcceptStranger;
  String blockUserIds;

  UserSetting({
    required this.userId,
    this.isEnable = 1,
    this.isAcceptStranger = 1,
    this.blockUserIds = '',
  });

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      userId: json['userId'] ?? 0,
      isEnable: json['isEnable'] ?? 1,
      isAcceptStranger: json['isAcceptStranger'] ?? 1,
      blockUserIds: json['blockUserIds'] ?? '',
    );
  }

  List<String> get blockList {
    if (blockUserIds.trim().isEmpty) return [];
    return blockUserIds.split(',').where((s) => s.trim().isNotEmpty).toList();
  }
}
