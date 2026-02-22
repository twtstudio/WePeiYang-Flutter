import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/network/private_chat_service.dart';
import 'package:we_pei_yang_flutter/private_chat/network/private_chat_websocket_service.dart';

/// 私聊状态管理 Provider
class PrivateChatProvider extends ChangeNotifier {
  // ======== 状态 ========
  int? _myUserId;
  bool _isConnected = false;
  PrivateChatWebSocketService? _wsService;

  List<PrivateChatContact> _contacts = [];
  PrivateChatContact? _currentContact;
  List<PrivateChatMsgVO> _currentMessages = [];
  PrivateChatUserSetting? _userSetting;

  /// 消息版本号，每次消息列表变化时递增
  int _messageVersion = 0;

  // ======== Getters ========
  int? get myUserId => _myUserId;
  bool get isConnected => _isConnected;
  List<PrivateChatContact> get contacts => _contacts;
  PrivateChatContact? get currentContact => _currentContact;
  List<PrivateChatMsgVO> get currentMessages => _currentMessages;
  PrivateChatUserSetting? get userSetting => _userSetting;
  int get messageVersion => _messageVersion;

  /// 总未读消息数
  int get totalUnreadCount =>
      _contacts.fold(0, (sum, c) => sum + c.unreadCount);

  // ======== 初始化/连接 ========

  /// 初始化私聊服务（登录后调用）
  Future<void> init() async {
    // 从 CommonPreferences 获取当前用户 ID
    final uidStr = CommonPreferences.lakeUid.value;
    if (uidStr.isEmpty) return;
    final uid = int.tryParse(uidStr);
    if (uid == null || uid <= 0) return;

    _myUserId = uid;

    _wsService = PrivateChatWebSocketService(userId: uid);
    _wsService!.onMessageReceived = _onWsMessage;
    _wsService!.onConnectionChanged = (connected) {
      _isConnected = connected;
      notifyListeners();
    };
    _wsService!.connect();

    await fetchContacts();
    notifyListeners();
  }

  /// 断开连接
  void disconnect() {
    _wsService?.disconnect();
    _wsService?.dispose();
    _wsService = null;
    _isConnected = false;
    _contacts = [];
    _currentContact = null;
    _currentMessages = [];
    _userSetting = null;
    notifyListeners();
  }

  // ======== 会话管理 ========

