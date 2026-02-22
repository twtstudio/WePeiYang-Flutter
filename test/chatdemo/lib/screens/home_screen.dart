import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../models/chat_models.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'log_screen.dart';
import 'login_screen.dart';

/// 主页 — 会话列表（仿微信主页）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        final pages = [
          _SessionListPage(provider: provider),
          const SettingsScreen(),
          const LogScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _currentIndex == 0
                  ? '私信 - 用户 ${provider.myUserId}'
                  : _currentIndex == 1
                      ? '设置'
                      : 'WebSocket 日志',
            ),
            backgroundColor: const Color(0xFF1ABC9C),
            foregroundColor: Colors.white,
            actions: [
              // 连接状态指示
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: Icon(Icons.circle,
                      size: 10,
                      color:
                          provider.isConnected ? Colors.green : Colors.red),
                  label: Text(provider.isConnected ? '在线' : '离线',
                      style: TextStyle(fontSize: 12, color: provider.isConnected ? Colors.blue : Colors.red)),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
              // 添加联系人
              if (_currentIndex == 0)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _showAddContactDialog(context, provider),
                  tooltip: '添加聊天对象',
                ),
              // 退出
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context, provider),
                tooltip: '退出',
              ),
            ],
          ),
          body: pages[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: [
              NavigationDestination(
                  icon: Badge(
                    isLabelVisible: provider.totalUnreadCount > 0,
                    label: Text('${provider.totalUnreadCount}'),
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  selectedIcon: const Icon(Icons.chat_bubble),
                  label: '私信'),
              const NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: '设置'),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: provider.logs.length > 0,
                  label: Text('${provider.logs.length}'),
                  child: const Icon(Icons.article_outlined),
                ),
                selectedIcon: const Icon(Icons.article),
                label: '日志',
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout(BuildContext context, ChatProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出确认'),
        content: const Text('确定要断开连接并退出吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              provider.logout();
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, ChatProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加聊天对象'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '对方用户 ID',
            hintText: '输入用户ID（如 1002）',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              final id = int.tryParse(controller.text.trim());
              if (id == null || id <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入有效的用户ID')),
                );
                return;
              }
              Navigator.pop(ctx);
              final error = await provider.addContact(id);
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

/// 会话列表页
class _SessionListPage extends StatelessWidget {
  final ChatProvider provider;

  const _SessionListPage({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('暂无会话', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('点击右上角 ➕ 添加聊天对象',
                style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => provider.fetchContacts(),
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchContacts(),
      child: ListView.separated(
        itemCount: provider.contacts.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final contact = provider.contacts[index];
          return _ContactTile(contact: contact, provider: provider);
        },
      ),
    );
  }
}

/// 联系人列表项
class _ContactTile extends StatelessWidget {
  final Contact contact;
  final ChatProvider provider;

  const _ContactTile({required this.contact, required this.provider});

  @override
  Widget build(BuildContext context) {
    String timeStr = '';
    if (contact.lastMsgTime != null) {
      try {
        final dt = DateTime.parse(
            contact.lastMsgTime!.replaceFirst(' ', 'T'));
        timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF3498DB),
        child: Text(
          contact.username.substring(contact.username.length - 2),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      title: Text(contact.username,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        contact.lastMsg.isEmpty ? '暂无消息' : contact.lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[500], fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timeStr.isNotEmpty)
            Text(timeStr,
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          if (contact.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Text(
                contact.unreadCount > 99
                    ? '99+'
                    : '${contact.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
      onTap: () async {
        await provider.selectContact(contact);
        if (context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(contact: contact),
            ),
          );
          // 从聊天页返回后：先清除当前聊天对象，让后续 WS 消息正确计入未读
          provider.clearCurrentContact();
          if (context.mounted) {
            provider.fetchContacts();
          }
        }
      },
    );
  }
}
