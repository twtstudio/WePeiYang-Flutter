import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/ios_push_registration.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.twt.service/push');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late PushManager manager;
  late Future<Object?> Function(MethodCall) native;
  late PushDeviceRequest request;
  late List<(String, String)> requests;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'account-a'});
    await CommonPreferences.init();
    requests = [];
    request = (_, __, ___) async => PushRegistrationResult.success;
    native = (_) async => 'open push service success';
    messenger.setMockMethodCallHandler(channel, (call) => native(call));
    manager = PushManager(
      isIOS: true,
      iosRegistration: IosPushRegistration(
        currentToken: () => CommonPreferences.token.value,
        deviceInfo: () async => {
          'cid': 'test-cid',
          'appId': 'test-app',
          'installId': 'test-installation',
          'packageName': 'com.twt.WePeiYang-1',
        },
        request: (action, token, fields) {
          requests.add((action, token));
          return request(action, token, fields);
        },
      ),
    );
  });

  tearDown(() {
    manager.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  Future<void> drain() => Future<void>.delayed(Duration.zero);
  Future<void> turnOn() => manager.turnOnPushService(
      () {}, () => fail('Unexpected refusal'), () => fail('Unexpected error'));

  test('slow disable cannot overwrite a subsequent enable', () async {
    await turnOn();
    await drain();
    final disableStarted = Completer<void>();
    final finishDisable = Completer<PushRegistrationResult>();
    request = (action, _, __) async {
      if (action == 'disable') {
        disableStarted.complete();
        return finishDisable.future;
      }
      return PushRegistrationResult.success;
    };
    native = (call) async => call.method == 'turnOffPushService'
        ? null
        : 'open push service success';
    var oldCallbacks = 0;
    final stopping =
        manager.turnOffPushService(() => oldCallbacks++, () => oldCallbacks++);
    await disableStarted.future;
    await turnOn();
    finishDisable.complete(PushRegistrationResult.success);
    await stopping;
    await drain();
    expect(manager.openPush, isTrue);
    expect(oldCallbacks, 0);
    expect(requests.map((r) => r.$1), ['register', 'disable', 'register']);
  });

  test('late native failure after re-enabling does not report an old error',
      () async {
    final finishStop = Completer<Object?>();
    final stopStarted = Completer<void>();
    native = (call) async {
      if (call.method == 'turnOffPushService') {
        stopStarted.complete();
        return finishStop.future;
      }
      return 'open push service success';
    };
    var oldCallbacks = 0;
    final stopping =
        manager.turnOffPushService(() => oldCallbacks++, () => oldCallbacks++);
    await stopStarted.future;
    await turnOn();
    finishStop.completeError(PlatformException(code: 'STOP_FAILED'));
    await stopping;
    expect(manager.openPush, isTrue);
    expect(oldCallbacks, 0);
  });

  test(
      'logout invalidates pending permission and registers only the new account',
      () async {
    final permission = Completer<Object?>();
    final permissionStarted = Completer<void>();
    native = (call) async {
      if (call.method == 'turnOnPushService') {
        permissionStarted.complete();
        return permission.future;
      }
      return null;
    };
    var oldCallbacks = 0;
    final enabling = manager.turnOnPushService(
        () => oldCallbacks++, () => oldCallbacks++, () => oldCallbacks++);
    await permissionStarted.future;
    await manager.disablePushDevice();
    CommonPreferences.token.value = 'account-b';
    native = (_) async => 'open push service success';
    await manager.initGeTuiSdk();
    permission.complete('open push service success');
    await enabling;
    await drain();
    expect(manager.openPush, isTrue);
    expect(oldCallbacks, 0);
    expect(requests, [('disable', 'account-a'), ('register', 'account-b')]);
  });

  test(
      'a stale permission error cannot clear a newer initialization busy state',
      () async {
    final first = Completer<Object?>();
    final firstStarted = Completer<void>();
    final second = Completer<Object?>();
    final secondStarted = Completer<void>();
    var initCalls = 0;
    var oldCallbacks = 0;
    native = (call) async {
      if (call.method == 'turnOnPushService') {
        firstStarted.complete();
        return first.future;
      }
      if (call.method == 'initGeTuiSdk') {
        initCalls++;
        if (!secondStarted.isCompleted) secondStarted.complete();
        return second.future;
      }
      return null;
    };
    final enabling = manager.turnOnPushService(
        () => oldCallbacks++, () => oldCallbacks++, () => oldCallbacks++);
    await firstStarted.future;
    await manager.disablePushDevice();
    final initializing = manager.initGeTuiSdk();
    await secondStarted.future;
    first.completeError(PlatformException(code: 'PERMISSION_FAILED'));
    await enabling;
    manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await drain();
    second.complete('open push service success');
    await initializing;
    await drain();
    expect(initCalls, 1);
    expect(oldCallbacks, 0);
    expect(manager.openPush, isTrue);
  });

  test('disposing while disable is pending suppresses completion callbacks',
      () async {
    final finishStop = Completer<Object?>();
    final stopStarted = Completer<void>();
    native = (_) async {
      stopStarted.complete();
      return finishStop.future;
    };
    var callbacks = 0;
    final stopping =
        manager.turnOffPushService(() => callbacks++, () => callbacks++);
    await stopStarted.future;
    manager.dispose();
    finishStop.complete(null);
    await stopping;
    // Supply a fresh instance for the common teardown.
    manager = PushManager(isIOS: false);
    expect(callbacks, 0);
  });
}
