import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/network/private_chat_service.dart';

/// API 接口测试页面 — 可手动调用所有私聊后端 API 并查看响应
class PrivateChatApiTestPage extends StatefulWidget {
  const PrivateChatApiTestPage({super.key});

  @override
  State<PrivateChatApiTestPage> createState() => _PrivateChatApiTestPageState();
}

class _PrivateChatApiTestPageState extends State<PrivateChatApiTestPage> {
  String _lastResult = '';
  bool _isLoading = false;

  Future<void> _callApi(String name, Future<dynamic> Function() fn) async {
    setState(() {
      _isLoading = true;
      _lastResult = '⏳ 正在调用 $name...';
    });
    try {
      final result = await fn();
      String display;
      if (result is PrivateChatApiResult) {
        final encoder = const JsonEncoder.withIndent('  ');
        display = '✅ $name\n'
            'code: ${result.code}\n'
            'msg: ${result.msg}\n'
            'data: ${result.data != null ? encoder.convert(result.data) : 'null'}';
      } else {
        display = '✅ $name\n$result';
      }
      setState(() {
        _isLoading = false;
        _lastResult = display;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _lastResult = '❌ $name 失败\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = CommonPreferences.lakeUid.value;

    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(
        title: Text('API 测试',
            style: TextUtil.base.bold.sp(17).label(context)),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 当前用户信息
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryBackgroundColor),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前测试身份',
                    style: TextUtil.base.bold.sp(14).label(context)),
                SizedBox(height: 4.h),
                Text('lakeUid: $userId (JWT token 鉴权)',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'monospace',
                        color: const Color(0xFF1565C0))),
                SizedBox(height: 4.h),
                Text('baseUrl: ${privateChatDio.baseUrl}',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'monospace',
                        color: Colors.grey[600])),
              ],
            ),
          ),

          // API 列表
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              children: [
                _SectionTitle('会话管理'),
                _ApiButton(
                  icon: Icons.list_alt,
                  title: '获取会话列表',
                  subtitle: 'GET /sessions',
                  onTap: () =>
                      _callApi('获取会话列表', PrivateChatService.getSessions),
                ),
                _ApiButton(
                  icon: Icons.delete_sweep,
                  title: '删除会话',
                  subtitle: 'POST /session/delete?session_id=?',
                  onTap: () => _showInputDialog(
                    context,
                    '删除会话',
                    '会话 ID (session_id)',
                    (val) => _callApi(
                      '删除会话(session_id=$val)',
                      () => PrivateChatService.deleteSession(int.parse(val)),
                    ),
                  ),
                ),

                _SectionTitle('消息管理'),
                _ApiButton(
                  icon: Icons.send,
                  title: '发送消息',
                  subtitle: 'POST /message/send',
                  onTap: () => _showSendMessageDialog(context),
                ),
                _ApiButton(
                  icon: Icons.history,
                  title: '获取聊天记录',
                  subtitle: 'GET /message/history?target_user_id=',
                  onTap: () => _showHistoryDialog(context),
                ),
                _ApiButton(
                  icon: Icons.done_all,
                  title: '标记已读',
                  subtitle: 'POST /message/read?target_user_id=?',
                  onTap: () => _showInputDialog(
                    context,
                    '标记已读',
                    '对方用户ID (target_user_id)',
                    (val) => _callApi(
                      '标记已读(target_user_id=$val)',
                      () => PrivateChatService.markAsRead(int.parse(val)),
                    ),
                  ),
                ),
                _ApiButton(
                  icon: Icons.undo,
                  title: '撤回消息',
                  subtitle: 'POST /message/recall?msg_id=?',
                  onTap: () => _showInputDialog(
                    context,
                    '撤回消息',
                    '消息ID (msg_id)',
                    (val) => _callApi(
                      '撤回消息(msg_id=$val)',
                      () => PrivateChatService.recallMessage(int.parse(val)),
                    ),
                  ),
                ),
                _ApiButton(
                  icon: Icons.delete,
                  title: '删除消息',
                  subtitle: 'POST /message/delete?msg_id=?',
                  onTap: () => _showInputDialog(
                    context,
                    '删除消息',
                    '消息ID (msg_id)',
                    (val) => _callApi(
                      '删除消息(msg_id=$val)',
                      () => PrivateChatService.deleteMessage(int.parse(val)),
                    ),
                  ),
                ),

                _SectionTitle('用户设置'),
                _ApiButton(
                  icon: Icons.settings,
                  title: '获取设置',
                  subtitle: 'GET /setting',
                  onTap: () =>
                      _callApi('获取设置', PrivateChatService.getSetting),
                ),
                _ApiButton(
                  icon: Icons.toggle_on,
                  title: '更新私信开关',
                  subtitle: 'POST /setting/enable?is_enable=0|1',
                  onTap: () => _showSelectDialog(
                    context,
                    '更新私信开关',
                    {'开启 (1)': '1', '关闭 (0)': '0'},
                    (val) => _callApi(
                      '更新私信开关(is_enable=$val)',
                      () => PrivateChatService.updateEnable(int.parse(val)),
                    ),
                  ),
                ),
                _ApiButton(
                  icon: Icons.person_off,
                  title: '更新陌生人策略',
                  subtitle: 'POST /setting/stranger?is_accept_stranger=0|1',
                  onTap: () => _showSelectDialog(
                    context,
                    '更新陌生人策略',
                    {'接收 (1)': '1', '不接收 (0)': '0'},
                    (val) => _callApi(
                      '更新陌生人策略(is_accept_stranger=$val)',
                      () =>
                          PrivateChatService.updateStranger(int.parse(val)),
                    ),
                  ),
                ),
                _ApiButton(
                  icon: Icons.block,
                  title: '拉黑用户',
                  subtitle: 'POST /setting/block?block_user_id=?',
                  onTap: () => _showInputDialog(
                    context,
                    '拉黑用户',
                    '要拉黑的用户ID (block_user_id)',
                    (val) => _callApi(
                      '拉黑用户(block_user_id=$val)',
                      () => PrivateChatService.blockUser(int.parse(val)),
                    ),
                  ),
                ),
                _ApiButton(
                  icon: Icons.person_add,
                  title: '取消拉黑',
                  subtitle: 'POST /setting/unblock?unblock_user_id=?',
                  onTap: () => _showInputDialog(
                    context,
                    '取消拉黑',
                    '要取消拉黑的用户ID (unblock_user_id)',
                    (val) => _callApi(
                      '取消拉黑(unblock_user_id=$val)',
                      () =>
                          PrivateChatService.unblockUser(int.parse(val)),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // 结果面板
          _buildResultPanel(context),
        ],
      ),
    );
  }

  Widget _buildResultPanel(BuildContext context) {
    if (_lastResult.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(
            color: WpyTheme.of(context)
                .get(WpyColorKey.lightBorderColor),
          ),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(12.w),
            child: SelectableText(
              _lastResult,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'monospace',
                color: _lastResult.startsWith('❌')
                    ? const Color(0xFFFF6B6B)
                    : _lastResult.startsWith('⏳')
                        ? const Color(0xFFFFD93D)
                        : const Color(0xFF69F0AE),
                height: 1.4,
              ),
            ),
          ),
          // 复制按钮
          Positioned(
            top: 4.h,
            right: 4.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.copy, size: 16.sp, color: Colors.grey[400]),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _lastResult));
                    ToastProvider.success('已复制');
                  },
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16.sp, color: Colors.grey[400]),
                  onPressed: () => setState(() => _lastResult = ''),
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(
    BuildContext context,
    String title,
    String hint,
    void Function(String) onConfirm,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        title: Text(title, style: TextUtil.base.bold.sp(16).label(context)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isEmpty) {
                ToastProvider.error('请输入');
                return;
              }
              Navigator.pop(ctx);
              onConfirm(val);
            },
            child: const Text('调用'),
          ),
        ],
      ),
    );
  }

  void _showSelectDialog(
    BuildContext context,
    String title,
    Map<String, String> options,
    void Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        title: Text(title, style: TextUtil.base.bold.sp(16).label(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries
              .map((e) => ListTile(
                    title: Text(e.key),
                    onTap: () {
                      Navigator.pop(ctx);
                      onSelect(e.value);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showSendMessageDialog(BuildContext context) {
    final receiverCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        title: Text('发送消息',
            style: TextUtil.base.bold.sp(16).label(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: receiverCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '接收者ID (receiver_id)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: contentCtrl,
              decoration: InputDecoration(
                labelText: '消息内容 (content)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final receiver = int.tryParse(receiverCtrl.text.trim());
              final content = contentCtrl.text.trim();
              if (receiver == null || content.isEmpty) {
                ToastProvider.error('请完整填写');
                return;
              }
              Navigator.pop(ctx);
              _callApi(
                '发送消息(receiverId=$receiver)',
                () => PrivateChatService.sendMessage(
                  receiverId: receiver,
                  content: content,
                ),
              );
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  /// v2.1：获取聊天记录只需 target_user_id，无需 session_id
  void _showHistoryDialog(BuildContext context) {
    final targetUserCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        title: Text('获取聊天记录',
            style: TextUtil.base.bold.sp(16).label(context)),
        content: TextField(
          controller: targetUserCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '对方用户ID (target_user_id)',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final targetUserId = int.tryParse(targetUserCtrl.text.trim());
              if (targetUserId == null) {
                ToastProvider.error('请输入用户ID');
                return;
              }
              Navigator.pop(ctx);
              _callApi(
                '获取聊天记录(target_user_id=$targetUserId)',
                () => PrivateChatService.getChatHistory(
                  targetUserId: targetUserId,
                ),
              );
            },
            child: const Text('查询'),
          ),
        ],
      ),
    );
  }
}

/// 分组标题
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h, left: 4.w),
      child: Text(
        title,
        style: TextUtil.base.bold.sp(13).copyWith(
              color: WpyTheme.of(context)
                  .get(WpyColorKey.secondaryTextColor)
                  .withOpacity(0.7),
              letterSpacing: 1,
            ),
      ),
    );
  }
}

/// API 调用按钮
class _ApiButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ApiButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: WpyTheme.of(context)
              .get(WpyColorKey.lightBorderColor)
              .withOpacity(0.5),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 22.sp,
            color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor)),
        title: Text(title,
            style: TextUtil.base.w600.sp(14).label(context)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 11.sp,
                fontFamily: 'monospace',
                color: Colors.grey[500])),
        trailing: Icon(Icons.play_arrow_rounded, size: 22.sp,
            color: WpyTheme.of(context).get(WpyColorKey.primaryActionColor)),
        onTap: onTap,
      ),
    );
  }
}
