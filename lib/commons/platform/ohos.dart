import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress_common/flutter_image_compress_common.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'ohos_image_picker.dart';

final bool isOhos = !kIsWeb && Platform.operatingSystem == 'ohos';

const ohosSystemChannel = MethodChannel('com.twt.service/ohos_system');

Future<void> initializeOhosPlatform(
    GlobalKey<NavigatorState> navigatorKey) async {
  if (!isOhos) return;
  final paths =
      await ohosSystemChannel.invokeMapMethod<String, String>('getPaths');
  final files = paths?['files'];
  final cache = paths?['cache'];
  if (files == null || cache == null) {
    throw StateError('HarmonyOS application directories are unavailable');
  }
  PathProviderPlatform.instance = _OhosPaths(files, cache);
  final preferences = _OhosPreferences();
  await preferences.importLegacyFiles(files, cache);
  SharedPreferencesStorePlatform.instance = preferences;
  SharedPreferencesAsyncPlatform.instance = _OhosAsyncPreferences(preferences);
  UrlLauncherPlatform.instance = _OhosUrlLauncher();
  FlutterImageCompressCommon.registerWith();
  registerOhosImagePicker(navigatorKey);
}

class _OhosPaths extends PathProviderPlatform {
  _OhosPaths(this.files, this.cache);

  final String files;
  final String cache;

  @override
  Future<String> getApplicationDocumentsPath() async => files;

  @override
  Future<String> getApplicationSupportPath() async => files;

  @override
  Future<String> getApplicationCachePath() async => cache;

  @override
  Future<String> getTemporaryPath() async => cache;

  @override
  Future<String> getDownloadsPath() async =>
      (await Directory('$files/downloads').create(recursive: true)).path;

  @override
  Future<List<String>> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
      [
        (await Directory(
                    '$cache/we_pei_yang_flutter/${type?.name ?? 'external'}')
                .create(recursive: true))
            .path
      ];
}

class _OhosPreferences extends SharedPreferencesStorePlatform {
  static const _channel = MethodChannel('com.twt.service/preferences');
  static const _prefix = 'flutter.';

  Future<void> importLegacyFiles(String files, String cache) async {
    Map<String, Object>? persisted;
    for (final path in {
      '$files/wepeiyang_prefs.json',
      '$cache/wepeiyang_prefs.json',
      '$cache/wepeiyang_state.json',
    }) {
      final file = File(path);
      if (!await file.exists()) continue;
      final existing = persisted ??= await getAll();
      final Map<dynamic, dynamic> values;
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is! Map) continue;
        values = decoded;
      } on FormatException {
        continue;
      }
      if (path.endsWith('/wepeiyang_state.json')) {
        if (values['token'] is String &&
            (values['token'] as String).isNotEmpty) {
          values['login'] = true;
        }
        if (values['tjuuname'] is String &&
            (values['tjuuname'] as String).isNotEmpty) {
          values['bindtju'] = true;
        }
      }
      var complete = true;
      for (final entry in values.entries) {
        if (entry.key is! String) continue;
        final name = entry.key as String;
        final key = name.startsWith(_prefix) ? name : '$_prefix$name';
        if (existing.containsKey(key)) continue;
        final value = entry.value;
        final Object typed;
        if (value is List && value.every((item) => item is String)) {
          typed = List<String>.from(value);
        } else if (value is String || value is bool || value is num) {
          typed = value as Object;
        } else {
          continue;
        }
        if (await setValue('', key, typed)) {
          existing[key] = typed;
        } else {
          complete = false;
        }
      }
      if (complete) await file.delete();
    }
  }

  @override
  Future<Map<String, Object>> getAll() => getAllWithPrefix(_prefix);

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) =>
      getAllWithParameters(
          GetAllParameters(filter: PreferencesFilter(prefix: prefix)));

  @override
  Future<Map<String, Object>> getAllWithParameters(
      GetAllParameters parameters) async {
    final filter = parameters.filter;
    final values = await _channel.invokeMapMethod<String, Object>('getAll', {
          'prefix': filter.prefix,
          'allowList': filter.allowList?.toList(),
        }) ??
        {};
    return {
      for (final entry in values.entries)
        if (entry.key.startsWith(filter.prefix) &&
            (filter.allowList?.contains(entry.key) ?? true))
          entry.key: entry.value is List
              ? List<String>.from(entry.value as List)
              : entry.value,
    };
  }

  @override
  Future<bool> clear() => clearWithPrefix(_prefix);

  @override
  Future<bool> clearWithPrefix(String prefix) => clearWithParameters(
      ClearParameters(filter: PreferencesFilter(prefix: prefix)));

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async =>
      await _channel.invokeMethod<bool>('clear', {
        'prefix': parameters.filter.prefix,
        'allowList': parameters.filter.allowList?.toList(),
      }) ??
      false;

  @override
  Future<bool> remove(String key) async =>
      await _channel.invokeMethod<bool>('remove', {'key': key}) ?? false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      await _channel.invokeMethod<bool>('set', {'key': key, 'value': value}) ??
      false;
}

