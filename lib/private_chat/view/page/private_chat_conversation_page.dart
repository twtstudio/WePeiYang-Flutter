import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';

/// 聊天详情页 — 气泡消息 + 自动滚动
class PrivateChatConversationPage extends StatefulWidget {
  final PrivateChatContact contact;

  const PrivateChatConversationPage({super.key, required this.contact});

  @override
  State<PrivateChatConversationPage> createState() =>
      _PrivateChatConversationPageState();
}

class _PrivateChatConversationPageState
    extends State<PrivateChatConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    // 监听键盘弹出，自动滚到底部
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // reverse: true 时，0 是最底部
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    final provider = context.read<PrivateChatProvider>();
    final error = await provider.sendMessage(content);
    if (error != null && mounted) {
      ToastProvider.error(error);
    } else {
      _scrollToBottom();
    }
  }

  void _showBlockConfirmDialog(BuildContext context, PrivateChatProvider provider) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('拉黑用户', style: TextUtil.base.bold.sp(16).label(context)),
        content: Text('确定要拉黑 ${widget.contact.username} 吗？拉黑后将无法收到对方的消息。',
            style: TextUtil.base.regular.sp(14).label(context)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(c);
              final error = await provider.blockUser(widget.contact.userId);
              if (error != null && mounted) {
                ToastProvider.error(error);
              } else if (mounted) {
                ToastProvider.success('已拉黑');
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: WpyTheme.of(context).get(WpyColorKey.dangerousRed)),
            child: const Text('拉黑'),
          ),
        ],
      ),
    );
  }

  void _showMessageActions(BuildContext context, PrivateChatMsgVO msg) {
    final provider = context.read<PrivateChatProvider>();
    final isMine = msg.senderId == provider.myUserId;

    bool canRecall = false;
    if (isMine && msg.sendDateTime != null) {
      canRecall = DateTime.now().difference(msg.sendDateTime!).inMinutes < 2;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w, height: 4.h,
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // 复制
              ListTile(
                leading: Icon(Icons.copy_outlined, size: 22.sp),
                title: Text('复制', style: TextUtil.base.regular.sp(15).label(context)),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: msg.content ?? ''));
                  ToastProvider.success('已复制');
                },
              ),
              // 撤回
              if (canRecall)
                ListTile(
                  leading: Icon(Icons.undo, size: 22.sp,
                      color: WpyTheme.of(context).get(WpyColorKey.warningColor)),
                  title: Text('撤回', style: TextUtil.base.regular.sp(15).label(context)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final error = await provider.recallMessage(msg.msgId!);
                    if (error != null && mounted) ToastProvider.error(error);
                  },
                ),
              // 删除
              ListTile(
                leading: Icon(Icons.delete_outline, size: 22.sp,
                    color: WpyTheme.of(context).get(WpyColorKey.dangerousRed)),
                title: Text('删除', style: TextUtil.base.regular.sp(15).copyWith(
                    color: WpyTheme.of(context).get(WpyColorKey.dangerousRed))),
                subtitle: Text('仅从你的记录中删除', style: TextUtil.base.regular.sp(11).secondary(context)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text('确认删除', style: TextUtil.base.bold.sp(16).label(context)),
                      content: Text('确定要删除这条消息吗？', style: TextUtil.base.regular.sp(14).label(context)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
                        FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: WpyTheme.of(context).get(WpyColorKey.dangerousRed)),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final error = await provider.deleteMessage(msg.msgId!);
                    if (error != null && mounted) ToastProvider.error(error);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 判断是否需要显示时间分割线（与上一条消息间隔 > 5 分钟）
  bool _shouldShowTime(List<PrivateChatMsgVO> messages, int index) {
    // 注意：列表是反转的（最新消息在 index=0），所以上一条是 index+1
    if (index == messages.length - 1) return true; // 最早的消息始终显示时间
    final current = messages[index].sendDateTime;
    final prev = messages[index + 1].sendDateTime;
    if (current == null || prev == null) return false;
    return current.difference(prev).inMinutes.abs() > 5;
  }

  /// 格式化时间分割线文字
  String _formatTimeLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (diff == 0) return timeStr;
    if (diff == 1) return '昨天 $timeStr';
    if (diff < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return '${weekdays[dt.weekday - 1]} $timeStr';
    }
    return '${dt.month}月${dt.day}日 $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivateChatProvider>(
      builder: (context, provider, _) {
        // 检测消息更新，自动滚到底部
        if (provider.messageVersion != _lastVersion) {
          _lastVersion = provider.messageVersion;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }

        return Scaffold(
          backgroundColor: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          appBar: AppBar(
            title: Text(widget.contact.username, style: TextUtil.base.bold.sp(17).label(context)),
            centerTitle: true,
            backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            elevation: 0.5,
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    size: 22.sp),
                onSelected: (value) {
                  switch (value) {
                    case 'share':
                      ToastProvider.success('分享功能开发中');
                      break;
                    case 'block':
                      _showBlockConfirmDialog(context, provider);
                      break;
                    case 'report':
                      ToastProvider.success('举报功能开发中');
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(children: [
                      Icon(Icons.share_outlined, size: 20.sp,
                          color: WpyTheme.of(context).get(WpyColorKey.labelTextColor)),
                      SizedBox(width: 8.w),
                      Text('分享个人名片', style: TextUtil.base.regular.sp(14).label(context)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Row(children: [
                      Icon(Icons.block_outlined, size: 20.sp,
                          color: WpyTheme.of(context).get(WpyColorKey.warningColor)),
                      SizedBox(width: 8.w),
                      Text('拉黑当前用户', style: TextUtil.base.regular.sp(14).label(context)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(children: [
                      Icon(Icons.flag_outlined, size: 20.sp,
                          color: WpyTheme.of(context).get(WpyColorKey.dangerousRed)),
                      SizedBox(width: 8.w),
                      Text('举报当前用户', style: TextUtil.base.regular.sp(14).label(context)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // 消息列表
              Expanded(
                child: GestureDetector(
                  onTap: () => _focusNode.unfocus(),
                  child: provider.currentMessages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_outlined, size: 56.sp,
                                  color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor).withOpacity(0.4)),
                              SizedBox(height: 12.h),
                              Text('发送第一条消息吧！', style: TextUtil.base.regular.sp(14).secondary(context)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          itemCount: provider.currentMessages.length,
                          itemBuilder: (context, index) {
                            final msg = provider.currentMessages[index];
                            final isMine = msg.senderId == provider.myUserId;
                            final showTime = _shouldShowTime(provider.currentMessages, index);

                            return Column(
                              children: [
                                // 时间分割线
                                if (showTime && msg.sendDateTime != null)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        _formatTimeLabel(msg.sendDateTime!),
                                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                // 消息气泡
                                _ChatBubble(
                                  msg: msg,
                                  isMine: isMine,
                                  onLongPress: () {
                                    if (!msg.isRecalled) _showMessageActions(context, msg);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
              // 输入区域
              _ChatInputBar(
                controller: _messageController,
                focusNode: _focusNode,
                onSend: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 聊天气泡
class _ChatBubble extends StatelessWidget {
  final PrivateChatMsgVO msg;
  final bool isMine;
  final VoidCallback? onLongPress;

  const _ChatBubble({required this.msg, required this.isMine, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    if (msg.isRecalled) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              isMine ? '你撤回了一条消息' : '对方撤回了一条消息',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 气泡
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(maxWidth: 0.7.sw),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isMine
                      ? const Color(0xFF5B8CFF) // 蓝色（自己）
                      : Colors.white,            // 白色（对方）
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                    bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  msg.content ?? '',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: isMine ? Colors.white : WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          // 已读/未读状态指示器（仅我发的消息显示）
          if (isMine) ...[
            SizedBox(width: 4.w),
            _buildReadStatusIndicator(context),
          ],
        ],
      ),
    );
  }

  /// 已读/未读状态指示器
  Widget _buildReadStatusIndicator(BuildContext context) {
    final isRead = msg.msgStatus == 1;
    return Container(
      width: 8.w,
      height: 8.w,
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRead ? const Color(0xFF5B8CFF) : Colors.transparent,
        border: Border.all(
          color: isRead ? const Color(0xFF5B8CFF) : Colors.grey[400]!,
          width: 1.5,
        ),
      ),
    );
  }
}

/// 聊天输入栏（微信风格）
class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _ChatInputBar({required this.controller, required this.focusNode, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12.w, right: 8.w, top: 8.h,
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 120.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  isDense: true,
                ),
                style: TextStyle(fontSize: 15.sp),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40.w, height: 40.w,
              decoration: BoxDecoration(
                color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
