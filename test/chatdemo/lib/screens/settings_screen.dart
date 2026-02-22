import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';

/// 用户设置页面 — 私信开关、陌生人策略、拉黑管理
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final provider = context.read<ChatProvider>();
    final error = await provider.loadSetting();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final setting = provider.userSetting;
        if (setting == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('设置尚未加载'),
                const SizedBox(height: 16),
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
            padding: const EdgeInsets.all(16),
            children: [
              // ===== 私信设置 =====
              _buildSectionCard(
                title: '📨 私信设置',
                children: [
                  SwitchListTile(
                    title: const Text('私信总开关'),
                    subtitle: Text(setting.isEnable == 1 ? '已开启' : '已关闭'),
                    value: setting.isEnable == 1,
                    activeColor: const Color(0xFF27AE60),
                    onChanged: (val) async {
                      final error = await provider.toggleEnable(val);
                      if (error != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('接收陌生人私信'),
                    subtitle:
                        Text(setting.isAcceptStranger == 1 ? '已开启' : '已关闭'),
                    value: setting.isAcceptStranger == 1,
                    activeColor: const Color(0xFF27AE60),
                    onChanged: (val) async {
                      final error = await provider.toggleStranger(val);
                      if (error != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== 拉黑名单 =====
              _buildSectionCard(
                title: '🚫 拉黑名单',
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _blockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '输入用户ID',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _blockUser(provider),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('拉黑'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (setting.blockList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '暂无拉黑用户 ✅',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: setting.blockList.map((id) {
                          return Chip(
                            avatar: const Icon(Icons.block,
                                size: 16, color: Colors.red),
                            label: Text('用户 $id'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () async {
                              final uid = int.tryParse(id.trim());
                              if (uid != null) {
                                final error =
                                    await provider.unblockUser(uid);
                                if (error != null && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                }
                              }
                            },
                            backgroundColor: Colors.red[50],
                            side: BorderSide(color: Colors.red[200]!),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  final _blockController = TextEditingController();

  Future<void> _blockUser(ChatProvider provider) async {
    final id = int.tryParse(_blockController.text.trim());
    if (id == null || id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的用户ID')),
      );
      return;
    }
    final error = await provider.blockUser(id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      _blockController.clear();
    }
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _blockController.dispose();
    super.dispose();
  }
}
