import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_conversation_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_settings_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_log_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_api_test_page.dart';

/// 私聊主页
class PrivateChatHomePage extends StatefulWidget {
  const PrivateChatHomePage({super.key});

  @override
  State<PrivateChatHomePage> createState() => _PrivateChatHomePageState();
}

class _PrivateChatHomePageState extends State<PrivateChatHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PrivateChatProvider>();
      if (provider.myUserId == null) {
        provider.init();
      } else {
        provider.fetchContacts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivateChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '私信',
                  style: TextUtil.base.bold.sp(18).label(context),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.isConnected
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5252),
                  ),
                ),
              ],
            ),
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.bug_report_outlined,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    size: 22.sp),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivateChatLogPage())),
                tooltip: '调试日志',
              ),
              IconButton(
                icon: Icon(Icons.api_outlined,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    size: 22.sp),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivateChatApiTestPage())),
                tooltip: 'API 测试',
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    size: 22.sp),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivateChatSettingsPage())),
                tooltip: '私信设置',
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.add_circle_outline,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    size: 22.sp),
                onSelected: (value) {
                  if (value == 'add') _showAddContactDialog(context, provider);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'add',
                    child: Row(children: [
                      Icon(Icons.person_add_outlined, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('发起聊天', style: TextUtil.base.regular.sp(14).label(context)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(context, provider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PrivateChatProvider provider) {
    if (provider.contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 72.sp,
                color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withOpacity(0.4)),
            SizedBox(height: 16.h),
            Text('暂无会话', style: TextUtil.base.w600.sp(16).secondary(context)),
            SizedBox(height: 8.h),
            Text('点击右上角 + 发起新的聊天', style: TextUtil.base.regular.sp(13).secondary(context)),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () => provider.fetchContacts(),
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text('刷新', style: TextUtil.base.regular.sp(14)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchContacts(),
      child: ListView.builder(
        itemCount: provider.contacts.length,
        itemBuilder: (context, index) {
          final contact = provider.contacts[index];
          return _ContactTile(
            contact: contact,
            onTap: () => _openConversation(context, provider, contact),
            onLongPress: () => _showContactActions(context, contact),
          );
        },
      ),
    );
  }

  Future<void> _openConversation(
    BuildContext context,
    PrivateChatProvider provider,
    PrivateChatContact contact,
  ) async {
    if (!context.mounted) return;
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => PrivateChatConversationPage(contact: contact)),
    );
    provider.clearCurrentContact();
  }

  void _showContactActions(BuildContext context, PrivateChatContact contact) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36.w, height: 4.h, margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r))),
              ListTile(
                leading: Icon(Icons.push_pin_outlined, size: 22.sp),
                title: Text('置顶会话', style: TextUtil.base.regular.sp(15).label(context)),
                onTap: () { Navigator.pop(ctx); ToastProvider.success('功能开发中'); },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, size: 22.sp,
                    color: WpyTheme.of(context).get(WpyColorKey.dangerousRed)),
                title: Text('删除会话', style: TextUtil.base.regular.sp(15).copyWith(
                    color: WpyTheme.of(context).get(WpyColorKey.dangerousRed))),
                onTap: () { Navigator.pop(ctx); ToastProvider.success('功能开发中'); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, PrivateChatProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('发起聊天', style: TextUtil.base.bold.sp(17).label(context)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '对方用户 ID',
            hintText: '请输入对方的用户ID',
            prefixIcon: Icon(Icons.person_outline, size: 20.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('取消', style: TextUtil.base.regular.sp(14).secondary(context))),
          FilledButton(
            onPressed: () async {
              final id = int.tryParse(controller.text.trim());
              if (id == null || id <= 0) { ToastProvider.error('请输入有效的用户ID'); return; }
              Navigator.pop(ctx);
              final error = provider.validateContact(id);
              if (error != null && context.mounted) {
                ToastProvider.error(error);
              } else {
                var contact = provider.contacts.where((c) => c.userId == id).firstOrNull;
                if (contact == null) {
                  contact = PrivateChatContact(userId: id, username: '用户 $id');
                }
                if (context.mounted) {
                  _openConversation(context, provider, contact);
                }
              }
            },
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 会话列表项
class _ContactTile extends StatelessWidget {
  final PrivateChatContact contact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ContactTile({required this.contact, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(contact.lastMsgTime);
    final hasUnread = contact.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor).withOpacity(0.5), width: 0.5)),
        ),
        child: Row(
          children: [
            // 头像 + 未读红点
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                    width: 48.w, height: 48.w,
                    child: contact.avatarUrl.isNotEmpty
                        ? WpyPic(contact.avatarUrl, width: 48.w, height: 48.w, fit: BoxFit.cover, withCache: true)
                        : Container(
                            decoration: BoxDecoration(color: _getAvatarColor(contact.userId), borderRadius: BorderRadius.circular(8.r)),
                            child: Center(child: Text(_getAvatarText(contact.username),
                                style: TextUtil.base.bold.sp(18).copyWith(color: Colors.white))),
                          ),
                  ),
                ),
                if (hasUnread) Positioned(top: -4.h, right: -4.w, child: Container(
                  constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white, width: 1.5)),
                  child: Center(child: Text(
                    contact.unreadCount > 99 ? '99+' : '${contact.unreadCount}',
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
                  )),
                )),
              ],
            ),
            SizedBox(width: 12.w),
            // 右侧内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(contact.username, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextUtil.base.w600.sp(16).label(context))),
                    if (timeStr.isNotEmpty) Text(timeStr, style: TextUtil.base.regular.sp(12).copyWith(
                        color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withOpacity(0.7))),
                  ]),
                  SizedBox(height: 4.h),
                  Text(contact.lastMsg.isEmpty ? '暂无消息' : contact.lastMsg,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextUtil.base.regular.sp(13).copyWith(
                          color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(int userId) {
    const colors = [Color(0xFF5B8CFF), Color(0xFF44C5A0), Color(0xFFFF8C5A), Color(0xFFCF7BFF),
        Color(0xFFFF6B8A), Color(0xFF64B5F6), Color(0xFFFFB74D), Color(0xFF81C784)];
    return colors[userId % colors.length];
  }

  String _getAvatarText(String username) {
    if (username.isEmpty) return '?';
    final lastChar = username[username.length - 1];
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(lastChar)) return lastChar;
    return username[0].toUpperCase();
  }

  String _formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawTime.replaceFirst(' ', 'T'));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(msgDay).inDays;
      if (diff == 0) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      if (diff == 1) return '昨天';
      if (diff < 7) {
        const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
        return '周${weekdays[dt.weekday - 1]}';
      }
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }
}
