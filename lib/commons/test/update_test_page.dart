import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import '../widgets/w_button.dart';

class UpdateTestPage extends StatefulWidget {
  const UpdateTestPage({super.key});

  @override
  State<UpdateTestPage> createState() => _UpdateTestPageState();
}

class _UpdateTestPageState extends State<UpdateTestPage> {
  Future<void> _deleteAllApk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final apkDir = Directory('${dir.path}/apk');
      if (apkDir.existsSync()) {
        for (final file in apkDir.listSync()) {
          final name = file.path.split(Platform.pathSeparator).last;
          if (name.endsWith('.apk') && name.split('-').length == 3) {
            file.deleteSync();
          }
        }
      }
      ToastProvider.success('APK 已清除');
    } catch (e) {
      ToastProvider.error('失败: $e');
    }
  }

  Future<void> _deleteAllSo() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final hotfixDir = Directory('${dir.path}/hotfix');
      if (hotfixDir.existsSync()) {
        for (final file in hotfixDir.listSync()) {
          final name = file.path.split(Platform.pathSeparator).last;
          if (name.endsWith('.so') && name.split('-').length == 3) {
            file.deleteSync();
          }
        }
      }
      ToastProvider.success('SO 已清除');
    } catch (e) {
      ToastProvider.error('失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(title: const Text('更新测试')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            WButton(onPressed: _deleteAllApk, child: const Text('删除所有 APK')),
            const SizedBox(height: 12),
            WButton(onPressed: _deleteAllSo, child: const Text('删除所有 SO')),
            const SizedBox(height: 12),
            WButton(
              onPressed: () => context.read<UpdateManager>().checkUpdate(auto: false),
              child: const Text('检查更新'),
            ),
          ],
        ),
      ),
    );
  }
}
