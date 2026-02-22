import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/view/widget/chat_input_widget.dart';
import 'package:we_pei_yang_flutter/private_chat/view/widget/message_bubble_widget.dart';

/// 聊天详情页 — 与指定联系人的消息收发界面
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    final provider = context.read<PrivateChatProvider>();
    final error = await provider.sendMessage(content);
    if (error != null && mounted) {
      ToastProvider.error(error);
    }
  }

  void _showMessageActions(BuildContext context, PrivateChatMsgVO msg) {
    final provider = context.read<PrivateChatProvider>();
    final isMine = msg.senderId == provider.myUserId;

    // 检查是否可撤回（2分钟内，且是自己发的）
    bool canRecall = false;
    if (isMine && msg.sendDateTime != null) {
      canRecall = DateTime.now().difference(msg.sendDateTime!).inMinutes < 2;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canRecall)
              ListTile(
                leading: Icon(
                  Icons.undo,
                  color:
                      WpyTheme.of(context).get(WpyColorKey.warningColor),
                ),
                title: Text(
                  '撤回消息',
                  style: TextUtil.base.regular.sp(16).label(context),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final error = await provider.recallMessage(msg.msgId!);
                  if (error != null && mounted) {
                    ToastProvider.error(error);
                  }
                },
              ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color:
                    WpyTheme.of(context).get(WpyColorKey.dangerousRed),
              ),
              title: Text(
                '删除消息',
                style: TextUtil.base.regular.sp(16).label(context),
              ),
              subtitle: Text(
                '仅从你的记录中删除，对方仍可见',
                style: TextUtil.base.regular.sp(12).secondary(context),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(
                      '确认删除',
                      style: TextUtil.base.bold.sp(16).label(context),
                    ),
                    content: Text(
                      '确定要删除这条消息吗？',
                      style: TextUtil.base.regular.sp(14).label(context),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: WpyTheme.of(context)
                              .get(WpyColorKey.dangerousRed),
                        ),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final error = await provider.deleteMessage(msg.msgId!);
                  if (error != null && mounted) {
                    ToastProvider.error(error);
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.copy,
                color:
                    WpyTheme.of(context).get(WpyColorKey.labelTextColor),
              ),
              title: Text(
                '复制内容',
                style: TextUtil.base.regular.sp(16).label(context),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ToastProvider.success('已复制');
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivateChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.username,
                  style: TextUtil.base.bold.sp(16).label(context),
                ),
                Text(
                  provider.isConnected ? '在线' : '离线',
                  style: TextUtil.base.regular.sp(12).copyWith(
                        color: provider.isConnected
                            ? WpyTheme.of(context)
                                .get(WpyColorKey.successGreen)
                            : WpyTheme.of(context)
                                .get(WpyColorKey.dangerousRed),
                      ),
                ),
              ],
            ),
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            elevation: 0,
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
                            Icon(
                              Icons.chat_outlined,
                              size: 64.sp,
                              color: WpyTheme.of(context)
                                  .get(WpyColorKey.secondaryTextColor),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '暂无消息',
                              style: TextUtil.base.regular
                                  .sp(14)
                                  .secondary(context),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '发送第一条消息吧！',
                              style: TextUtil.base.regular
                                  .sp(13)
                                  .secondary(context),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        itemCount: provider.currentMessages.length,
                        itemBuilder: (context, index) {
                          final msg = provider.currentMessages[index];
                          return MessageBubbleWidget(
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
              ChatInputWidget(
                controller: _messageController,
                onSend: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}
