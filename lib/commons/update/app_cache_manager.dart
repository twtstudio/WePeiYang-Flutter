import 'dart:io';
import 'package:path_provider/path_provider.dart';

//加载缓存
searchLocalCache() async {
  Directory tempDir = await getExternalStorageDirectory();
  double value = await _getTotalSizeOfFilesInDir(tempDir);
  /*tempDir.list(followLinks: false,recursive: true).listen((file){
          //打印每个缓存文件的路径
        print(file.path);
      });*/
  // print('临时目录大小: ' + _renderSize(value));
  await delAllTemporaryFile();
}

// 循环计算文件的大小（递归）
Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
  if (file is File) {
    int length = await file.length();
    return double.parse(length.toString());
  }
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    double total = 0;
    if (children != null)
      for (final FileSystemEntity child in children)
        total += await _getTotalSizeOfFilesInDir(child);
    return total;
  }
  return 0;
}

// 递归方式删除目录
Future<Null> _delDir(FileSystemEntity file) async {
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    for (final FileSystemEntity child in children) {
      await _delDir(child);
    }
  }
  await file.delete();
}

Future<Null> delAllTemporaryFile() async {
  Directory tempDir = await getExternalStorageDirectory();
  final List<FileSystemEntity> children = tempDir.listSync();
  for (var child in children) {
    if (child.path.endsWith("gtpush")) continue;
    if (child is Directory) {
      var delete = true;
      var reg = RegExp(r'^[0-9].[0-9].[0-9]$');
      var dirName = child.path.substring(
          child.path.lastIndexOf("/") + 1,
          child.path.length);
      if (reg.hasMatch(dirName)) {
        for (var apk in child.listSync()) {
          if (apk.path.endsWith('apk')) {
            delete = false;
          }
        }
      }
      if (delete) {
        await _delDir(child);
      }
    } else {
      await child.delete();
    }
  }
}

// 计算大小
String _renderSize(double value) {
  if (null == value) {
    return '';
  }
  List<String> unitArr = List()..add('B')..add('K')..add('M')..add('G');
  int index = 0;
  while (value > 1024) {
    index++;
    value = value / 1024;
  }
  String size = value.toStringAsFixed(2);
  if (size == '0.00') {
    return '0M';
  }
  return size + unitArr[index];
}

void clearCache() async {
  Directory tempDir = await getExternalStorageDirectory();
  //删除缓存目录
  await _delDir(tempDir);
  await searchLocalCache();
}
