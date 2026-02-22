import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';

/// WebSocket 日志页面 — 查看实时通信日志
class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // 工具栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF2D2D2D),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WebSocket 实时日志 (${provider.logs.length})',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: () => provider.clearLogs(),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.grey, size: 16),
                    label: const Text('清空',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ],
              ),
            ),
            // 日志内容
            Expanded(
              child: Container(
                color: const Color(0xFF1E1E1E),
                child: provider.logs.isEmpty
                    ? const Center(
                        child: Text('暂无日志',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.logs.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final log = provider
                              .logs[provider.logs.length - 1 - index];
                          return _LogEntryWidget(log: log);
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LogEntryWidget extends StatelessWidget {
  final LogEntry log;

  const _LogEntryWidget({required this.log});

  Color _getColor() {
    switch (log.type) {
      case 'info':
        return const Color(0xFF4FC1FF);
      case 'warn':
        return const Color(0xFFFFCC02);
      case 'error':
        return const Color(0xFFF48771);
      case 'send':
        return const Color(0xFF6A9955);
      case 'recv':
        return const Color(0xFFCE9178);
      default:
        return const Color(0xFFD4D4D4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${log.time.hour.toString().padLeft(2, '0')}:'
        '${log.time.minute.toString().padLeft(2, '0')}:'
        '${log.time.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '[$timeStr] ',
              style: const TextStyle(
                  color: Color(0xFF858585),
                  fontFamily: 'monospace',
                  fontSize: 12),
            ),
            TextSpan(
              text: log.message,
              style: TextStyle(
                  color: _getColor(),
                  fontFamily: 'monospace',
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
