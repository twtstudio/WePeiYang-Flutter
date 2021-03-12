import 'package:flutter/services.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';

class FeedbackMessageCenter {
  static final _feedbackMessageChannel =
  MethodChannel('com.example.wei_pei_yang_demo/feedback');

  static Future<int> getFeedbackMessageCount() async {
    try {
      var count = await _feedbackMessageChannel
          .invokeMethod<int>('getFeedbackMessageCount');
      return count;
    } catch (e) {
      ToastProvider.error("get feedback message count error: " + e.toString());
      return 0;
    }
  }

  static clearFeedbackMessage() async =>
      await _feedbackMessageChannel.invokeMethod('clearFeedbackMessage');
}


