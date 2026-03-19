import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';

/// ======================== 私聊 Dio 网络实例 ========================
/// 所有私聊相关的 HTTP 请求统一通过此 Dio 实例发送。
/// baseUrl 对应后端的私聊模块根路径。
///
/// 鉴权方式：通过 token 请求头传递 JWT
class PrivateChatDio extends DioAbstract {
  // ========== 地址配置 ==========
  // 线上地址（部署后切换）：
  // String baseUrl = '${EnvConfig.QNHD}api/v1/f/private-chat/';
  //
  // 本地调试地址：
  //   - Android 模拟器用 10.0.2.2 访问宿主机 localhost
  //   - iOS 模拟器直接用 localhost
  //   - 真机测试需替换为电脑局域网 IP
  @override
  String baseUrl = 'http://10.0.2.2:8092/api/v1/f/private-chat/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 使用 LakeTokenManager 获取 JWT token（与 message_service 等模块一致）
        options.headers['token'] = await LakeTokenManager().token;
        PrivateChatLogger.log(
          'HTTP',
          '→ ${options.method} ${options.path}',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 统一处理后端 Result 包装：code=200 表示成功，其他视为业务异常
        final code = response.data['code'] ?? 0;
        final msg = response.data['msg'] ?? '';
        PrivateChatLogger.log(
          'HTTP',
          '← ${response.requestOptions.method} '
          '${response.requestOptions.path} [code=$code] $msg',
        );
        switch (code) {
          case 200:
            return handler.next(response);
          default:
            return handler.reject(
              WpyDioException(error: msg.isNotEmpty ? msg : '未知错误'),
              true,
            );
        }
      },
      onError: (error, handler) {
        PrivateChatLogger.log(
          'HTTP',
          '✖ ${error.requestOptions.method} '
          '${error.requestOptions.path} ERROR: ${error.message}',
        );
        return handler.next(error);
      },
    ),
  ];
}

final privateChatDio = PrivateChatDio();

/// ======================== 私聊日志记录器 ========================
/// 用于在调试日志页面显示 HTTP / WebSocket 请求日志，
/// 方便开发阶段排查问题。生产环境可关闭或限制日志量。
class PrivateChatLogger {
  static final List<String> _logs = [];
  static const int _maxLogs = 500;

  static List<String> get logs => List.unmodifiable(_logs);

  /// 添加一条日志，自动附加时间戳
  static void log(String tag, String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
    final entry = '[$timeStr] [$tag] $message';
    _logs.add(entry);
    if (_logs.length > _maxLogs) _logs.removeAt(0);
  }

  static void clear() => _logs.clear();
}

/// ======================== 私聊网络请求服务 ========================
/// 封装所有私聊模块的 HTTP API 调用。
///
/// 接口文档版本：v2.3
///   - 会话在首次发送消息时自动创建（移除了 session/create 接口）
///   - 聊天记录和已读接口改用 targetUserId 参数
class PrivateChatService {
  // ==================== 消息相关 ====================

