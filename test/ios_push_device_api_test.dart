import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/ios_push_registration.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions, String) respond;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final bytes = await requestStream!.expand((part) => part).toList();
    return respond(options, utf8.decode(bytes));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  IosPushDeviceApi api(_Adapter adapter) => IosPushDeviceApi(
        applicationHeaders: {'DOMAIN': 'test.example', 'ticket': 'test-ticket'},
        dio: Dio()..httpClientAdapter = adapter,
      );

  ResponseBody response(int code, {int status = 200}) =>
      ResponseBody.fromString(
        jsonEncode({'error_code': code}),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        },
      );

  test(
      'registration and disable include application authentication and captured token',
      () async {
    final client = api(_Adapter((options, body) async {
      expect(options.method, 'POST');
      expect(options.uri.origin, 'https://api.twt.edu.cn');
      expect(options.uri.path, '/api/notification/device/${options.path}');
      expect(options.headers['DOMAIN'], 'test.example');
      expect(options.headers['ticket'], 'test-ticket');
      expect(options.headers['token'], 'captured-account');
      expect(options.followRedirects, isFalse);
      expect(options.contentType, Headers.formUrlEncodedContentType);
      expect(Uri.splitQueryString(body),
          {'appId': 'test-app', 'installId': 'test-install'});
      return response(0);
    }));
    for (final action in ['register', 'disable']) {
      expect(
          await client.request(action, 'captured-account', {
            'appId': 'test-app',
            'installId': 'test-install',
          }),
          PushRegistrationResult.success);
    }
  });

  for (final code in [-1, 40005, 50003, 50004]) {
    test('invalid parameters or authentication code $code stops retrying',
        () async {
      final client = api(_Adapter((_, __) async => response(code)));
      expect(await client.request('register', 'test-token', {}),
          PushRegistrationResult.rejected);
    });
  }

  test('server failure can retry', () async {
    final client = api(_Adapter((_, __) async => response(50001)));
    expect(await client.request('register', 'test-token', {}),
        PushRegistrationResult.retry);
  });

  test('transport errors classify authentication versus temporary failures',
      () async {
    for (final status in [401, 429, 503]) {
      final client =
          api(_Adapter((_, __) async => response(0, status: status)));
      expect(
          await client.request('register', 'test-token', {}),
          status == 401
              ? PushRegistrationResult.rejected
              : PushRegistrationResult.retry);
    }
    final client = api(_Adapter((options, _) async {
      throw DioException(
          requestOptions: options, type: DioExceptionType.connectionTimeout);
    }));
    expect(await client.request('register', 'test-token', {}),
        PushRegistrationResult.retry);
  });
}
