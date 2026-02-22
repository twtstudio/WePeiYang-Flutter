import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'api_service.dart';
import 'websocket_service.dart';

/// 全局状态管理 — 管理用户状态、会话列表、消息和设置
class ChatProvider extends ChangeNotifier {
  // ======== 配置 ========
  String serverHost = '10.0.2.2'; // Android 模拟器访问 localhost
  String serverPort = '8081';

  String get baseUrl => 'http://$serverHost:$serverPort';
  String get baseWsUrl => 'ws://$serverHost:$serverPort';

  // ======== 状态 ========
  int? myUserId;
  bool isConnected = false;
  ApiService? _apiService;
  WebSocketService? _wsService;

  List<Contact> contacts = [];
  Contact? currentContact;
  List<PrivateChatMsgVO> currentMessages = [];
  UserSetting? userSetting;

  /// 消息版本号 — 每次消息列表变化时递增，用于帮助 UI 检测变化
  int messageVersion = 0;

  // 日志
  List<LogEntry> logs = [];

  ApiService? get apiService => _apiService;

  // ======== 连接/断开 ========

  /// 以指定用户 ID 登录并初始化服务
  Future<void> login(int userId) async {
    myUserId = userId;
    _apiService = ApiService(baseUrl: baseUrl, userId: userId);
    _wsService = WebSocketService(baseWsUrl: baseWsUrl, userId: userId);

    _wsService!.onMessageReceived = _onWsMessage;
    _wsService!.onConnectionChanged = (connected) {
      isConnected = connected;
      notifyListeners();
    };
    _wsService!.onLog = (type, msg) {
      // 使用静默日志，避免在 WS 消息处理链中提前触发 notifyListeners
      _addLogSilent(type, msg);
    };

    _wsService!.connect();
    await fetchContacts();
    notifyListeners();
  }

  /// 断开连接并重置状态
  void logout() {
    _wsService?.disconnect();
    _wsService?.dispose();
    _wsService = null;
    _apiService = null;
    myUserId = null;
    isConnected = false;
    contacts = [];
    currentContact = null;
    currentMessages = [];
    userSetting = null;
    notifyListeners();
  }

  // ======== 会话管理 ========

  /// 获取会话列表
  Future<void> fetchContacts() async {
    if (_apiService == null) return;
    try {
      final result = await _apiService!.getSessions();
      if (result.isSuccess && result.data != null) {
        contacts = (result.data as List).map((json) {
          final session = ChatSession.fromJson(json);
          final otherId = session.getOtherUserId(myUserId!);
          return Contact(
            userId: otherId,
            username: '用户 $otherId',
            sessionId: session.sessionId,
            lastMsg: session.lastMsg ?? '',
            lastMsgTime: session.lastMsgTime,
            unreadCount: session.unreadCount,
          );
        }).toList();
        addLog('info', '加载了 ${contacts.length} 个会话');
        notifyListeners();
      }
    } catch (e) {
      addLog('error', '获取会话失败: $e');
    }
  }

  /// 添加新联系人（创建会话）
  Future<String?> addContact(int targetUserId) async {
    if (_apiService == null) return '请先登录';
    if (targetUserId == myUserId) return '不能添加自己';

    // 检查是否已存在
    final existing = contacts.where((c) => c.userId == targetUserId).toList();
    if (existing.isNotEmpty) {
      selectContact(existing.first);
      return null;
    }

    try {
      final result = await _apiService!.createSession(targetUserId);
      if (result.isSuccess && result.data != null) {
        final contact = Contact(
          userId: targetUserId,
          username: '用户 $targetUserId',
          sessionId: result.data['sessionId'],
        );
        contacts.insert(0, contact);
        addLog('info', '✅ 成功创建与用户 $targetUserId 的会话');
        notifyListeners();
        return null; // 成功
      } else {
        return result.msg;
      }
    } catch (e) {
      return '创建会话失败: $e';
    }
  }

  /// 退出聊天界面时清除当前联系人，让后续 WS 消息正确计入未读
  void clearCurrentContact() {
    currentContact = null;
    currentMessages = [];
    notifyListeners();
  }

  /// 选择联系人并加载聊天记录
  Future<void> selectContact(Contact contact) async {
    currentContact = contact;
    contact.unreadCount = 0;
    currentMessages = [];
    notifyListeners();

    // 标记已读
    if (contact.sessionId != null) {
      try {
        await _apiService?.markAsRead(contact.sessionId!);
      } catch (_) {}
    }

    await loadHistory();
  }