  /// 发送私信
  ///
  /// POST /message/send
  /// - 首次发送时自动创建会话，无需提前调用创建接口
  /// - 后端会进行设置校验（开关、拉黑、陌生人策略）
  /// - 发送成功后会通过 WebSocket 实时推送给接收方
  static Future<PrivateChatApiResult> sendMessage({
    required int receiverId,
    required String content,
    int msgType = 1,
  }) async {
    try {
      final response = await privateChatDio.postNoRetry(
        'message/send',
        data: {
          'receiver_id': receiverId,
          'content': content,
          'msg_type': msgType,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 获取聊天记录（分页）
  ///
  /// GET /message/history?target_user_id=&page=&page_size=
  /// - 无需提前知道 sessionId，后端根据双方用户 ID 自动查找
  /// - 如果双方从未聊过，返回空数组
  /// - 按 send_time DESC 排序（最新消息在前）
  static Future<PrivateChatApiResult> getChatHistory({
    required int targetUserId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await privateChatDio.get(
        'message/history',
        queryParameters: {
          'target_user_id': targetUserId,
          'page': page,
          'page_size': pageSize,
        },
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 标记消息已读
  ///
  /// POST /message/read?target_user_id=
  /// - 进入聊天界面时调用
  /// - 批量将对方发给自己的未读消息更新为已读（msg_status: 0 → 1）
  /// - 如果双方从未聊过，返回影响 0 条
  static Future<PrivateChatApiResult> markAsRead(int targetUserId) async {
    try {
      final response = await privateChatDio.post(
        'message/read',
        queryParameters: {'target_user_id': targetUserId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 撤回消息
  ///
  /// POST /message/recall?msg_id=
  /// - 仅消息发送者可撤回，发送后 2 分钟内可撤回
  /// - 撤回后 msg_status=2，content 替换为 [消息已撤回]
  /// - 通过 WebSocket 实时通知接收方
  static Future<PrivateChatApiResult> recallMessage(int msgId) async {
    try {
      final response = await privateChatDio.post(
        'message/recall',
        queryParameters: {'msg_id': msgId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 删除消息（单方删除）
  ///
  /// POST /message/delete?msg_id=
  /// - 仅影响当前用户视角，对方仍可见
  static Future<PrivateChatApiResult> deleteMessage(int msgId) async {
    try {
      final response = await privateChatDio.post(
        'message/delete',
        queryParameters: {'msg_id': msgId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 统计所有会话未读消息数
  ///
  /// GET /message/unread-count
  static Future<PrivateChatApiResult> getUnreadCount() async {
    try {
      final response = await privateChatDio.get('message/unread-count');
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  // ==================== 会话相关 ====================

  /// 获取会话列表
  ///
  /// GET /sessions
  /// - 仅返回有实际消息的会话（空会话不出现）
  /// - 按 last_msg_time 倒序排列
  static Future<PrivateChatApiResult> getSessions() async {
    try {
      final response = await privateChatDio.get('sessions');
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 删除会话（逻辑删除）
  ///
  /// POST /session/delete?session_id=
  /// - 逻辑删除（is_deleted=1），不删除历史消息
  /// - 当有新消息发送时，会话会自动恢复
  static Future<PrivateChatApiResult> deleteSession(int sessionId) async {
    try {
      final response = await privateChatDio.post(
        'session/delete',
        queryParameters: {'session_id': sessionId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  // ==================== 用户设置 ====================

  /// 获取私信设置
  ///
  /// GET /setting
  /// - 返回私信开关、陌生人策略、拉黑列表
  static Future<PrivateChatApiResult> getSetting() async {
    try {
      final response = await privateChatDio.get('setting');
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 更新私信开关
  ///
  /// POST /setting/enable?is_enable=0|1
  static Future<PrivateChatApiResult> updateEnable(int isEnable) async {
    try {
      final response = await privateChatDio.post(
        'setting/enable',
        queryParameters: {'is_enable': isEnable},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 更新陌生人策略
  ///
  /// POST /setting/stranger?is_accept_stranger=0|1
  /// - 陌生人判定：双方之间没有历史会话记录
  static Future<PrivateChatApiResult> updateStranger(
      int isAcceptStranger) async {
    try {
      final response = await privateChatDio.post(
        'setting/stranger',
        queryParameters: {'is_accept_stranger': isAcceptStranger},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 拉黑用户
  ///
  /// POST /setting/block?block_user_id=
  /// - 拉黑后双方均无法互发私信
  static Future<PrivateChatApiResult> blockUser(int blockUserId) async {
    try {
      final response = await privateChatDio.post(
        'setting/block',
        queryParameters: {'block_user_id': blockUserId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 取消拉黑
  ///
  /// POST /setting/unblock?unblock_user_id=
  static Future<PrivateChatApiResult> unblockUser(int unblockUserId) async {
    try {
      final response = await privateChatDio.post(
        'setting/unblock',
        queryParameters: {'unblock_user_id': unblockUserId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  // ==================== 用户资料 ====================

  /// 获取用户资料（昵称、头像）
  ///
  /// GET /api/v1/f/user/profile?user_id=
  /// - 注意：此接口不在 private-chat 模块下，使用独立 Dio 实例访问
  /// - 返回结构：{ code: 200, data: { user_info: { nickname, avatar, ... } } }
  static Future<PrivateChatApiResult> getUserProfile(int userId) async {
    try {
      final response = await _userProfileDio.get(
        'user/profile',
        queryParameters: {'user_id': userId},
      );
      // 提取 user_info 层级，让调用方直接获取 nickname / avatar
      final data = response.data;
      final code = data['code'] ?? 0;
      final msg = data['msg'] ?? '';
      if (code == 200 && data['data'] != null) {
        final userInfo = data['data']['user_info'];
        return PrivateChatApiResult(code: 200, msg: msg, data: userInfo);
      }
      return PrivateChatApiResult(code: code, msg: msg.isNotEmpty ? msg : '获取用户资料失败');
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 获取调试 Token（开发环境）
  ///
  /// GET /api/v1/f/auth/chat-debug-token?userId=
  static Future<PrivateChatApiResult> getChatDebugToken(int userId) async {
    try {
      final response = await _userProfileDio.get(
        'auth/chat-debug-token',
        queryParameters: {'userId': userId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }
}

/// 用于访问 /api/v1/f/user/profile 等非 private-chat 模块接口的 Dio 实例
final _userProfileDio = _UserProfileDio();

class _UserProfileDio extends DioAbstract {
  // 线上地址（部署后切换）：
  // String baseUrl = '${EnvConfig.QNHD}api/v1/f/';
  @override
  String baseUrl = 'http://10.0.2.2:8092/api/v1/f/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['token'] = await LakeTokenManager().token;
        return handler.next(options);
      },
    ),
  ];
}
