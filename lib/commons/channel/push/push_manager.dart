import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart'
    show AuthDio;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';

import 'push_intent.dart';
import 'ios_push_registration.dart';
import 'request_push_dialog.dart';

export 'push_intent.dart';

class PushManager extends ChangeNotifier with WidgetsBindingObserver {
  PushManager({bool? isIOS, IosPushRegistration? iosRegistration})
      : _isIOS = isIOS ?? Platform.isIOS,
        _registrationOverride = iosRegistration {
    if (_isIOS) WidgetsBinding.instance.addObserver(this);
    _pushChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'refreshPushPermission':
          openPush = false;
          break;
        case 'cidChanged':
          if (_isIOS && openPush) unawaited(_iosRegistration.refresh());
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  final bool _isIOS;
  final IosPushRegistration? _registrationOverride;
  bool _openPush = false;
  bool _iosReady = false;
  bool _iosBusy = false;
  bool _disposed = false;
  int _iosGeneration = 0;
  late final _iosApi = IosPushDeviceApi(applicationHeaders: {
    'DOMAIN': AuthDio.DOMAIN,
    'ticket': AuthDio.ticket,
  });
  late final _iosRegistration = _registrationOverride ??
      IosPushRegistration(
        currentToken: () => CommonPreferences.token.value,
        deviceInfo: () async =>
            await _pushChannel
                .invokeMapMethod<String, String>('getDeviceInfo') ??
            {},
        request: _iosApi.request,
        // Backend audience environment, independent of the APNs sandbox setting.
        environment: const String.fromEnvironment('PUSH_ENVIRONMENT',
            defaultValue: 'RELEASE'),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isIOS &&
        state == AppLifecycleState.resumed &&
        _iosReady &&
        !_iosBusy &&
        CommonPreferences.token.value.isNotEmpty) {
      unawaited(_initIos(showDialog: false));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_iosGeneration;
    if (_isIOS) {
      WidgetsBinding.instance.removeObserver(this);
      _iosRegistration.dispose();
    }
    _pushChannel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<String?> _activateIos(String method) async {
    if (_disposed) return null;
    final generation = ++_iosGeneration;
    _iosBusy = false;
    if (CommonPreferences.token.value.isEmpty) return 'refuse open push';
    _iosReady = true;
    _iosBusy = true;
    try {
      final result = await _pushChannel.invokeMethod<String>(method);
      if (!_isCurrentIos(generation)) return null;
      openPush = result == 'open push service success';
      if (openPush) {
        unawaited(_iosRegistration.enable());
      } else if (result == 'refuse open push') {
        unawaited(_iosRegistration.disable());
      }
      return result;
    } finally {
      if (_isCurrentIos(generation)) _iosBusy = false;
    }
  }

  bool _isCurrentIos(int generation) =>
      !_disposed && generation == _iosGeneration;

  Future<void> _initIos({bool showDialog = true}) async {
    final activation = _activateIos('initGeTuiSdk');
    final generation = _iosGeneration;
    try {
      final result = await activation;
      if (!_isCurrentIos(generation)) return;
      if (showDialog && result == 'showRequestNotificationDialog') {
        showRequestNotificationDialog();
      }
    } catch (_) {
      if (_isCurrentIos(generation)) {
        Log.w('iOS 推送初始化失败，将在回到前台时重试', tag: 'push');
      }
    }
  }

  Future<bool> _stopIos(String method, Duration timeout) async {
    if (_disposed) return false;
    ++_iosGeneration;
    _iosBusy = false;
    openPush = false;
    // Invalidates callbacks and captures the token BEFORE any asynchronous wait.
    final disabled = _iosRegistration.disable();
    await _pushChannel.invokeMethod<void>(method);
    return disabled.timeout(timeout, onTimeout: () => false);
  }

  bool get openPush => _openPush;

  set openPush(bool value) {
    _openPush = value;
    notifyListeners();
  }

  static const Tag = 'PushManager_RequestNotification';

  void showRequestNotificationDialog() {
    SmartDialog.show(
      clickMaskDismiss: false,
      backType: SmartBackType.block,
      tag: Tag,
      builder: (BuildContext context) {
        return RequestPushDialog();
      },
    );
  }

  void closeDialogAndRetryTurnOnPush() {
    SmartDialog.dismiss(status: SmartStatus.dialog, tag: Tag);
    turnOnPushService(() {
      openPush = true;
    }, () {
      ToastProvider.success("可以在设置中打开推送");
    }, () {
      //
    });
  }

  void closeDialogAndTurnOffPush() {
    SmartDialog.dismiss(status: SmartStatus.dialog, tag: Tag);
    turnOffPushService(() {
      openPush = false;
    }, () {
      //
    });
  }

  // 在用户同意隐私协议后，开启个推
  Future<void> initGeTuiSdk() async {
    if (Platform.isAndroid) {
      try {
        final result = await _pushChannel.invokeMethod<String>("initGeTuiSdk");
        switch (result) {
          case 'open push service success':
            openPush = true;
            break;
          case 'refuse open push':
            // 1. 在对话框中选择不打开推送
            // 2. 在推送权限页中不允许通知权限
            // 3. 不允许推送（没有权限或手动关闭）
            openPush = false;
            break;
          case 'showRequestNotificationDialog':
            showRequestNotificationDialog();
            break;
        }
      } on PlatformException catch (e) {
        switch (e.code) {
          case "OPEN_PUSH_SERVICE_ERROR":
            break;
          case "OPEN_NOTIFICATION_CONFIG_PAGE_ERROR":
            break;
          case "CHECK_NOTIFICATION_ENABLE_ERROR":
            break;
          case "INIT_GT_SDK_ERROR":
            break;
          case 'OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR':
            break;
          case 'FATAL_ERROR':
            break;
          default:
            break;
        }
      } catch (e) {
        // TODO
      }
    } else if (_isIOS) {
      await _initIos();
    }
  }

  // 在设置里，可以手动打开推送
  Future<void> turnOnPushService(
      Function success, Function failure, Function error) async {
    int? generation;
    try {
      final activation = _isIOS
          ? _activateIos('turnOnPushService')
          : _pushChannel.invokeMethod("turnOnPushService");
      if (_isIOS) generation = _iosGeneration;
      final result = await activation;
      if (generation != null && !_isCurrentIos(generation)) return;
      switch (result) {
        case 'open push service success':
          openPush = true;
          success();
          break;
        case 'refuse open push':
          openPush = false;
          failure();
          break;
      }
    } on PlatformException catch (e) {
      if (generation != null && !_isCurrentIos(generation)) return;
      switch (e.code) {
        case "OPEN_PUSH_SERVICE_ERROR":
          break;
        case "OPEN_NOTIFICATION_CONFIG_PAGE_ERROR":
          break;
        case "CHECK_NOTIFICATION_ENABLE_ERROR":
          break;
        case 'OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR':
          break;
        case 'FATAL_ERROR':
          break;
        default:
          break;
      }
      error();
    } catch (e) {
      if (generation != null && !_isCurrentIos(generation)) return;
      error();
    }
  }

  Future<void> turnOffPushService(Function success, Function error) async {
    int? generation;
    try {
      if (_isIOS) {
        final stopping =
            _stopIos('turnOffPushService', const Duration(seconds: 3));
        generation = _iosGeneration;
        await stopping;
        if (!_isCurrentIos(generation)) return;
      } else {
        await _pushChannel.invokeMethod("turnOffPushService");
      }
      openPush = false;
      success();
    } catch (e) {
      if (generation != null && !_isCurrentIos(generation)) return;
      error();
    }
  }

  Future<void> getCurrentCanReceivePush(
      Function(bool) success, Function(Object) error, Function noResult) async {
    try {
      final result =
          await _pushChannel.invokeMethod<bool>("getCurrentCanReceivePush");
      if (result != null) {
        success(result);
      } else {
        noResult.call();
      }
    } catch (e) {
      error(e);
    }
  }

  Future<String?> getCid() async {
    try {
      return await _pushChannel.invokeMethod<String>("getCid");
    } catch (e) {
      return null;
    }
  }

  /// Returns the stable ID for this app installation, across account changes.
  Future<String?> getInstallId() async {
    if (!Platform.isAndroid && !_isIOS) return null;
    try {
      return await _pushChannel.invokeMethod<String>('getInstallId');
    } catch (e, stack) {
      Log.e(e, stack, 'push');
      return null;
    }
  }

  /// Disables this installation in the server-side push registry.
  ///
  /// A short timeout keeps logout/account switching responsive when the
  /// network is unavailable. The native side captures the current token before
  /// the caller clears local credentials.
  Future<bool> disablePushDevice(
      {Duration timeout = const Duration(seconds: 3)}) async {
    if (_isIOS) {
      _iosReady = false;
      try {
        return await _stopIos('pausePushService', timeout);
      } catch (_) {
        return false;
      }
    }
    if (!Platform.isAndroid) return false;
    try {
      final result = await _pushChannel
          .invokeMethod<bool>('disablePushDevice')
          .timeout(timeout);
      return result == true;
    } catch (e, stack) {
      Log.e(e, stack, 'push.disable');
      return false;
    }
  }

  /// Wait briefly for vendor push channels that return the CID asynchronously.
  Future<String?> waitForCid(
      {Duration timeout = const Duration(seconds: 15)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final cid = await getCid();
      if (cid != null && cid.trim().isNotEmpty) return cid.trim();
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return await getCid();
  }

  Future<void> cancelNotification(
      int id, Function success, Function error) async {
    try {
      await _pushChannel.invokeMethod("cancelNotification", {"id", id});
      success();
    } catch (e) {
      error();
    }
  }

  Future<void> cancelAllNotification(Function success, Function error) async {
    try {
      await _pushChannel.invokeMethod("cancelAllNotification");
      success();
    } catch (e) {
      error();
    }
  }

  Future<String?> getIntentUri<T extends PushIntent>(T intent) async {
    try {
      return _pushChannel.invokeMethod<String>(
        "getIntentUri",
        // ignore: invalid_use_of_protected_member
        intent.toMap(),
      );
    } catch (e) {
      return null;
    }
  }
}

const _pushChannel = MethodChannel('com.twt.service/push');
