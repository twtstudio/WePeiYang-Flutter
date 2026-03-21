import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/network/private_chat_service.dart';

/// WebSocket 服务 — 管理实时消息推送连接
class PrivateChatWebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  /// 新消息回调
  void Function(PrivateChatMsgVO msg)? onMessageReceived;

  /// 连接状态变更回调
  void Function(bool connected)? onConnectionChanged;

  bool get isConnected => _isConnected;

  PrivateChatWebSocketService();

  /// 获取 WebSocket 连接地址（使用 JWT token 鉴权）
  Future<String> _getWsUrl() async {
    final token = await LakeTokenManager().token;
    // 线上地址（部署后切换）：
    // final baseWs = EnvConfig.QNHD.replaceFirst('http', 'ws');
    // return '${baseWs}ws/private-chat?token=$token';

    // 本地调试地址（Android 模拟器用 10.0.2.2 访问宿主机 localhost）
    //return 'ws://10.0.2.2:8092/ws/private-chat?token=$token';
    final base = privateChatDio.baseUrl;
    final wsBase = base.replaceFirst(RegExp(r'^http'), 'ws');
    final wsUrl = wsBase.replaceFirst(
      RegExp(r'/api/v1/f/private-chat/?$'),
      '/ws/private-chat',
    );
    return '$wsUrl?token=$token';
  }

  /// 建立 WebSocket 连接
  void connect() async {
    final wsUrl = await _getWsUrl();
    PrivateChatLogger.log('WS', '尝试连接 $wsUrl');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (data) {
          if (!_isConnected) {
            _isConnected = true;
            onConnectionChanged?.call(true);
            PrivateChatLogger.log('WS', '连接已建立');
          }
          try {
            PrivateChatLogger.log('WS', '← 收到消息: $data');
            final json = jsonDecode(data);
            final msg = PrivateChatMsgVO.fromJson(json);
            onMessageReceived?.call(msg);
          } catch (e) {
            PrivateChatLogger.log('WS', '消息解析失败: $e');
          }
        },
        onDone: () {
          PrivateChatLogger.log('WS', '连接已关闭');
          _isConnected = false;
          onConnectionChanged?.call(false);
          _scheduleReconnect();
        },
        onError: (error) {
          PrivateChatLogger.log('WS', '连接错误: $error');
          _isConnected = false;
          onConnectionChanged?.call(false);
          _scheduleReconnect();
        },
      );

      _channel!.ready.then((_) {
        if (!_isConnected) {
          _isConnected = true;
          onConnectionChanged?.call(true);
          PrivateChatLogger.log('WS', '连接就绪');
        }
      }).catchError((e) {
        PrivateChatLogger.log('WS', '连接就绪失败: $e');
        if (!_isConnected) {
          onConnectionChanged?.call(false);
          _scheduleReconnect();
        }
      });
    } catch (e) {
      PrivateChatLogger.log('WS', '连接异常: $e');
      _isConnected = false;
      onConnectionChanged?.call(false);
      _scheduleReconnect();
    }
  }

  /// 断开连接
  void disconnect() {
    PrivateChatLogger.log('WS', '主动断开连接');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    onConnectionChanged?.call(false);
  }

  /// 5 秒后自动重连
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        PrivateChatLogger.log('WS', '自动重连...');
        connect();
      }
    });
  }

  /// 释放资源
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }
}
