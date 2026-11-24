import 'dart:async';

import 'package:dio/dio.dart';

enum PushRegistrationResult { success, retry, rejected }

typedef PushDeviceRequest = Future<PushRegistrationResult> Function(
    String action, String token, Map<String, String> fields);

/// Serializes account changes so an old CID callback cannot rebind after logout.
/// Credentials are captured per session and are never persisted by this class.
class IosPushRegistration {
  IosPushRegistration({
    required this.currentToken,
    required this.deviceInfo,
    required this.request,
    this.environment = 'RELEASE',
    this.retryDelays = const [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 15),
    ],
  });

  final String Function() currentToken;
  final Future<Map<String, String>> Function() deviceInfo;
  final PushDeviceRequest request;
  final String environment;
  final List<Duration> retryDelays;
  Future<void> _tail = Future.value();
  Timer? _retry;
  int _generation = 0;
  String? _sessionToken;
  bool _disposed = false;

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> enable() {
    if (_disposed) return Future.value();
    _sessionToken = currentToken().trim();
    return refresh();
  }

  Future<void> refresh() {
    if (_disposed || _sessionToken == null || _sessionToken!.isEmpty) {
      return Future.value();
    }
    _retry?.cancel();
    final generation = ++_generation;
    return _register(generation, _sessionToken!, 0);
  }

  bool _isCurrent(int generation, String token) =>
      !_disposed &&
      generation == _generation &&
      _sessionToken == token &&
      currentToken().trim() == token;

  Future<void> _register(int generation, String token, int attempt) =>
      _enqueue(() async {
        if (!_isCurrent(generation, token)) return;
        var result = PushRegistrationResult.retry;
        try {
          final info = await deviceInfo();
          if (!_isCurrent(generation, token)) return;
          if (_validIdentity(info) && (info['cid'] ?? '').isNotEmpty) {
            result = await request('register', token, {
              ...info,
              'platform': 'IOS',
              'environment': environment,
            });
          }
        } catch (_) {
          // No request/token/CID logging. Retry only within this login session.
        }
        if (result == PushRegistrationResult.retry &&
            _isCurrent(generation, token) &&
            attempt < retryDelays.length) {
          _retry = Timer(retryDelays[attempt], () {
            unawaited(_register(generation, token, attempt + 1));
          });
        }
      });

  /// Call before clearing login data. Queued disables retain the old token,
  /// and complete before a later account's registration can start.
  Future<bool> disable() {
    final token = currentToken().trim();
    _sessionToken = null;
    ++_generation;
    _retry?.cancel();
    return _enqueue(() async {
      if (token.isEmpty) return false;
      try {
        final info = await deviceInfo();
        if (!_validIdentity(info)) return false;
        return await request('disable', token, {
              'appId': info['appId']!,
              'installId': info['installId']!,
            }) ==
            PushRegistrationResult.success;
      } catch (_) {
        return false;
      }
    });
  }

  static bool _validIdentity(Map<String, String> info) => [
        'appId',
        'packageName',
        'installId'
      ].every((key) => (info[key] ?? '').isNotEmpty);

  void dispose() {
    _disposed = true;
    ++_generation;
    _retry?.cancel();
  }
}

/// Uses the same JWT-authenticated registry as Android. A separate Dio instance
/// avoids logging credentials or replaying a request with a different account.
class IosPushDeviceApi {
  IosPushDeviceApi({required Map<String, String> applicationHeaders, Dio? dio})
      : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.twt.edu.cn/api/notification/device/',
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: Headers.formUrlEncodedContentType,
      followRedirects: false,
      headers: {...applicationHeaders},
    );
  }

  final Dio _dio;

  Future<PushRegistrationResult> request(
      String action, String token, Map<String, String> fields) async {
    try {
      final response = await _dio.post<Object?>(action,
          data: fields, options: Options(headers: {'token': token}));
      final body = response.data;
      if (body is! Map) return PushRegistrationResult.retry;
      final code = body['error_code'];
      if (code == 0) return PushRegistrationResult.success;
      return code == -1 ||
              code == 50003 ||
              code == 50004 ||
              (code is num && code >= 40000 && code < 50000)
          ? PushRegistrationResult.rejected
          : PushRegistrationResult.retry;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      return status != null && status >= 400 && status < 500 && status != 429
          ? PushRegistrationResult.rejected
          : PushRegistrationResult.retry;
    }
  }
}