  /// 加载聊天记录
  Future<void> loadHistory({int page = 1, int pageSize = 50}) async {
    if (_apiService == null || currentContact == null) return;
    if (currentContact!.sessionId == null) {
      currentMessages = [];
      notifyListeners();
      return;
    }

    try {
      final result = await _apiService!.getChatHistory(
        sessionId: currentContact!.sessionId!,
        userIdB: currentContact!.userId,
        page: page,
        pageSize: pageSize,
      );
      if (result.isSuccess && result.data != null) {
        // API 返回降序（最新在前），配合 ListView reverse:true 直接使用
        currentMessages = (result.data as List)
            .map((json) => PrivateChatMsgVO.fromJson(json))
            .toList();
        messageVersion++;
        notifyListeners();
      }
    } catch (e) {
      addLog('error', '加载聊天记录失败: $e');
    }
  }

  // ======== 消息收发 ========

  /// 发送消息
  Future<String?> sendMessage(String content, {int msgType = 1}) async {
    if (_apiService == null || currentContact == null) return '请先选择联系人';
    if (content.trim().isEmpty) return '消息不能为空';

    try {
      final result = await _apiService!.sendMessage(
        receiverId: currentContact!.userId,
        content: content,
        msgType: msgType,
      );
      if (result.isSuccess && result.data != null) {
        final msg = PrivateChatMsgVO.fromJson(result.data);
        _handleNewMessage(msg);
        addLog('send', '📤 发送消息: $content');
        return null;
      } else {
        return result.msg;
      }
    } catch (e) {
      return '发送失败: $e';
    }
  }

