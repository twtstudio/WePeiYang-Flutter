import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import 'home_screen.dart';

/// 登录页面 — 输入用户 ID 和服务器地址
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userIdController = TextEditingController(text: '1001');
  final _hostController = TextEditingController(text: '10.0.2.2');
  final _portController = TextEditingController(text: '8081');
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final userIdStr = _userIdController.text.trim();
    if (userIdStr.isEmpty) {
      _showSnackBar('请输入用户ID');
      return;
    }
    final userId = int.tryParse(userIdStr);
    if (userId == null || userId <= 0) {
      _showSnackBar('请输入有效的用户ID');
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<ChatProvider>();
    provider.serverHost = _hostController.text.trim();
    provider.serverPort = _portController.text.trim();

    try {
      await provider.login(userId);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('连接失败: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1ABC9C), Color(0xFF2C3E50)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 64, color: Color(0xFF1ABC9C)),
                      const SizedBox(height: 8),
                      const Text('私信系统',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Flutter 客户端',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 24),

                      // 用户 ID
                      TextField(
                        controller: _userIdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '用户 ID',
                          hintText: '输入用户ID（如 1001）',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 服务器地址
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _hostController,
                              decoration: InputDecoration(
                                labelText: '服务器地址',
                                hintText: 'IP 或域名',
                                prefixIcon: const Icon(Icons.dns),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _portController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '端口',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '提示：Android 模拟器用 10.0.2.2\n'
                        'iOS 模拟器用 127.0.0.1\n'
                        '真机用电脑局域网 IP',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // 登录按钮
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _login,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.login),
                          label:
                              Text(_isLoading ? '连接中...' : '连接并登录'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1ABC9C),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
