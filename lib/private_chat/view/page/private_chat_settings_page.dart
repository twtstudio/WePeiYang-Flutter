import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/network/private_chat_service.dart';

/// 私信设置页面 — 私信开关、陌生人策略、拉黑管理
class PrivateChatSettingsPage extends StatefulWidget {
  const PrivateChatSettingsPage({super.key});

  @override
  State<PrivateChatSettingsPage> createState() =>
      _PrivateChatSettingsPageState();
}

class _PrivateChatSettingsPageState extends State<PrivateChatSettingsPage> {
  bool _isLoading = false;
  final _blockController = TextEditingController();
  final _baseUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final saved = CommonPreferences.privateChatBaseUrl.value;
    final current = saved.isNotEmpty ? saved : privateChatDio.baseUrl;
    _baseUrlController.text = current;
    if (current.isNotEmpty) {
      privateChatDio.baseUrl = current;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _blockController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final provider = context.read<PrivateChatProvider>();
    final error = await provider.loadSetting();
    if (error != null && mounted) {
      ToastProvider.error(error);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivateChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          appBar: AppBar(
            title: Text(
              '私信设置',
              style: TextUtil.base.bold.sp(18).label(context),
            ),
            backgroundColor:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            elevation: 0,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(context, provider),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, PrivateChatProvider provider) {
    final setting = provider.userSetting;
    if (setting == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 64.sp,
              color:
                  WpyTheme.of(context).get(WpyColorKey.secondaryTextColor),
            ),
            SizedBox(height: 16.h),
            Text(
              '设置尚未加载',
              style: TextUtil.base.regular.sp(16).secondary(context),
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: _loadSettings,
              icon: const Icon(Icons.refresh),
              label: const Text('加载设置'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSettings,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 私信设置卡片
          _buildSectionCard(
            context: context,
            title: '📨 私信设置',
            children: [
              SwitchListTile(
                title: Text(
                  '私信总开关',
                  style: TextUtil.base.regular.sp(16).label(context),
                ),
                subtitle: Text(
                  setting.isEnable == 1 ? '已开启' : '已关闭',
                  style: TextUtil.base.regular.sp(13).secondary(context),
                ),
                value: setting.isEnable == 1,
                activeColor:
                    WpyTheme.of(context).get(WpyColorKey.successGreen),
                onChanged: (val) async {
                  final error = await provider.toggleEnable(val);
                  if (error != null && mounted) {
                    ToastProvider.error(error);
                  }
                },
              ),
              Divider(
                height: 1,
                color:
                    WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
              ),
              SwitchListTile(
                title: Text(
                  '接收陌生人私信',
                  style: TextUtil.base.regular.sp(16).label(context),
                ),
                subtitle: Text(
                  setting.isAcceptStranger == 1 ? '已开启' : '已关闭',
                  style: TextUtil.base.regular.sp(13).secondary(context),
                ),
                value: setting.isAcceptStranger == 1,
                activeColor:
                    WpyTheme.of(context).get(WpyColorKey.successGreen),
                onChanged: (val) async {
                  final error = await provider.toggleStranger(val);
                  if (error != null && mounted) {
                    ToastProvider.error(error);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 测试用：私信连接地址
          _buildSectionCard(
            context: context,
            title: '🧪 测试用：私信连接地址',
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: TextField(
                  controller: _baseUrlController,
                  decoration: InputDecoration(
                    labelText: '私信 baseUrl',
                    hintText: '例如：http://10.0.2.2:8092/api/v1/f/private-chat/',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildBaseUrlChip(
                      context,
                      '模拟器地址',
                      'http://10.0.2.2:8092/api/v1/f/private-chat/',
                    ),
                    _buildBaseUrlChip(
                      context,
                      '当前地址',
                      privateChatDio.baseUrl,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _applyBaseUrl,
                    child: const Text('应用'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 拉黑名单卡片
          _buildSectionCard(
            context: context,
            title: '🚫 拉黑名单',
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _blockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '输入用户ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    FilledButton(
                      onPressed: () => _blockUser(provider),
                      style: FilledButton.styleFrom(
                        backgroundColor: WpyTheme.of(context)
                            .get(WpyColorKey.dangerousRed),
                      ),
                      child: const Text('拉黑'),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color:
                    WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
              ),
              if (setting.blockList.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    '暂无拉黑用户 ✅',
                    style: TextUtil.base.regular.sp(14).secondary(context),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: setting.blockList.map((id) {
                      return Chip(
                        avatar: Icon(
                          Icons.block,
                          size: 16.sp,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.dangerousRed),
                        ),
                        label: Text(
                          '用户 $id',
                          style:
                              TextUtil.base.regular.sp(13).label(context),
                        ),
                        deleteIcon: Icon(Icons.close, size: 16.sp),
                        onDeleted: () async {
                          final uid = int.tryParse(id.trim());
                          if (uid != null) {
                            final error =
                                await provider.unblockUser(uid);
                            if (error != null && mounted) {
                              ToastProvider.error(error);
                            }
                          }
                        },
                        backgroundColor: WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 应用新的 baseUrl 设置（测试用）
  void _applyBaseUrl() {
    final value = _baseUrlController.text.trim();
    if (value.isEmpty) {
      ToastProvider.error('请输入有效的 baseUrl');
      return;
    }
    CommonPreferences.privateChatBaseUrl.value = value;
    privateChatDio.baseUrl = value;
    ToastProvider.success('已切换 baseUrl（测试用）');
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextUtil.base.bold.sp(16).label(context),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // 快速设置 baseUrl 的选项卡, 仅供测试使用
  Widget _buildBaseUrlChip(
    BuildContext context,
    String label,
    String url,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () {
        setState(() => _baseUrlController.text = url);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: WpyTheme.of(context)
              .get(WpyColorKey.secondaryBackgroundColor),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: WpyTheme.of(context)
                .get(WpyColorKey.lightBorderColor),
          ),
        ),
        child: Text(
          label,
          style: TextUtil.base.regular.sp(13).label(context),
        ),
      ),
    );
  }

  Future<void> _blockUser(PrivateChatProvider provider) async {
    final id = int.tryParse(_blockController.text.trim());
    if (id == null || id <= 0) {
      ToastProvider.error('请输入有效的用户ID');
      return;
    }
    final error = await provider.blockUser(id);
    if (error != null && mounted) {
      ToastProvider.error(error);
    } else {
      _blockController.clear();
      if (mounted) ToastProvider.success('拉黑成功');
    }
  }
}