  /// 撤回消息
  Future<String?> recallMessage(int msgId) async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.recallMessage(msgId);
      if (result.isSuccess && result.data != null) {
        final msg = PrivateChatMsgVO.fromJson(result.data);
        _updateMessageInList(msg);
        _updateContactLastMsg(msg, '[消息已撤回]');
        addLog('info', '✅ 消息 #$msgId 撤回成功');
        return null;
      } else {
        return result.msg;
      }
    } catch (e) {
      return '撤回失败: $e';
    }
  }

  /// 删除消息
  Future<String?> deleteMessage(int msgId) async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.deleteMessage(msgId);
      if (result.isSuccess) {
        currentMessages.removeWhere((m) => m.msgId == msgId);
        addLog('info', '✅ 消息 #$msgId 已删除');
        notifyListeners();
        return null;
      } else {
        return result.msg;
      }
    } catch (e) {
      return '删除失败: $e';
    }
  }

  /// 处理 WebSocket 收到的消息
  void _onWsMessage(PrivateChatMsgVO msg) {
    final otherUserId = msg.senderId == myUserId ? msg.receiverId : msg.senderId;
    if (otherUserId == null) return;

    _addLogSilent('info', '📨 WS 消息处理: msgId=${msg.msgId}, from=${msg.senderId}, to=${msg.receiverId}, status=${msg.msgStatus}');

    // 撤回通知
    if (msg.isRecalled) {
      _updateMessageInListSilent(msg);
      _updateContactLastMsgSilent(msg, '[消息已撤回]');
      messageVersion++;
      notifyListeners();
      return;
    }

    _handleNewMessageSilent(msg);

    // 如果不是当前聊天对象发的，增加未读计数
    if (currentContact == null || currentContact!.userId != otherUserId) {
      if (msg.senderId != myUserId) {
        final matchedContacts = contacts.where((c) => c.userId == otherUserId).toList();
        if (matchedContacts.isNotEmpty) {
          matchedContacts.first.unreadCount++;
        }
      }
    } else {
      // 当前正在和对方聊天，自动已读
      if (msg.senderId != myUserId && currentContact!.sessionId != null) {
        _apiService?.markAsRead(currentContact!.sessionId!);
      }
    }

    // 所有状态修改完毕后，统一通知 UI 刷新
    messageVersion++;
    notifyListeners();
  }

  /// 处理新消息（带通知，供 REST 调用使用）
  void _handleNewMessage(PrivateChatMsgVO msg) {
    _handleNewMessageSilent(msg);
    messageVersion++;
    notifyListeners();
  }

  /// 处理新消息（不通知，供 WS 批量操作后统一通知使用）
  void _handleNewMessageSilent(PrivateChatMsgVO msg) {
    final otherUserId = msg.senderId == myUserId ? msg.receiverId : msg.senderId;
    if (otherUserId == null) return;

    // 查找联系人
    var contactIndex = contacts.indexWhere((c) => c.userId == otherUserId);
    if (contactIndex == -1) {
      // 新联系人
      final contact = Contact(
        userId: otherUserId,
        username: '用户 $otherUserId',
        sessionId: msg.sessionId,
        lastMsg: msg.content ?? '',
        lastMsgTime: msg.sendTime,
      );
      contacts.insert(0, contact);
    } else {
      final contact = contacts[contactIndex];
      contact.lastMsg = msg.content ?? '';
      contact.lastMsgTime = msg.sendTime;
      if (contact.sessionId == null) contact.sessionId = msg.sessionId;
      // 置顶
      contacts.removeAt(contactIndex);
      contacts.insert(0, contact);
    }

    // 如果是当前聊天对象的消息，插入到消息列表头部（降序，最新在前）
    if (currentContact != null && currentContact!.userId == otherUserId) {
      // 去重
      if (!currentMessages.any((m) => m.msgId == msg.msgId)) {
        currentMessages.insert(0, msg);
      }
    }
  }

  /// 更新消息列表中的消息（带通知）
  void _updateMessageInList(PrivateChatMsgVO msg) {
    _updateMessageInListSilent(msg);
    messageVersion++;
    notifyListeners();
  }

  /// 更新消息列表中的消息（不通知）
  void _updateMessageInListSilent(PrivateChatMsgVO msg) {
    final index = currentMessages.indexWhere((m) => m.msgId == msg.msgId);
    if (index != -1) {
      currentMessages[index] = msg;
    }
  }

  void _updateContactLastMsg(PrivateChatMsgVO msg, String lastMsg) {
    _updateContactLastMsgSilent(msg, lastMsg);
    notifyListeners();
  }

  void _updateContactLastMsgSilent(PrivateChatMsgVO msg, String lastMsg) {
    final otherUserId = msg.senderId == myUserId ? msg.receiverId : msg.senderId;
    final matchedContacts = contacts.where((c) => c.userId == otherUserId).toList();
    if (matchedContacts.isNotEmpty) {
      matchedContacts.first.lastMsg = lastMsg;
    }
  }

  // ======== 用户设置 ========

  Future<String?> loadSetting() async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.getSetting();
      if (result.isSuccess && result.data != null) {
        userSetting = UserSetting.fromJson(result.data);
        notifyListeners();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '加载设置失败: $e';
    }
  }

  Future<String?> toggleEnable(bool value) async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.updateEnable(value ? 1 : 0);
      if (result.isSuccess) {
        userSetting?.isEnable = value ? 1 : 0;
        notifyListeners();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '更新失败: $e';
    }
  }

  Future<String?> toggleStranger(bool value) async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.updateStranger(value ? 1 : 0);
      if (result.isSuccess) {
        userSetting?.isAcceptStranger = value ? 1 : 0;
        notifyListeners();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '更新失败: $e';
    }
  }

  Future<String?> blockUser(int blockUserId) async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.blockUser(blockUserId);
      if (result.isSuccess) {
        await loadSetting();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '拉黑失败: $e';
    }
  }

  Future<String?> unblockUser(int unblockUserId) async {
    if (_apiService == null) return '未登录';
    try {
      final result = await _apiService!.unblockUser(unblockUserId);
      if (result.isSuccess) {
        await loadSetting();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '取消拉黑失败: $e';
    }
  }

  // ======== 日志 ========

  /// 总未读消息数
  int get totalUnreadCount => contacts.fold(0, (sum, c) => sum + c.unreadCount);

  /// 静默添加日志（不触发 notifyListeners，用于 WS 消息批量处理中）
  void _addLogSilent(String type, String message) {
    logs.add(LogEntry(
      type: type,
      message: message,
      time: DateTime.now(),
    ));
    if (logs.length > 500) {
      logs.removeRange(0, logs.length - 500);
    }
  }

  void addLog(String type, String message) {
    logs.add(LogEntry(
      type: type,
      message: message,
      time: DateTime.now(),
    ));
    // 限制日志数量
    if (logs.length > 500) {
      logs.removeRange(0, logs.length - 500);
    }
    notifyListeners();
  }

  void clearLogs() {
    logs.clear();
    addLog('info', '日志已清空');
  }

  @override
  void dispose() {
    _wsService?.dispose();
    super.dispose();
  }
}

/// 日志条目
class LogEntry {
  final String type;
  final String message;
  final DateTime time;

  LogEntry({required this.type, required this.message, required this.time});
}
