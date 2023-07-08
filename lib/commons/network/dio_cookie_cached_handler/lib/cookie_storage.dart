import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'cookie.dart';

/// Our main class. This is where our main job is done.
class CookieStorage {
  final DateFormat _cookieDateFormat = DateFormat("EEE, dd MMM yyyy HH':'mm':'ss 'GMT'");
  File? _file;
  final Set<Cookie> _cookies = {};
  final Future<String> storePath;

  CookieStorage(this.storePath);

  Future<File> _ensureOpen() async {
    if (_file == null) {
      await _init();
    }
    return _file!;
  }

  Future<void> clear() async {
    _cookies.clear();
    final file = _file;
    if (file != null && file.existsSync()) {
      await file.writeAsString("", mode: FileMode.write, flush: true);
    }
  }

  Future<void> _init() async {
    final file = File(await storePath);
    debugPrint("restoring from: $file");
    final exists = await file.exists();
    if (exists) {
      final lines = await file.readAsLines();
      final now = DateTime.now();
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) {
          continue;
        }
        debugPrint("restoring cookie $line");
        final i = line.indexOf('=');
        final j = line.indexOf(';', i);
        final key = line.substring(0, i);
        final value = line.substring(i + 1, j);
        final expireStr = line.substring(j + 1);
        final expire = DateTime.parse(expireStr);
        if (now.isAfter(expire)) {
          continue;
        }
        _cookies.add(Cookie(name: key, value: value, expires: expire));
      }
    } else {
      await file.create();
    }
    _file = file;
  }

  Future<void> storeAll() async {
    final file = await _ensureOpen();
    final sink = file.openWrite(mode: FileMode.write);
    debugPrint("storing into $file");
    try {
      final now = DateTime.now();
      final remove = <Cookie>[];
      for (final cookie in _cookies) {
        if (now.isBefore(cookie.expires)) {
          debugPrint("storing cookie: ${cookie.name}=${cookie.value};${cookie.expires.toIso8601String()}");
          sink
            ..write(cookie.name)
            ..write("=")
            ..write(cookie.value)
            ..write(";")
            ..write(cookie.expires.toIso8601String())
            ..write("\n");
        } else {
          remove.add(cookie);
        }
      }
      debugPrint("removing expired cookies: $remove");
      _cookies.removeAll(remove);
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  DateTime? findExpiresAttr(String setCookie, int startIndex) {
    final ai = setCookie.indexOf("Expires=", startIndex);
    if (ai == -1) {
      return null;
    }
    final i = ai + 8;
    final j = setCookie.indexOf(';', i);
    final expiresStr = j == -1 ? setCookie.substring(i) : setCookie.substring(i, j);

    try {
      return _cookieDateFormat.parse(expiresStr, true);
    } catch (_) {
      return null;
    }
  }

  DateTime? findMaxAgeAttr(String setCookie, int startIndex, DateTime now) {
    final ai = setCookie.indexOf("Max-Age=", startIndex);
    if (ai == -1) {
      return null;
    }

    final i = ai + 8;
    final j = setCookie.indexOf(';', i);
    final maxAgeStr = j == -1 ? setCookie.substring(i) : setCookie.substring(i, j);
    final maxAge = int.parse(maxAgeStr);

    return now.add(Duration(seconds: maxAge));
  }

  Future<void> storeFromRes(Response<dynamic> res) async {
    final setCookies = res.headers["Set-Cookie"];
    if (setCookies != null) {
      debugPrint("Set-Cookie headers $setCookies");
      final now = DateTime.now();
      for (final setCookie in setCookies) {
        final i = setCookie.indexOf('=');
        final j = setCookie.indexOf(';', i);

        final key = setCookie.substring(0, i);
        late final String value;
        late final DateTime expires;

        if (j == -1) {
          value = setCookie.substring(i + 1);
          expires = now.add(const Duration(days: 400));
        } else {
          value = setCookie.substring(i + 1, j);
          expires =
              findExpiresAttr(setCookie, j) ?? findMaxAgeAttr(setCookie, j, now) ?? now.add(const Duration(days: 400));
        }

        final cookie = Cookie(name: key, value: value, expires: expires);
        _cookies.remove(cookie);
        if (now.isBefore(expires)) {
          _cookies.add(cookie);
        }
      }
      await storeAll();
    }
  }

  Future<void> loadToReq(RequestOptions options) async {
    await _ensureOpen();
    final resultStr = await toCookieString();
    if (resultStr != null) {
      options.headers["cookie"] = resultStr;
    }
  }

  Future<String?> toCookieString() async {
    await _ensureOpen();
    if (_cookies.isNotEmpty) {
      final result = StringBuffer();
      final now = DateTime.now();
      final remove = <Cookie>[];
      for (final cookie in _cookies) {
        if (now.isAfter(cookie.expires)) {
          remove.add(cookie);
          continue;
        }
        if (result.isNotEmpty) {
          result.write("; ");
        }
        result.write("${cookie.name}=${cookie.value}");
      }
      _cookies.removeAll(remove);
      final resultStr = result.toString();
      debugPrint("Request Cookies: $resultStr");
      return resultStr;
    } else {
      return null;
    }
  }
}