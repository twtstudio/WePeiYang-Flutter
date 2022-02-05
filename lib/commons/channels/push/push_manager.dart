import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'push_intent.dart';
import 'request_push_dialog.dart';
export 'push_intent.dart';

class PushManager {
  PushManager._() {
    _pushChannel.setMethodCallHandler((call) async {
      switch (call.method) {
      // 当初始化sdk后，如果发现用户的通知权限是默认关闭的，则告知用户推送的意义，请求打开权限
      // TODO: 产品说应该隔段时间主动询问一下能否打开推送
        case "showRequestNotificationDialog":
          return await showRequestNotificationDialog();
        case 'initSdkSuccess':
          _initSdk = true;
          break;
        case 'openPushSuccess':
          _openPush = true;
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  bool _initSdk = false;
  bool _openPush = false;

  bool get initSdk => _initSdk;

  bool get openPush => _openPush;

  static const _pushChannel = MethodChannel('com.twt.service/push');

  static PushManager _instance;

  static PushManager getInstance() {
    if (_instance == null) {
      _instance = PushManager._();
    }
    return _instance;
  }

  // 在用户同意隐私协议后，开启个推
  Future<void> initGeTuiSdk() async {
    try {
      final result = await _pushChannel.invokeMethod<String>("initGeTuiSdk");
      _initSdk = true;
      switch (result) {
        case 'open push service success':
          _openPush = true;
          break;
        case 'refuse open push':
          _openPush = false;
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
  Future<void> turnOnPushService(Function success, Function failure,
      Function error) async {
    try {
      final result = await _pushChannel.invokeMethod("turnOnPushService");
      switch (result) {
        case 'open push service success':
          _openPush = true;
          success();
          break;
        case 'refuse open push':
          _openPush = false;
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
      _openPush = false;
      success();
    } catch (e) {
      error();
    }
  }

  Future<void> getCurrentCanReceivePush(Function(bool) success,
      Function(Object) error, Function noResult) async {
    try {
      final result =
      await _pushChannel.invokeMethod<bool>("getCurrentCanReceivePush");
      if (result != null) {
        success(result);
      } else {
        (noResult ?? error).call();
      }
    } catch (e) {
      error(e);
    }
  }

  Future<String> getCid() async {
    try {
      return await _pushChannel.invokeMethod<String>("getCid");
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelNotification(int id, Function success,
      Function error) async {
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

  Future<String> getIntentUri<T extends PushIntent>(T intent) async {
    try {
      return await _pushChannel.invokeMethod<String>(
        "getIntentUri",
        intent.toMap(),
      );
    } catch (e) {
      return null;
    }
  }
}
