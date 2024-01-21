import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';

import '../widgets/w_button.dart';

class UpdateTestPage extends StatefulWidget {
  const UpdateTestPage({Key? key}) : super(key: key);

  @override
  _UpdateTestPageState createState() => _UpdateTestPageState();
}

class _UpdateTestPageState extends State<UpdateTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更新测试页面'),
      ),
      body: ListView(
        children: [
          WButton(onPressed: _deleteAllApk, child: Text('删除所有安装包')),
          WButton(onPressed: _deleteAllSo, child: Text('删除所有so')),
          WButton(
            onPressed: () {
              context.read<UpdateManager>().checkUpdate(auto: false);
            },
            child: Text('检查更新'),
          ),
        ],
      ),
    );
  }
}

Future<void> _deleteAllApk() async {
  final dir =
      (await getExternalStorageDirectories(type: StorageDirectory.downloads))
          ?.first;
  if (dir == null) {
    // 没有这个文件夹就很尬
  }
  final apkDir = Directory(dir!.path + Platform.pathSeparator + 'apk');
  if (apkDir.existsSync()) {
    for (var file in apkDir.listSync()) {
      final name = file.path.split(Platform.pathSeparator).last;
      debugPrint('current file: ' + name);
      final list = name.split('-');
      if (name.endsWith('.apk') && list.length == 3) {
        file.delete();
      }
    }
  }
}

Future<void> _deleteAllSo() async {
  final dir =
      (await getExternalStorageDirectories(type: StorageDirectory.downloads))
          ?.first;
  if (dir == null) {
    // 没有这个文件夹就很尬
  }
  final apkDir = Directory(dir!.path + Platform.pathSeparator + 'hotfix');
  if (apkDir.existsSync()) {
    for (var file in apkDir.listSync()) {
      final name = file.path.split(Platform.pathSeparator).last;
      debugPrint('current file: ' + name);
      final list = name.split('-');
      if (name.endsWith('.so') && list.length == 3) {
        file.delete();
      }
    }
  }
}
