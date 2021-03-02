import 'package:flutter/services.dart';

class NotifyProvider {
  static final notificationBar =
      const MethodChannel('com.example.wei_pei_yang_demo/notify');

  static Future<void> setNotification(String text) async {

    var result = await notificationBar.invokeMethod('notify', {'text': text});
    return result == 'success';
  }
}
