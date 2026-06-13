import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';

/// 单个字体在「重新加载」过程中的状态。
enum FontLoadStatus { pending, downloading, loading, success, failed }

/// 一个待下载/加载的字体条目，持有下载任务与实时进度。
class FontReloadEntry {
  final String name; // 友好名称，展示给用户
  final String url;
  DownloadTask task;
  double progress = 0; // 0..1
  FontLoadStatus status = FontLoadStatus.pending;
  String? reason; // 失败原因

  FontReloadEntry({required this.name, required this.url})
      : task = DownloadTask(url: url, type: DownloadType.font);

  String get fileName => task.fileName;
  String get path => task.path;
}

/// 驱动「重新加载字体文件」流程，并通过 [ChangeNotifier] 把下载/加载进度
/// 暴露给 UI。与启动时静默使用的 [WbyFontLoader.initFonts] 区分开，
/// 这里会强制重新下载，以便用户看到真实的下载进度。
class FontReloadController extends ChangeNotifier {
  FontReloadController() {
    entries = [
      FontReloadEntry(name: '思源黑体 Noto', url: 'https://upgrade.twt.edu.cn/font/noto'),
      FontReloadEntry(name: '苹方 PingFang', url: 'https://upgrade.twt.edu.cn/font/ping'),
    ];
  }

  late final List<FontReloadEntry> entries;

  bool _running = false;
  bool _finished = false;
  bool _disposed = false;

  bool get running => _running;
  bool get finished => _finished;

  int get successCount =>
      entries.where((e) => e.status == FontLoadStatus.success).length;
  int get failedCount =>
      entries.where((e) => e.status == FontLoadStatus.failed).length;
  bool get hasFailure => failedCount > 0;

  /// 字体文件所在目录，用于在 UI 中展示文件位置。
  String get directory => DownloadType.font.path;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  FontReloadEntry? _entryByUrl(String url) {
    for (final e in entries) {
      if (e.task.url == url) return e;
    }
    return null;
  }

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _finished = false;
    for (final e in entries) {
      e
        ..task = DownloadTask(url: e.url, type: DownloadType.font)
        ..progress = 0
        ..status = FontLoadStatus.pending
        ..reason = null;
    }
    _notify();

    // 强制重新下载：先删掉已缓存的文件，否则下载会被直接跳过、看不到进度。
    for (final e in entries) {
      try {
        final f = File(e.task.path);
        if (f.existsSync()) f.deleteSync();
      } catch (err, s) {
        Log.e(err, s);
      }
    }

    if (Platform.isAndroid) {
      _startAndroid();
    } else {
      await _startIOS();
    }
  }

  void _startAndroid() {
    // downloads 会修改传入的 list，复制一份避免影响 entries。
    final tasks = entries.map((e) => e.task).toList();
    DownloadManager.getInstance().downloads(
      tasks,
      download_running: (task, progress) {
        final e = _entryByUrl(task.url);
        if (e == null) return;
        e
          ..progress = progress.clamp(0.0, 1.0)
          ..status = FontLoadStatus.downloading;
        _notify();
      },
      download_failed: (task, progress, reason) {
        final e = _entryByUrl(task.url);
        if (e == null) return;
        e
          ..status = FontLoadStatus.failed
          ..reason = reason;
        _notify();
        _maybeFinish();
      },
      download_success: (task) async {
        final e = _entryByUrl(task.url);
        if (e == null) return;
        e
          ..progress = 1
          ..status = FontLoadStatus.loading;
        _notify();
        await _loadFromFile(e);
        _maybeFinish();
      },
      all_complete: (success, failed) => _maybeFinish(),
    );
  }

  Future<void> _startIOS() async {
    final dio = Dio();
    await Future.wait(entries.map((e) async {
      try {
        final dir = Directory(p.dirname(e.task.path));
        if (!dir.existsSync()) dir.createSync(recursive: true);
        e.status = FontLoadStatus.downloading;
        _notify();
        final res = await dio.get(
          e.task.url,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              e.progress = (received / total).clamp(0.0, 1.0);
              _notify();
            }
          },
        );
        final data = Uint8List.fromList((res.data as List).cast<int>());
        File(e.task.path).writeAsBytesSync(data);
        e
          ..progress = 1
          ..status = FontLoadStatus.loading;
        _notify();
        await _loadFromBytes(e, data);
      } catch (err, s) {
        Log.e(err, s);
        e
          ..status = FontLoadStatus.failed
          ..reason = '$err';
        _notify();
      }
    }));
    _markFinished();
  }

  Future<void> _loadFromFile(FontReloadEntry e) async {
    try {
      final list = await File(e.task.path).readAsBytes();
      await _loadFromBytes(e, list);
    } catch (err, s) {
      Log.e(err, s);
      e
        ..status = FontLoadStatus.failed
        ..reason = '$err';
      _notify();
    }
  }

  Future<void> _loadFromBytes(FontReloadEntry e, Uint8List list) async {
    String? family = e.task.path.split('/').last.split('-').first;
    // 如果截取的 family 不全由字母组成，则让 loadFontFromList 自己解析。
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(family)) family = null;
    await loadFontFromList(list, fontFamily: family);
    e.status = FontLoadStatus.success;
    _notify();
  }

  void _maybeFinish() {
    final done = entries.every((e) =>
        e.status == FontLoadStatus.success ||
        e.status == FontLoadStatus.failed);
    if (done) _markFinished();
  }

  void _markFinished() {
    if (_finished) return;
    _running = false;
    _finished = true;
    _notify();
  }
}