  /// 获取会话列表
  Future<void> fetchContacts() async {
    if (_myUserId == null) return;
    try {
      final result = await PrivateChatService.getSessions();
      if (result.isSuccess && result.data != null) {
        _contacts = (result.data as List).map((json) {
          final session = ChatSession.fromJson(json);
          final otherId = session.getOtherUserId(_myUserId!);
          return PrivateChatContact(
            userId: otherId,
            username: '用户 $otherId',
            sessionId: session.sessionId,
            lastMsg: session.lastMsg ?? '',
            lastMsgTime: session.lastMsgTime,
            unreadCount: session.unreadCount,
          );
        }).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  /// 添加新联系人（创建会话）
  Future<String?> addContact(int targetUserId) async {
    if (_myUserId == null) return '请先登录';
    if (targetUserId == _myUserId) return '不能添加自己';

    final existing =
        _contacts.where((c) => c.userId == targetUserId).toList();
    if (existing.isNotEmpty) {
      await selectContact(existing.first);
      return null;
    }

    try {
      final result = await PrivateChatService.createSession(targetUserId);
      if (result.isSuccess && result.data != null) {
        final contact = PrivateChatContact(
          userId: targetUserId,
          username: '用户 $targetUserId',
          sessionId: result.data['sessionId'],
        );
        _contacts.insert(0, contact);
        notifyListeners();
        return null;
      } else {
        return result.msg;
      }
    } catch (e) {
      return '创建会话失败: $e';
    }
  }

  /// 选择联系人并加载聊天记录
  Future<void> selectContact(PrivateChatContact contact) async {
    _currentContact = contact;
    contact.unreadCount = 0;
    _currentMessages = [];
    notifyListeners();

    if (contact.sessionId != null) {
      try {
        await PrivateChatService.markAsRead(contact.sessionId!);
      } catch (_) {}
    }

    await loadHistory();
  }

  /// 退出聊天界面时清除当前联系人
  void clearCurrentContact() {
    _currentContact = null;
    _currentMessages = [];
    notifyListeners();
  }

  /// 加载聊天记录
  Future<void> loadHistory({int page = 1, int pageSize = 50}) async {
    if (_currentContact == null || _currentContact!.sessionId == null) {
      _currentMessages = [];
      notifyListeners();
      return;
    }

    try {
      final result = await PrivateChatService.getChatHistory(
        sessionId: _currentContact!.sessionId!,
        userIdB: _currentContact!.userId,
        page: page,
        pageSize: pageSize,
      );
      if (result.isSuccess && result.data != null) {
        _currentMessages = (result.data as List)
            .map((json) => PrivateChatMsgVO.fromJson(json))
            .toList();
        _messageVersion++;
        notifyListeners();
      }
    } catch (_) {}
  }

  // ======== 消息收发 ========

  /// 发送消息
  Future<String?> sendMessage(String content, {int msgType = 1}) async {
    if (_currentContact == null) return '请先选择联系人';
    if (content.trim().isEmpty) return '消息不能为空';

    try {
      final result = await PrivateChatService.sendMessage(
        receiverId: _currentContact!.userId,
        content: content,
        msgType: msgType,
      );
      if (result.isSuccess && result.data != null) {
        final msg = PrivateChatMsgVO.fromJson(result.data);
        _handleNewMessage(msg);
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
    try {
      final result = await PrivateChatService.recallMessage(msgId);
      if (result.isSuccess && result.data != null) {
        final msg = PrivateChatMsgVO.fromJson(result.data);
        _updateMessageInList(msg);
        _updateContactLastMsg(msg, '[消息已撤回]');
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
    try {
      final result = await PrivateChatService.deleteMessage(msgId);
      if (result.isSuccess) {
        _currentMessages.removeWhere((m) => m.msgId == msgId);
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
    final otherUserId =
        msg.senderId == _myUserId ? msg.receiverId : msg.senderId;
    if (otherUserId == null) return;

    // 撤回通知
    if (msg.isRecalled) {
      _updateMessageInList(msg);
      _updateContactLastMsg(msg, '[消息已撤回]');
      return;
    }

    _handleNewMessageSilent(msg);

    // 如果不是当前聊天对象发的，增加未读计数
    if (_currentContact == null || _currentContact!.userId != otherUserId) {
      if (msg.senderId != _myUserId) {
        final matched =
            _contacts.where((c) => c.userId == otherUserId).toList();
        if (matched.isNotEmpty) {
          matched.first.unreadCount++;
        }
      }
    } else {
      // 当前正在和对方聊天，自动已读
      if (msg.senderId != _myUserId && _currentContact!.sessionId != null) {
        PrivateChatService.markAsRead(_currentContact!.sessionId!);
      }
    }

    _messageVersion++;
    notifyListeners();
  }

  void _handleNewMessage(PrivateChatMsgVO msg) {
    _handleNewMessageSilent(msg);
    _messageVersion++;
    notifyListeners();
  }

  void _handleNewMessageSilent(PrivateChatMsgVO msg) {
    final otherUserId =
        msg.senderId == _myUserId ? msg.receiverId : msg.senderId;
    if (otherUserId == null) return;

    var contactIndex = _contacts.indexWhere((c) => c.userId == otherUserId);
    if (contactIndex == -1) {
      final contact = PrivateChatContact(
        userId: otherUserId,
        username: '用户 $otherUserId',
        sessionId: msg.sessionId,
        lastMsg: msg.content ?? '',
        lastMsgTime: msg.sendTime,
      );
      _contacts.insert(0, contact);
    } else {
      final contact = _contacts[contactIndex];
      contact.lastMsg = msg.content ?? '';
      contact.lastMsgTime = msg.sendTime;
      if (contact.sessionId == null) contact.sessionId = msg.sessionId;
      _contacts.removeAt(contactIndex);
      _contacts.insert(0, contact);
    }

    // 如果是当前聊天对象的消息，插入到消息列表头部
    if (_currentContact != null && _currentContact!.userId == otherUserId) {
      if (!_currentMessages.any((m) => m.msgId == msg.msgId)) {
        _currentMessages.insert(0, msg);
      }
    }
  }

  void _updateMessageInList(PrivateChatMsgVO msg) {
    final index = _currentMessages.indexWhere((m) => m.msgId == msg.msgId);
    if (index != -1) {
      _currentMessages[index] = msg;
    }
    _messageVersion++;
    notifyListeners();
  }

  void _updateContactLastMsg(PrivateChatMsgVO msg, String lastMsg) {
    final otherUserId =
        msg.senderId == _myUserId ? msg.receiverId : msg.senderId;
    final matched =
        _contacts.where((c) => c.userId == otherUserId).toList();
    if (matched.isNotEmpty) {
      matched.first.lastMsg = lastMsg;
    }
    notifyListeners();
  }

  // ======== 用户设置 ========

  Future<String?> loadSetting() async {
    try {
      final result = await PrivateChatService.getSetting();
      if (result.isSuccess && result.data != null) {
        _userSetting = PrivateChatUserSetting.fromJson(result.data);
        notifyListeners();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '加载设置失败: $e';
    }
  }

  Future<String?> toggleEnable(bool value) async {
    try {
      final result =
          await PrivateChatService.updateEnable(value ? 1 : 0);
      if (result.isSuccess) {
        _userSetting?.isEnable = value ? 1 : 0;
        notifyListeners();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '更新失败: $e';
    }
  }

  Future<String?> toggleStranger(bool value) async {
    try {
      final result =
          await PrivateChatService.updateStranger(value ? 1 : 0);
      if (result.isSuccess) {
        _userSetting?.isAcceptStranger = value ? 1 : 0;
        notifyListeners();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '更新失败: $e';
    }
  }

  Future<String?> blockUser(int blockUserId) async {
    try {
      final result = await PrivateChatService.blockUser(blockUserId);
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
    try {
      final result = await PrivateChatService.unblockUser(unblockUserId);
      if (result.isSuccess) {
        await loadSetting();
        return null;
      }
      return result.msg;
    } catch (e) {
      return '取消拉黑失败: $e';
    }
  }

  @override
  void dispose() {
    _wsService?.dispose();
    super.dispose();
  }
}
