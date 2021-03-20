import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wei_pei_yang_demo/commons/message/message_dialog.dart';

class MessageProvider extends ChangeNotifier {
  MessageProvider(this._messageChannel);

  final MethodChannel _messageChannel;
  int _feedbackCount;
  String _messageData;

  int get feedbackCount => _feedbackCount;

  String get messageData => _messageData;

  refreshFeedbackCount() async {
    _feedbackCount =
        await _messageChannel.invokeMethod<int>('getFeedbackMessageCount');
    notifyListeners();
  }
}

showMessageDialog(BuildContext context, String data) async {
  print("&&&&&&&&&&&&&&&&&&&&&&&&&&&$data&&&&&&&&&&&&&&&&&&&&&&&");
  try {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MessageDialog(data),
    );
  } catch (e) {
    print("??//////////$e");
  }
}
