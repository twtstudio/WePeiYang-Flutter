import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/ios_push_registration.dart';

void main() {
  late String token;
  late Map<String, String> info;
  late List<(String, String, Map<String, String>)> calls;
  late IosPushRegistration registration;

  setUp(() {
    token = 'account-a';
    info = {
      'cid': 'cid-one',
      'appId': 'test-app',
      'installId': 'installation',
      'packageName': 'com.twt.WePeiYang-1',
    };
    calls = [];
    registration = IosPushRegistration(
      currentToken: () => token,
      deviceInfo: () async => {...info},
      request: (action, capturedToken, fields) async {
        calls.add((action, capturedToken, fields));
        return PushRegistrationResult.success;
      },
    );
  });

  tearDown(() => registration.dispose());

  test('registers actual installation and refreshes a changed CID', () async {
    await registration.enable();
    expect(calls.single.$1, 'register');
    expect(calls.single.$2, 'account-a');
    expect(calls.single.$3,
        {...info, 'platform': 'IOS', 'environment': 'RELEASE'});
    info['cid'] = 'cid-two';
    await registration.refresh();
    expect(calls.last.$3['cid'], 'cid-two');
  });

  test('no login token means no registration', () async {
    token = '';
    await registration.enable();
    expect(calls, isEmpty);
  });

  test('logout captures old token and ignores late CID callbacks', () async {
    await registration.enable();
    final disabled = registration.disable();
    token = '';
    expect(await disabled, isTrue);
    await registration.refresh();
    expect(calls.map((c) => c.$1), ['register', 'disable']);
    expect(calls.last.$2, 'account-a');
    expect(calls.last.$3, {'appId': 'test-app', 'installId': 'installation'});
  });

  test('account upgrade token clearing does not itself disable the device',
      () async {
    await registration.enable();
    token = '';
    await registration.refresh();
    expect(calls.map((c) => c.$1), ['register']);
  });

  test('switching accounts orders register A, disable A, register B', () async {
    final started = Completer<void>();
    final finish = Completer<PushRegistrationResult>();
    registration.dispose();
    registration = IosPushRegistration(
      currentToken: () => token,
      deviceInfo: () async => {...info},
      request: (action, capturedToken, fields) async {
        calls.add((action, capturedToken, fields));
        if (calls.length == 1) {
          started.complete();
          return finish.future;
        }
        return PushRegistrationResult.success;
      },
    );
    final first = registration.enable();
    await started.future;
    final disabled = registration.disable();
    token = 'account-b';
    final second = registration.enable();
    finish.complete(PushRegistrationResult.success);
    await Future.wait([first, disabled, second]);
    expect(calls.map((c) => (c.$1, c.$2)), [
      ('register', 'account-a'),
      ('disable', 'account-a'),
      ('register', 'account-b'),
    ]);
  });

  test('logout invalidates a registration still waiting for native metadata',
      () async {
    final read = Completer<Map<String, String>>();
    final reading = Completer<void>();
    registration.dispose();
    registration = IosPushRegistration(
      currentToken: () => token,
      deviceInfo: () {
        if (!reading.isCompleted) reading.complete();
        return read.future;
      },
      request: (action, capturedToken, fields) async {
        calls.add((action, capturedToken, fields));
        return PushRegistrationResult.success;
      },
    );
    final enabling = registration.enable();
    await reading.future;
    final disabling = registration.disable();
    token = '';
    read.complete(info);
    await Future.wait([enabling, disabling]);
    expect(calls.map((c) => c.$1), ['disable']);
  });

  testWidgets('missing CID is retried and disposal cancels pending retries',
      (tester) async {
    // Create the queue inside the widget test's fake clock zone.
    registration.dispose();
    registration = IosPushRegistration(
      currentToken: () => token,
      deviceInfo: () async => {...info},
      request: (action, capturedToken, fields) async {
        calls.add((action, capturedToken, fields));
        return PushRegistrationResult.success;
      },
    );
    info['cid'] = '';
    await registration.enable();
    expect(calls, isEmpty);
    info['cid'] = 'cid-ready';
    await tester.pump(const Duration(seconds: 2));
    expect(calls.single.$3['cid'], 'cid-ready');
    info['cid'] = '';
    await registration.refresh();
    registration.dispose();
    info['cid'] = 'late-cid';
    await tester.pump(const Duration(seconds: 30));
    expect(calls.length, 1);
  });

  for (final response in [
    PushRegistrationResult.retry,
    PushRegistrationResult.rejected
  ]) {
    testWidgets('network result $response has bounded retry behavior',
        (tester) async {
      registration.dispose();
      registration = IosPushRegistration(
        currentToken: () => token,
        deviceInfo: () async => {...info},
        request: (action, capturedToken, fields) async {
          calls.add((action, capturedToken, fields));
          return response;
        },
      );
      await registration.enable();
      for (final seconds in [2, 5, 15, 60]) {
        await tester.pump(Duration(seconds: seconds));
      }
      expect(calls.length, response == PushRegistrationResult.retry ? 4 : 1);
    });
  }
}
