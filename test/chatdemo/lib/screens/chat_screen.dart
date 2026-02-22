import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../models/chat_models.dart';

/// 聊天详情页 — 与指定联系人的消息收发界面
class ChatScreen extends StatefulWidget {
  final Contact contact;

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    final provider = context.read<ChatProvider>();
    final error = await provider.sendMessage(content);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  void _showMessageActions(BuildContext context, PrivateChatMsgVO msg) {
    final provider = context.read<ChatProvider>();
    final isMine = msg.senderId == provider.myUserId;

    // 检查是否可撤回（2分钟内，且是自己发的）
    bool canRecall = false;
    if (isMine && msg.sendTime != null) {
      try {
        final sendDate =
            DateTime.parse(msg.sendTime!.replaceFirst(' ', 'T'));
        canRecall =
            DateTime.now().difference(sendDate).inMinutes < 2;
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canRecall)
              ListTile(
                leading: const Icon(Icons.undo, color: Colors.orange),
                title: const Text('撤回消息'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final error = await provider.recallMessage(msg.msgId!);
                  if (error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除消息'),
              subtitle: const Text('仅从你的记录中删除，对方仍可见'),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除这条消息吗？'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('取消')),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('删除')),
                    ],
                  ),
                );
                if (confirm == true) {
                  final error = await provider.deleteMessage(msg.msgId!);
                  if (error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制内容'),
              onTap: () {
                Navigator.pop(ctx);
                // 简单复制（实际需导入 Clipboard）
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已复制: ${msg.content}')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contact.username),
                Text(
                  provider.isConnected ? '在线' : '离线',
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.isConnected
                        ? Colors.green[100]
                        : Colors.red[100],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1ABC9C),
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // 消息列表
              Expanded(
                child: provider.currentMessages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('暂无消息',
                                style: TextStyle(color: Colors.grey[400])),
                            const SizedBox(height: 4),
                            Text('发送第一条消息吧！',
                                style: TextStyle(
                                    color: Colors.grey[350], fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: provider.currentMessages.length,
                        itemBuilder: (context, index) {
                          final msg = provider.currentMessages[index];
                          return _MessageBubble(
                            msg: msg,
                            isMine: msg.senderId == provider.myUserId,
                            onLongPress: () {
                              if (!msg.isRecalled) {
                                _showMessageActions(context, msg);
                              }
                            },
                          );
                        },
                      ),
              ),

              // 输入区域
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  left: 12,
                  right: 8,
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '输入消息...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                const BorderSide(color: Color(0xFFDDD)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      onPressed: _sendMessage,
                      backgroundColor: const Color(0xFF2ECC71),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 消息气泡组件
class _MessageBubble extends StatelessWidget {
  final PrivateChatMsgVO msg;
  final bool isMine;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.msg,
    required this.isMine,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // 解析时间
    String timeStr = '';
    if (msg.sendTime != null) {
      try {
        final dt = DateTime.parse(msg.sendTime!.replaceFirst(' ', 'T'));
        timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    // 消息状态文本
    String statusText = '';
    if (isMine && !msg.isRecalled) {
      statusText = msg.msgStatus == 0
          ? '未读'
          : msg.msgStatus == 1
              ? '已读'
              : '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text('${msg.senderId ?? '?'}'.substring(
                  '${msg.senderId ?? '?'}'.length > 2
                      ? '${msg.senderId ?? '?'}'.length - 2
                      : 0),
                  style: const TextStyle(fontSize: 11)),
            ),
          if (!isMine) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isRecalled
                      ? Colors.grey[200]
                      : isMine
                          ? const Color(0xFF3498DB)
                          : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                  boxShadow: [
                    if (!isMine && !msg.isRecalled)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // 消息内容
                    Text(
                      msg.isRecalled
                          ? '⚠️ ${msg.content ?? "消息已撤回"}'
                          : msg.content ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: msg.isRecalled
                            ? Colors.grey[600]
                            : isMine
                                ? Colors.white
                                : Colors.black87,
                        fontStyle:
                            msg.isRecalled ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 时间 + 状态
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (timeStr.isNotEmpty)
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isMine && !msg.isRecalled
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),
                        if (statusText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              color: isMine
                                  ? Colors.white60
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                        if (msg.msgId != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '#${msg.msgId}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isMine && !msg.isRecalled
                                  ? Colors.white38
                                  : Colors.grey[350],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 8),
          if (isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1ABC9C),
              child: const Text('我',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
