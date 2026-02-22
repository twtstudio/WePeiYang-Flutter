import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_models.dart';

/// WebSocket 服务 — 管理实时消息推送连接
class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  final String _baseWsUrl;
  final int _userId;

  /// 新消息回调
  void Function(PrivateChatMsgVO msg)? onMessageReceived;

  /// 连接状态变更回调
  void Function(bool connected)? onConnectionChanged;

  /// 日志回调
  void Function(String type, String message)? onLog;

  bool get isConnected => _isConnected;

  WebSocketService({required String baseWsUrl, required int userId})
      : _baseWsUrl = baseWsUrl,
        _userId = userId;

  /// 建立 WebSocket 连接（同步，不使用 async/await）
  void connect() {
    try {
      final wsUrl = '$_baseWsUrl/ws/private-chat?userId=$_userId';
      onLog?.call('info', '正在连接: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // 【关键】立即设置 stream 监听器，不等待 ready
      _channel!.stream.listen(
        (data) {
          // 收到任何数据就说明连接已建立
          if (!_isConnected) {
            _isConnected = true;
            onConnectionChanged?.call(true);
          }
          try {
            final json = jsonDecode(data);
            final msg = PrivateChatMsgVO.fromJson(json);
            // 【关键】先处理消息回调，再记录日志
            // 确保 notifyListeners 时消息已经在列表中
            onMessageReceived?.call(msg);
            onLog?.call('recv', '📩 收到消息: msgId=${msg.msgId}');
          } catch (e) {
            onLog?.call('error', '解析消息失败: $data (error: $e)');
          }
        },
        onDone: () {
          _isConnected = false;
          onConnectionChanged?.call(false);
          onLog?.call('warn', 'WebSocket 连接已关闭');
          _scheduleReconnect();
        },
        onError: (error) {
          _isConnected = false;
          onConnectionChanged?.call(false);
          onLog?.call('error', 'WebSocket 错误: $error');
          _scheduleReconnect();
        },
      );

      // 非阻塞检查握手状态（仅用于更新连接状态指示器）
      _channel!.ready.then((_) {
        if (!_isConnected) {
          _isConnected = true;
          onConnectionChanged?.call(true);
        }
        onLog?.call('info', '✅ WebSocket 连接成功 (userId=$_userId)');
      }).catchError((e) {
        onLog?.call('error', '❌ WebSocket 握手失败: $e');
        if (!_isConnected) {
          onConnectionChanged?.call(false);
          _scheduleReconnect();
        }
      });
    } catch (e) {
      onLog?.call('error', '❌ WebSocket 连接异常: $e');
      _isConnected = false;
      onConnectionChanged?.call(false);
      _scheduleReconnect();
    }
  }

  /// 断开连接
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    onConnectionChanged?.call(false);
    onLog?.call('info', '手动断开 WebSocket 连接');
  }

  /// 5 秒后自动重连
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        onLog?.call('info', '🔄 尝试重新连接...');
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
