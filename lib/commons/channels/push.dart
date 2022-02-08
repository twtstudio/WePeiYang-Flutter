// @dart = 2.12
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/push/push_intent.dart';

const _pushChannel = MethodChannel('com.twt.service/push');

MethodChannel get pushChannel => _pushChannel;

Future<String?> initSdk() async => await _pushChannel.invokeMethod<String>("initGeTuiSdk");

Future<String?> turnOnPush() async => await _pushChannel.invokeMethod("turnOnPushService");

Future<void> turnOffPush() async => await _pushChannel.invokeMethod("turnOffPushService");

Future<bool?> get canPush async => await _pushChannel.invokeMethod<bool>("getCurrentCanReceivePush");

Future<String?> get cid async => await _pushChannel.invokeMethod<String>("getCid");

Future<void> cancelNotificationOf(int id) async {
  return await _pushChannel.invokeMethod("cancelNotification", {"id", id});
}

Future<void> cancelAllNotifications() async => await _pushChannel.invokeMethod("cancelAllNotification");

Future<String?> getIntent<T extends PushIntent>(T intent) async {
  return await _pushChannel.invokeMethod<String>(
    "getIntentUri",
    intent.toMap(),
  );
}
