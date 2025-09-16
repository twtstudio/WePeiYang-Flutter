import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageCacheService {
  ImageCacheService._();
  static final ImageCacheService instance = ImageCacheService._();

  final Dio _dio = Dio();

  static const String _spKeyExpiresMap = 'imageExpiresMap';

  Future<void> ensureAllCached(List<String> urls) async {
    for (final url in urls) {
      await ensureCached(url);
    }
  }

  Future<File> ensureCached(String url) async {
    final file = await _localFileForUrl(url);
    final expires = await _getExpires(url);

    final needFetch = !await file.exists() ||
        expires == null ||
        DateTime.now().isAfter(expires);

    _dlog('[ImageCacheService] ensureCached url=$url');
    _dlog('[ImageCacheService] localFile=${file.path}');
    _dlog(
        '[ImageCacheService] expires=${expires?.toIso8601String()} needFetch=$needFetch');

    if (needFetch) {
      return await _downloadAndSave(url, file);
    }
    return file;
  }

  Future<File?> getLocalFileIfExists(String url) async {
    final file = await _localFileForUrl(url);
    final exists = await file.exists();
    _dlog(
        '[ImageCacheService] getLocalFileIfExists url=$url exists=$exists path=${file.path}');
    if (exists) return file;
    return null;
  }

  Future<File> _downloadAndSave(String url, File file) async {
    _dlog('[ImageCacheService] downloading url=$url');
    final resp = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes, followRedirects: true),
    );

    await file.create(recursive: true);
    await file.writeAsBytes(resp.data!);
    _dlog(
        '[ImageCacheService] saved bytes=${resp.data?.length} to ${file.path}');

    final expiresHeader = _firstHeader(resp.headers, 'expires');
    DateTime? expires = _parseExpires(expiresHeader);

    if (expires == null) {
      final cacheControl = _firstHeader(resp.headers, 'cache-control');
      final maxAge = _parseMaxAge(cacheControl);
      if (maxAge != null) {
        expires = DateTime.now().add(Duration(seconds: maxAge));
      }
    }

    expires ??= DateTime.now().add(const Duration(days: 30));

    await _saveExpires(url, expires);
    _dlog(
        '[ImageCacheService] set expires=${expires.toIso8601String()} for url=$url');

    return file;
  }

  String? _firstHeader(Headers headers, String name) {
    try {
      final v = headers.map[name.toLowerCase()] ??
          headers.map[name] ??
          headers.value(name);
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String) return v;
      return headers.value(name);
    } catch (_) {
      return null;
    }
  }

  int? _parseMaxAge(String? cacheControl) {
    if (cacheControl == null) return null;
    final parts = cacheControl.toLowerCase().split(',').map((e) => e.trim());
    for (final p in parts) {
      if (p.startsWith('max-age=')) {
        final n = int.tryParse(p.substring('max-age='.length));
        if (n != null && n >= 0) return n;
      }
    }
    return null;
  }

  DateTime? _parseExpires(String? expiresHeader) {
    if (expiresHeader == null) return null;
    try {
      return HttpDate.parse(expiresHeader);
    } catch (_) {
      return null;
    }
  }

  Future<File> _localFileForUrl(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeName = _fileNameFromUrl(url);
    return File('${dir.path}/image_cache/$safeName');
  }

  String _fileNameFromUrl(String url) {
    final segs = Uri.parse(url).pathSegments;
    final base = segs.isNotEmpty ? segs.last : 'image';
    final sanitized = base.isEmpty ? 'image' : base;
    final hash = url.hashCode.toUnsigned(32).toRadixString(16);
    final hasExt = sanitized.contains('.');
    return hasExt ? '${sanitized}_$hash' : '${sanitized}_$hash.img';
  }

  Future<void> _saveExpires(String url, DateTime expires) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_spKeyExpiresMap) ?? '{}';
    final Map<String, dynamic> map = _decodeJsonSafe(raw);
    map[url] = expires.millisecondsSinceEpoch;
    await sp.setString(_spKeyExpiresMap, json.encode(map));
  }

  Future<DateTime?> _getExpires(String url) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_spKeyExpiresMap) ?? '{}';
    final Map<String, dynamic> map = _decodeJsonSafe(raw);
    final v = map[url];
    if (v == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(v as int);
  }

  Map<String, dynamic> _decodeJsonSafe(String raw) {
    try {
      final m = json.decode(raw);
      if (m is Map<String, dynamic>) return m;
      if (m is Map) return m.map((k, v) => MapEntry(k.toString(), v));
      return <String, dynamic>{};
    } catch (e) {
      _dlog('[ImageCacheService] JSON decode error: $e');
      return <String, dynamic>{};
    }
  }

  Future<void> clearAllCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      _dlog('[ImageCacheService] cleared cache dir ${cacheDir.path}');
    }
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_spKeyExpiresMap);
  }

  void _dlog(Object? o) {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    // ignore: avoid_print
    print('$hh:$mm:$ss | $o');
  }
}
