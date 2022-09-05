// @dart = 2.12

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'push_intent.dart';
import 'request_push_dialog.dart';

export 'push_intent.dart';

class PushManager extends ChangeNotifier {
  PushManager() {
    _pushChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'refreshPushPermission':
          openPush = false;
          break;
        case 'getCidFromIOS':
          _gotCidFromIOS(call.arguments);
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  bool _openPush = Platform.isIOS ? true : false;

  bool get openPush => _openPush;

  set openPush(bool value) {
    _openPush = value;
    notifyListeners();
  }

  static const Tag = 'PushManager_RequestNotification';

  void showRequestNotificationDialog() {
    SmartDialog.show(
      clickBgDismissTemp: false,
      backDismiss: false,
      tag: Tag,
      widget: RequestPushDialog(),
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
  }

  // 在设置里，可以手动打开推送
  Future<void> turnOnPushService(
      Function success, Function failure, Function error) async {
    try {
      final result = await _pushChannel.invokeMethod("turnOnPushService");
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
      await _pushChannel.invokeMethod("turnOffPushService");
      openPush = false;
      success();
    } catch (e) {
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

  void _gotCidFromIOS(arguments) async {
    final list = jsonDecode(jsonEncode(arguments));
    AuthService.updateCid(list['cid'], onResult: (_) {
      debugPrint('cid 更新成功');
    }, onFailure: (_) {});
  }
}

const _pushChannel = MethodChannel('com.twt.service/push');
