import 'dart:convert';

import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';

/// 私聊网络请求 Dio 实例
class PrivateChatDio extends DioAbstract {
  // TODO: 请根据实际后端地址修改此 baseUrl
  @override
  String baseUrl = '${EnvConfig.QNHD}private-chat/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers['token'] = await LakeTokenManager().token;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case 200:
          return handler.next(response);
        default:
          return handler.reject(
            WpyDioException(error: response.data['msg'] ?? '未知错误'),
            true,
          );
      }
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
}
