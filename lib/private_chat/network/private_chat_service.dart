import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';

/// 私聊日志记录器
class PrivateChatLogger {
  static final List<String> _logs = [];
  static int _maxLogs = 500;

  static List<String> get logs => List.unmodifiable(_logs);

  static void log(String tag, String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
    final entry = '[$timeStr] [$tag] $message';
    _logs.add(entry);
    if (_logs.length > _maxLogs) _logs.removeAt(0);
  }

  static void clear() => _logs.clear();
}

/// 私聊网络请求 Dio 实例
class PrivateChatDio extends DioAbstract {
  // TODO: 请根据实际后端地址修改此 baseUrl
  @override
  // 线上地址（部署后切换）
  // String baseUrl = '${EnvConfig.QNHD}private-chat/';
  // 本地调试地址（Android 模拟器用 10.0.2.2 访问宿主机 localhost）
  String baseUrl = 'http://10.0.2.2:8081/private-chat/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      // 后端使用 X-Test-User-Id 请求头识别用户身份
      final userId = CommonPreferences.lakeUid.value;
      options.headers['X-Test-User-Id'] = userId;
      PrivateChatLogger.log(
        'HTTP',
        '→ ${options.method} ${options.path} [userId=$userId]',
      );
      return handler.next(options);
    }, onResponse: (response, handler) {
      final code = response.data['code'] ?? 0;
      final msg = response.data['msg'] ?? '';
      PrivateChatLogger.log(
        'HTTP',
        '← ${response.requestOptions.method} ${response.requestOptions.path} [code=$code] $msg',
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
    }, onError: (error, handler) {
      PrivateChatLogger.log(
        'HTTP',
        '✖ ${error.requestOptions.method} ${error.requestOptions.path} ERROR: ${error.message}',
      );
      return handler.next(error);
    }),
  ];
}

final privateChatDio = PrivateChatDio();

/// 私聊网络请求服务
class PrivateChatService {
  /// 发送私信
  static Future<PrivateChatApiResult> sendMessage({
    required int receiverId,
    required String content,
    int msgType = 1,
  }) async {
    try {
      final response = await privateChatDio.post(
        'message/send',
        data: {
          'receiverId': receiverId,
          'content': content,
          'msgType': msgType,
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

  /// 获取会话列表
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

  /// 获取聊天记录
  static Future<PrivateChatApiResult> getChatHistory({
    required int sessionId,
    required int userIdB,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await privateChatDio.get(
        'message/history',
        queryParameters: {
          'sessionId': sessionId,
          'userIdB': userIdB,
          'page': page,
          'pageSize': pageSize,
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

  /// 标记会话已读
  static Future<PrivateChatApiResult> markAsRead(int sessionId) async {
    try {
      final response = await privateChatDio.post(
        'message/read',
        queryParameters: {'sessionId': sessionId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 创建/获取会话
  static Future<PrivateChatApiResult> createSession(int targetUserId) async {
    try {
      final response = await privateChatDio.post(
        'session/create',
        queryParameters: {'targetUserId': targetUserId},
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
  static Future<PrivateChatApiResult> recallMessage(int msgId) async {
    try {
      final response = await privateChatDio.post(
        'message/recall',
        queryParameters: {'msgId': msgId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 删除消息
  static Future<PrivateChatApiResult> deleteMessage(int msgId) async {
    try {
      final response = await privateChatDio.post(
        'message/delete',
        queryParameters: {'msgId': msgId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 获取用户设置
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
  static Future<PrivateChatApiResult> updateEnable(int isEnable) async {
    try {
      final response = await privateChatDio.post(
        'setting/enable',
        queryParameters: {'isEnable': isEnable},
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
  static Future<PrivateChatApiResult> updateStranger(
      int isAcceptStranger) async {
    try {
      final response = await privateChatDio.post(
        'setting/stranger',
        queryParameters: {'isAcceptStranger': isAcceptStranger},
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
  static Future<PrivateChatApiResult> blockUser(int blockUserId) async {
    try {
      final response = await privateChatDio.post(
        'setting/block',
        queryParameters: {'blockUserId': blockUserId},
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
  static Future<PrivateChatApiResult> unblockUser(int unblockUserId) async {
    try {
      final response = await privateChatDio.post(
        'setting/unblock',
        queryParameters: {'unblockUserId': unblockUserId},
      );
      return PrivateChatApiResult.fromJson(response.data);
    } on DioException catch (e) {
      return PrivateChatApiResult(
        code: -1,
        msg: e.error?.toString() ?? '网络请求失败',
      );
    }
  }

  /// 获取用户资料（昵称、头像）
  static Future<PrivateChatApiResult> getUserProfile(int userId) async {
    try {
      final response = await privateChatDio.get(
        'user/profile',
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