final class _OhosAsyncPreferences extends SharedPreferencesAsyncPlatform {
  _OhosAsyncPreferences(this.store);

  final _OhosPreferences store;
  // 异步图片缓存使用单独的前缀，清除账号偏好时仍可保留。
  static const _prefix = 'async.';

  PreferencesFilter _filter(Set<String>? keys) => PreferencesFilter(
        prefix: _prefix,
        allowList: keys?.map((key) => '$_prefix$key').toSet(),
      );

  Future<T?> _get<T>(String key) async {
    final values = await store.getAllWithParameters(
      GetAllParameters(filter: _filter({key})),
    );
    final value = values['$_prefix$key'];
    return value as T?;
  }

  Future<void> _set(String key, Object value) async {
    if (!await store.setValue('', '$_prefix$key', value)) {
      throw StateError('Could not save application preference');
    }
  }

  @override
  Future<String?> getString(String key, SharedPreferencesOptions options) =>
      _get<String>(key);

  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) =>
      _get<bool>(key);

  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) =>
      _get<int>(key);

  @override
  Future<double?> getDouble(
          String key, SharedPreferencesOptions options) async =>
      (await _get<num>(key))?.toDouble();

  @override
  Future<List<String>?> getStringList(
          String key, SharedPreferencesOptions options) =>
      _get<List<String>>(key);

  @override
  Future<void> setString(
          String key, String value, SharedPreferencesOptions options) =>
      _set(key, value);

  @override
  Future<void> setBool(
          String key, bool value, SharedPreferencesOptions options) =>
      _set(key, value);

  @override
  Future<void> setInt(
          String key, int value, SharedPreferencesOptions options) =>
      _set(key, value);

  @override
  Future<void> setDouble(
          String key, double value, SharedPreferencesOptions options) =>
      _set(key, value);

  @override
  Future<void> setStringList(
          String key, List<String> value, SharedPreferencesOptions options) =>
      _set(key, value);

  @override
  Future<void> clear(ClearPreferencesParameters parameters,
      SharedPreferencesOptions options) async {
    if (!await store.clearWithParameters(
      ClearParameters(filter: _filter(parameters.filter.allowList)),
    )) {
      throw StateError('Could not clear application preferences');
    }
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final values = await store.getAllWithParameters(
      GetAllParameters(filter: _filter(parameters.filter.allowList)),
    );
    return values
        .map((key, value) => MapEntry(key.substring(_prefix.length), value));
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async =>
      (await getPreferences(parameters, options)).keys.toSet();
}

class _OhosUrlLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async =>
      await ohosSystemChannel
          .invokeMethod<bool>('canLaunchUrl', {'url': url}) ??
      false;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async =>
      await ohosSystemChannel.invokeMethod<bool>('launchUrl', {
        'url': url,
        'appLinkingOnly':
            options.mode == PreferredLaunchMode.externalNonBrowserApplication,
      }) ??
      false;

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async =>
      mode == PreferredLaunchMode.platformDefault ||
      mode == PreferredLaunchMode.externalApplication ||
      mode == PreferredLaunchMode.externalNonBrowserApplication;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => false;
}
