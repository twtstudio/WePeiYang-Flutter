import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/platform/ohos.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/log/log.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'push_intent.dart';
import 'request_push_dialog.dart';

export 'push_intent.dart';

class PushManager extends ChangeNotifier with WidgetsBindingObserver {
  PushManager() {
    if (isOhos) WidgetsBinding.instance.addObserver(this);
    _pushChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'refreshPushPermission':
          openPush = false;
          break;
        case 'pushCidChanged':
          if (isOhos) await _syncOhosPush(cidChanged: true);
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  bool _openPush = Platform.isIOS ? true : false;
  bool _disposed = false;
  Future<void>? _ohosSync;
  bool _ohosCidChanged = false;

  bool get openPush => _openPush;

  set openPush(bool value) {
    if (_disposed) return;
    _openPush = value;
    notifyListeners();
  }

  @override
  void dispose() {
    if (isOhos) {
      _disposed = true;
      WidgetsBinding.instance.removeObserver(this);
      _pushChannel.setMethodCallHandler(null);
    }
    super.dispose();
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
    if (Platform.isIOS) {
      openAppSettings();
      return;
    }
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
  // TODO: iOS逻辑还可以完善
  Future<void> initGeTuiSdk() async {
    if (isOhos) {
      await _syncOhosPush();
      return;
    }
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
    } else if (Platform.isIOS) {
      final canPush = await Permission.notification.isGranted;
      if (!canPush) showRequestNotificationDialog();
    }
  }

  // 在设置里，可以手动打开推送
  Future<void> turnOnPushService(
      Function success, Function failure, Function error) async {
    try {
      final result = await _pushChannel.invokeMethod("turnOnPushService");
      switch (result) {
        case 'open push service success':
          if (isOhos) {
            await CommonPreferences.sharedPref.setBool('can_push', true);
            await _syncOhosPush();
            if (!openPush) {
              failure();
              return;
            }
          } else {
            openPush = true;
          }
          success();
          break;
        case 'refuse open push':
          openPush = false;
          failure();
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
        case 'OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR':
          break;
        case 'FATAL_ERROR':
          break;
        default:
          break;
      }
      error();
    } catch (e) {
      error();
    }
  }

  Future<void> turnOffPushService(Function success, Function error) async {
    try {
      if (isOhos) {
        // 先撤销推送意愿，让正在执行的同步在下一次检查时退出。
        await CommonPreferences.sharedPref.setBool('can_push', false);
        await _ohosSync;
      }
      await _pushChannel.invokeMethod("turnOffPushService");
      openPush = false;
      success();
    } catch (e) {
      error();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_syncOhosPush());
  }

  Future<void> _syncOhosPush({bool cidChanged = false}) async {
    if (_disposed) return;
    final activeSync = _ohosSync;
    if (activeSync != null) {
      if (cidChanged) _ohosCidChanged = true;
      return activeSync;
    }
    final nextSync = _syncLatestOhosCid();
    _ohosSync = nextSync;
    return nextSync;
  }

  Future<void> _syncLatestOhosCid() async {
    try {
      // 上报期间收到的 CID 变更合并到下一轮，重新读取 SDK 的最新值。
      do {
        _ohosCidChanged = false;
        await _registerOhosCid();
      } while (_ohosCidChanged && !_disposed);
    } finally {
      _ohosSync = null;
    }
  }

  Future<void> _registerOhosCid() async {
    final account = CommonPreferences.userNumber.value;
    bool canRegister() =>
        !_disposed &&
        account.isNotEmpty &&
        CommonPreferences.isLogin.value &&
        CommonPreferences.canPush.value &&
        account == CommonPreferences.userNumber.value;

    if (!canRegister()) {
      openPush = false;
      return;
    }
    try {
      final cid = await getCid();
      if (!canRegister()) return;
      if (cid == null || cid.isEmpty) {
        openPush = false;
        return;
      }
      if (cid != CommonPreferences.pushCid.value ||
          account != CommonPreferences.pushUser.value) {
        await AuthService.bindPushCid(cid);
        if (!canRegister()) return;
        CommonPreferences.pushCid.value = cid;
        CommonPreferences.pushUser.value = account;
      }
      openPush = true;
    } catch (error, stack) {
      openPush = false;
      Log.e(error, stack, 'push');
    }
  }

  Future<String?> getLegacyCid() async {
    if (isOhos) return null;
    return (await getCid()) ?? '';
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
