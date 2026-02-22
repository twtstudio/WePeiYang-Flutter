import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_model.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_conversation_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/page/private_chat_settings_page.dart';
import 'package:we_pei_yang_flutter/private_chat/view/widget/contact_tile_widget.dart';

/// 私聊主页 — 会话列表
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
            title: Text(
              '私信',
              style: TextUtil.base.bold.sp(18).label(context),
            ),
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            elevation: 0,
            actions: [
              // 连接状态
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  Icons.circle,
                  size: 10.sp,
                  color: provider.isConnected
                      ? WpyTheme.of(context).get(WpyColorKey.successGreen)
                      : WpyTheme.of(context).get(WpyColorKey.dangerousRed),
                ),
              ),
              // 设置
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivateChatSettingsPage(),
                    ),
                  );
                },
                tooltip: '私信设置',
              ),
              // 添加联系人
              IconButton(
                icon: Icon(
                  Icons.person_add_outlined,
                  color: WpyTheme.of(context).get(WpyColorKey.labelTextColor),
                ),
                onPressed: () => _showAddContactDialog(context, provider),
                tooltip: '添加聊天对象',
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
            Icon(
              Icons.chat_bubble_outline,
              size: 80.sp,
              color: WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
            ),
            SizedBox(height: 16.h),
            Text(
              '暂无会话',
              style: TextUtil.base.regular.sp(16).secondary(context),
            ),
            SizedBox(height: 8.h),
            Text(
              '点击右上角 ➕ 添加聊天对象',
              style: TextUtil.base.regular.sp(14).secondary(context),
            ),
            SizedBox(height: 24.h),
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
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72.w,
          color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
        ),
        itemBuilder: (context, index) {
          final contact = provider.contacts[index];
          return ContactTileWidget(
            contact: contact,
            onTap: () => _openConversation(context, provider, contact),
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
    await provider.selectContact(contact);
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrivateChatConversationPage(contact: contact),
        ),
      );
      provider.clearCurrentContact();
      if (context.mounted) {
        provider.fetchContacts();
      }
    }
  }

  void _showAddContactDialog(
      BuildContext context, PrivateChatProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '添加聊天对象',
          style: TextUtil.base.bold.sp(16).label(context),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '对方用户 ID',
            hintText: '输入用户ID',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final id = int.tryParse(controller.text.trim());
              if (id == null || id <= 0) {
                ToastProvider.error('请输入有效的用户ID');
                return;
              }
              Navigator.pop(ctx);
              final error = await provider.addContact(id);
              if (error != null && context.mounted) {
                ToastProvider.error(error);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
