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

/// 可嵌入消息中心的私聊会话列表（无 AppBar）
class PrivateChatSessionListWidget extends StatefulWidget {
  const PrivateChatSessionListWidget({super.key});

  @override
  State<PrivateChatSessionListWidget> createState() =>
      _PrivateChatSessionListWidgetState();
}

class _PrivateChatSessionListWidgetState
    extends State<PrivateChatSessionListWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    return Consumer<PrivateChatProvider>(
      builder: (context, provider, _) {
        if (provider.contacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 56.sp,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.secondaryTextColor)
                        .withOpacity(0.4)),
                SizedBox(height: 12.h),
                Text('暂无私信',
                    style: TextUtil.base.w600.sp(15).secondary(context)),
                SizedBox(height: 6.h),
                Text('从用户主页发起私信',
                    style: TextUtil.base.regular.sp(13).secondary(context)),
                SizedBox(height: 20.h),
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
              return _SessionTile(
                contact: contact,
                onTap: () => _openConversation(context, provider, contact),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openConversation(
    BuildContext context,
    PrivateChatProvider provider,
    PrivateChatContact contact,
  ) async {
    await provider.selectContact(contact);
    if (!context.mounted) return;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                PrivateChatConversationPage(contact: contact)),
    );
    provider.clearCurrentContact();
  }
}

/// 会话列表项
class _SessionTile extends StatelessWidget {
  final PrivateChatContact contact;
  final VoidCallback onTap;

  const _SessionTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(contact.lastMsgTime);
    final hasUnread = contact.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.lightBorderColor)
                      .withOpacity(0.5),
                  width: 0.5)),
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
                    width: 48.w,
                    height: 48.w,
                    child: contact.avatarUrl.isNotEmpty
                        ? WpyPic(contact.avatarUrl,
                            width: 48.w,
                            height: 48.w,
                            fit: BoxFit.cover,
                            withCache: true)
                        : Container(
                            decoration: BoxDecoration(
                                color: _getAvatarColor(contact.userId),
                                borderRadius: BorderRadius.circular(8.r)),
                            child: Center(
                                child: Text(
                                    _getAvatarText(contact.username),
                                    style: TextUtil.base.bold
                                        .sp(18)
                                        .copyWith(color: Colors.white))),
                          ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                      top: -4.h,
                      right: -4.w,
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            borderRadius: BorderRadius.circular(10.r),
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                        child: Center(
                            child: Text(
                          contact.unreadCount > 99
                              ? '99+'
                              : '${contact.unreadCount}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600),
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(contact.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextUtil.base.w600.sp(16).label(context))),
                        if (timeStr.isNotEmpty)
                          Text(timeStr,
                              style: TextUtil.base.regular.sp(12).copyWith(
                                  color: WpyTheme.of(context)
                                      .get(WpyColorKey.secondaryTextColor)
                                      .withOpacity(0.7))),
                      ]),
                  SizedBox(height: 4.h),
                  Text(
                      contact.lastMsg.isEmpty ? '暂无消息' : contact.lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextUtil.base.regular.sp(13).copyWith(
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.secondaryTextColor)
                              .withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(int userId) {
    const colors = [
      Color(0xFF5B8CFF),
      Color(0xFF44C5A0),
      Color(0xFFFF8C5A),
      Color(0xFFCF7BFF),
      Color(0xFFFF6B8A),
      Color(0xFF64B5F6),
      Color(0xFFFFB74D),
      Color(0xFF81C784)
    ];
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
      if (diff == 0)
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
