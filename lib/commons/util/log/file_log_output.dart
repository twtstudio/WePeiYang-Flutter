import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 把日志行追加写入本地滚动文件。
///
/// 目的：让日志在 **杀进程 / 崩溃 / 重启后依然能捞到**，并支持导出分享。
/// 写入串行化（单 Future 链）、带大小滚动；任何写文件失败都被吞掉，
/// 绝不反过来影响 app 运行。
class FileLogOutput {
  FileLogOutput._();

  static final FileLogOutput instance = FileLogOutput._();

  /// 单个日志文件上限，超过就滚动到备份。
  static const int _maxBytes = 2 * 1024 * 1024; // 2MB
  static const String _fileName = 'app.log';
  static const String _backupName = 'app.1.log';

  File? _file;
  bool _initializing = false;

  /// init 完成前先缓存日志行，避免启动早期日志丢失（限量防止无限增长）。
  final List<String> _pending = [];
  Future<void> _chain = Future.value();

  /// 在 app 启动早期调用一次。多次调用安全。
  Future<void> init() async {
    if (_file != null || _initializing) return;
    _initializing = true;
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/logs');
      if (!await dir.exists()) await dir.create(recursive: true);
      _file = File('${dir.path}/$_fileName');

      // flush 启动早期积压的日志。
      if (_pending.isNotEmpty) {
        final buffered = List<String>.from(_pending);
        _pending.clear();
        for (final line in buffered) write(line);
      }
    } catch (_) {
      // 文件不可用就放弃文件持久化，控制台/内存历史不受影响。
    } finally {
      _initializing = false;
    }
  }

  /// 追加一行日志（同步入队，异步落盘）。
  void write(String line) {
    final file = _file;
    if (file == null) {
      if (_pending.length < 500) _pending.add(line);
      return;
    }
    _chain = _chain.then((_) => _append(file, line)).catchError((_) {});
  }

  Future<void> _append(File file, String line) async {
    await file.writeAsString('$line\n', mode: FileMode.append, flush: false);
    await _rotateIfNeeded(file);
  }

  Future<void> _rotateIfNeeded(File file) async {
    try {
      if (await file.length() < _maxBytes) return;
      final backup = File('${file.parent.path}/$_backupName');
      if (await backup.exists()) await backup.delete();
      await file.rename(backup.path);
      // 同名新文件会在下次 append 时自动创建。
      _file = File(file.path);
    } catch (_) {}
  }

  /// 现存日志文件（新 → 旧），供导出 / 读取。
  Future<List<File>> logFiles() async {
    final files = <File>[];
    final current = _file;
    if (current != null && await current.exists()) files.add(current);
    if (current != null) {
      final backup = File('${current.parent.path}/$_backupName');
      if (await backup.exists()) files.add(backup);
    }
    return files;
  }

  /// 按时间顺序（旧 → 新）读出全部日志文本。
  Future<String> readAll() async {
    final buffer = StringBuffer();
    final files = await logFiles();
    for (final file in files.reversed) {
      buffer.writeln(await file.readAsString());
    }
    return buffer.toString();
  }

  Future<void> clear() async {
    _chain = _chain.then((_) async {
      for (final file in await logFiles()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    });
    await _chain;
  }
}
