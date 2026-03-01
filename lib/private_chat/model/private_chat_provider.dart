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

  /// 用户资料缓存 { userId: { 'nickname': ..., 'avatar': ... } }
  final Map<int, Map<String, String>> _userProfileCache = {};

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
    PrivateChatLogger.log('Provider', '初始化私聊服务，lakeUid=$uidStr');
    if (uidStr.isEmpty) {
      PrivateChatLogger.log('Provider', '❌ lakeUid 为空，无法初始化');
      return;
    }
    final uid = int.tryParse(uidStr);
    if (uid == null || uid <= 0) {
      PrivateChatLogger.log('Provider', '❌ lakeUid 解析失败: $uidStr');
      return;
    }

    _myUserId = uid;
    PrivateChatLogger.log('Provider', '✅ myUserId=$uid');

    _wsService = PrivateChatWebSocketService();
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
  /// 调用后端 sessions 接口，将返回的 ChatSession 映射为本地 PrivateChatContact 列表
  Future<void> fetchContacts() async {
    if (_myUserId == null) return;
    PrivateChatLogger.log('Provider', '获取会话列表...');
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
        PrivateChatLogger.log('Provider', '✅ 获取到 ${_contacts.length} 个会话');
        notifyListeners();
        // 异步获取所有联系人的用户资料（昵称、头像）
        _fetchUserProfilesForContacts();
      } else {
        PrivateChatLogger.log('Provider', '❌ 获取会话失败: ${result.msg}');
      }
    } catch (e) {
      PrivateChatLogger.log('Provider', '❌ 获取会话异常: $e');
    }
  }

  /// 添加新联系人（仅校验，不插入会话列表）
  /// v2.1：点击私信按钮时不创建会话，只有发送消息后会话才出现在消息中心。
  /// 返回错误信息（null 表示无错误）
  String? validateContact(int targetUserId) {
    if (_myUserId == null) return '请先登录';
    if (targetUserId == _myUserId) return '不能添加自己';
    return null;
  }

  /// 删除会话
  /// 调用后端 session/delete 接口，成功后从本地列表移除该联系人
  Future<String?> deleteSessionFromList(int sessionId) async {
    try {
      final result = await PrivateChatService.deleteSession(sessionId);
      if (result.isSuccess) {
        _contacts.removeWhere((c) => c.sessionId == sessionId);
        // 如果删除的是当前聊天对象，清空聊天内容
        if (_currentContact?.sessionId == sessionId) {
          _currentContact = null;
          _currentMessages = [];
        }
        notifyListeners();
        PrivateChatLogger.log('Provider', '✅ 删除会话成功 sessionId=$sessionId');
        return null;
      }
      return result.msg;
    } catch (e) {
      PrivateChatLogger.log('Provider', '❌ 删除会话异常: $e');
      return '删除会话失败: $e';
    }
  }

  /// 选择联系人并加载聊天记录
  /// 进入聊天界面时调用，同时标记对方消息为已读
  Future<void> selectContact(PrivateChatContact contact) async {
    _currentContact = contact;
    contact.unreadCount = 0;
    _currentMessages = [];
    notifyListeners();

    // 异步获取用户资料（昵称、头像），获取后自动更新 UI
    _fetchAndApplyUserProfile(contact);

    // v2.0：使用 targetUserId 标记已读，无需 sessionId
    try {
      await PrivateChatService.markAsRead(contact.userId);
    } catch (_) {}

    await loadHistory();
  }

  /// 退出聊天界面时清除当前联系人
  void clearCurrentContact() {
    _currentContact = null;
    _currentMessages = [];
    notifyListeners();
  }

  /// 加载聊天记录
  /// v2.0：使用 targetUserId 查询，无需提前知道 sessionId
  Future<void> loadHistory({int page = 1, int pageSize = 50}) async {
    if (_currentContact == null) {
      _currentMessages = [];
      notifyListeners();
      return;
    }

    try {
      final result = await PrivateChatService.getChatHistory(
        targetUserId: _currentContact!.userId,
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
        _refreshContactLastMsg();
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
        _refreshContactLastMsg();
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
      // 在对应的聊天界面内，更新消息列表后刷新摘要
      if (_currentContact != null && _currentContact!.userId == otherUserId) {
        _updateMessageInList(msg);
        _refreshContactLastMsg();
      } else {
        // 不在聊天界面，直接更新联系人 lastMsg
        _updateContactLastMsgByUserId(otherUserId, '[消息已撤回]');
      }
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
      // 当前正在和对方聊天，自动标记已读（v2.0 使用 targetUserId）
      if (msg.senderId != _myUserId) {
        PrivateChatService.markAsRead(_currentContact!.userId);
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
        username: _userProfileCache[otherUserId]?['nickname'] ?? '用户 $otherUserId',
        avatar: _userProfileCache[otherUserId]?['avatar'] ?? '',
        sessionId: msg.sessionId,
        lastMsg: msg.content ?? '',
        lastMsgTime: msg.sendTime,
      );
      _contacts.insert(0, contact);
      // 如果缓存中没有该用户资料，异步获取
      if (!_userProfileCache.containsKey(otherUserId)) {
        _fetchAndApplyUserProfile(contact);
      }
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

  /// 通过对方 userId 直接更新联系人的 lastMsg（不依赖 _currentContact）
  void _updateContactLastMsgByUserId(int otherUserId, String lastMsg) {
    final matched =
        _contacts.where((c) => c.userId == otherUserId).toList();
    if (matched.isNotEmpty) {
      matched.first.lastMsg = lastMsg;
    }
    notifyListeners();
  }

  /// 根据当前消息列表刷新联系人的最后一条消息摘要
  void _refreshContactLastMsg() {
    if (_currentContact == null) return;
    final matched =
        _contacts.where((c) => c.userId == _currentContact!.userId).toList();
    if (matched.isEmpty) return;
    final contact = matched.first;

    if (_currentMessages.isEmpty) {
      contact.lastMsg = '';
      contact.lastMsgTime = null;
      notifyListeners();
      return;
    }

    // _currentMessages 按时间倒序排列，第一条即最新消息
    final latest = _currentMessages.first;
    if (latest.isRecalled) {
      contact.lastMsg = '[消息已撤回]';
    } else {
      contact.lastMsg = latest.content ?? '';
    }
    contact.lastMsgTime = latest.sendTime;
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

  // ======== 用户资料获取 ========

  /// 为所有联系人异步获取用户资料
  Future<void> _fetchUserProfilesForContacts() async {
    for (final contact in _contacts) {
      await _fetchAndApplyUserProfile(contact);
    }
  }

  /// 获取单个用户资料并应用到联系人
  Future<void> _fetchAndApplyUserProfile(PrivateChatContact contact) async {
    // 先查缓存
    if (_userProfileCache.containsKey(contact.userId)) {
      final cached = _userProfileCache[contact.userId]!;
      contact.username = cached['nickname'] ?? contact.username;
      contact.avatar = cached['avatar'] ?? '';
      notifyListeners();
      return;
    }

    try {
      final result = await PrivateChatService.getUserProfile(contact.userId);
      if (result.isSuccess && result.data != null) {
        final nickname = result.data['nickname']?.toString() ?? '';
        final avatar = result.data['avatar']?.toString() ?? '';
        // 存入缓存
        _userProfileCache[contact.userId] = {
          'nickname': nickname,
          'avatar': avatar,
        };
        if (nickname.isNotEmpty) contact.username = nickname;
        if (avatar.isNotEmpty) contact.avatar = avatar;
        notifyListeners();
        PrivateChatLogger.log('Provider', '✅ 获取用户资料 uid=${contact.userId} nickname=$nickname');
      } else {
        PrivateChatLogger.log('Provider', '⚠️ 获取用户资料失败 uid=${contact.userId}: ${result.msg}');
      }
    } catch (e) {
      PrivateChatLogger.log('Provider', '⚠️ 获取用户资料异常 uid=${contact.userId}: $e');
    }
  }

  /// 根据 userId 获取缓存的用户资料
  Map<String, String>? getUserProfileFromCache(int userId) {
    return _userProfileCache[userId];
  }

  @override
  void dispose() {
    _wsService?.dispose();
    super.dispose();
  }
}
