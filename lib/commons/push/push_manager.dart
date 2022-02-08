// @dart = 2.12

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'push_intent.dart';
import 'request_push_dialog.dart';
import '../channels/push.dart';

export 'push_intent.dart';

class PushManager extends ChangeNotifier {
  PushManager() {
    pushChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        // 当初始化sdk后，如果发现用户的通知权限是默认关闭的，则告知用户推送的意义，请求打开权限
        // TODO: 产品说应该隔段时间主动询问一下能否打开推送
        case "showRequestNotificationDialog":
          return await showRequestNotificationDialog();
        case 'initSdkSuccess':
          break;
        case 'refreshPushPermission':
          openPush = false;
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  bool _openPush = false;
  bool get openPush => _openPush;

  set openPush(bool value) {
    _openPush = value;
    notifyListeners();
  }

  // 在用户同意隐私协议后，开启个推
  Future<void> initGeTuiSdk() async {
    try {
      debugPrint("initGeTuiSdk---");
      final result = await initSdk();
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
      }
    } on PlatformException catch (e) {
      debugPrint("$e");
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
      debugPrint("$e");
    }
  }

  // 在设置里，可以手动打开推送
  Future<void> turnOnPushService(Function success, Function failure, Function error) async {
    try {
      final result = await turnOnPush();
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
      await turnOffPush();
      openPush = false;
      success();
    } catch (e) {
      error();
    }
  }

  Future<void> getCurrentCanReceivePush(Function(bool) success, Function(Object) error, Function noResult) async {
    try {
      final result = await canPush;
      if (result != null) {
        success(result);
      } else {
        (noResult ?? error).call();
      }
    } catch (e) {
      error(e);
    }
  }

  Future<String?> getCid() async {
    try {
      return await cid;
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelNotification(int id, Function success, Function error) async {
    try {
      await cancelNotificationOf(id);
      success();
    } catch (e) {
      error();
    }
  }

  Future<void> cancelAllNotification(Function success, Function error) async {
    try {
      await cancelAllNotifications();
      success();
    } catch (e) {
      error();
    }
  }

  Future<String?> getIntentUri<T extends PushIntent>(T intent) async {
    try {
      return getIntent(intent);
    } catch (e) {
      return null;
    }
  }
}