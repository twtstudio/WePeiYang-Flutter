import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_models.dart';

/// HTTP API 服务 — 封装所有后端 REST 接口
class ApiService {
  final String baseUrl;
  final int userId;

  ApiService({required this.baseUrl, required this.userId});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Test-User-Id': userId.toString(),
      };

  // ============== 私信核心 ==============

  /// 发送私信
  Future<ApiResult> sendMessage({
    required int receiverId,
    required String content,
    int msgType = 1,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/private-chat/message/send'),
      headers: _headers,
      body: jsonEncode({
        'receiverId': receiverId,
        'content': content,
        'msgType': msgType,
      }),
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 获取会话列表
  Future<ApiResult> getSessions() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/private-chat/sessions'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 获取聊天记录
  Future<ApiResult> getChatHistory({
    required int sessionId,
    required int userIdB,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await http.get(
      Uri.parse(
          '$baseUrl/private-chat/message/history?sessionId=$sessionId&userIdB=$userIdB&page=$page&pageSize=$pageSize'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 标记会话已读
  Future<ApiResult> markAsRead(int sessionId) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/private-chat/message/read?sessionId=$sessionId'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 创建/获取会话
  Future<ApiResult> createSession(int targetUserId) async {
    final resp = await http.post(
      Uri.parse(
          '$baseUrl/private-chat/session/create?targetUserId=$targetUserId'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 撤回消息
  Future<ApiResult> recallMessage(int msgId) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/private-chat/message/recall?msgId=$msgId'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 删除消息
  Future<ApiResult> deleteMessage(int msgId) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/private-chat/message/delete?msgId=$msgId'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  // ============== 用户设置 ==============

  /// 获取设置
  Future<ApiResult> getSetting() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/private-chat/setting'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 更新私信开关
  Future<ApiResult> updateEnable(int isEnable) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/private-chat/setting/enable?isEnable=$isEnable'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 更新陌生人策略
  Future<ApiResult> updateStranger(int isAcceptStranger) async {
    final resp = await http.post(
      Uri.parse(
          '$baseUrl/private-chat/setting/stranger?isAcceptStranger=$isAcceptStranger'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 拉黑用户
  Future<ApiResult> blockUser(int blockUserId) async {
    final resp = await http.post(
      Uri.parse(
          '$baseUrl/private-chat/setting/block?blockUserId=$blockUserId'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }

  /// 取消拉黑
  Future<ApiResult> unblockUser(int unblockUserId) async {
    final resp = await http.post(
      Uri.parse(
          '$baseUrl/private-chat/setting/unblock?unblockUserId=$unblockUserId'),
      headers: _headers,
    );
    return ApiResult.fromJson(jsonDecode(resp.body));
  }
}
