import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/message/message_dialog.dart';
import 'package:wei_pei_yang_demo/message/message_model.dart';

class MessageProvider extends ChangeNotifier {
  MessageProvider(this._messageChannel);

  final MethodChannel _messageChannel;
  int _feedbackCounts;
  List<MessageDataItem> _feedbackQuestions;
  List<MessageDataItem> _feedbackFavourites;
  List<MessageDataItem> _feedbackMessageList;
  String _messageData;

  List<MessageDataItem> get feedbackQs => _feedbackQuestions;

  List<MessageDataItem> get feedbackFs => _feedbackFavourites;

  List<MessageDataItem> get feedbackMessageList => _feedbackMessageList;

  bool get isEmpty =>
      (feedbackFs?.length ?? 0) + (feedbackQs?.length ?? 0) == 0;

  String get messageData => _messageData;

  refreshFeedbackCount() async {
    _feedbackCounts =
        await _messageChannel.invokeMethod<int>('getFeedbackMessageCount');
    print(CommonPreferences().feedbackMessageQuestions.value);
    _feedbackQuestions = List()
      ..addAll((jsonDecode(CommonPreferences().feedbackMessageQuestions.value)
                  as List ??
              [])
          .map((e) => MessageDataItem.fromMap(e)));
    _feedbackFavourites = List()
      ..addAll((jsonDecode(CommonPreferences().feedbackMessageFavourites.value)
                  as List ??
              [])
          .map((e) => MessageDataItem.fromMap(e)));
    _feedbackMessageList = [..._feedbackFavourites, ..._feedbackQuestions];
    print("SETFEEDBACKSUCCESS");
    notifyListeners();
  }

  setFeedbackMessageRead(int messageId) async {
    print("SETFEEDBACK");
    await _messageChannel
        .invokeMethod('setMessageReadById', {"id": messageId});
    await refreshFeedbackCount();
    print("SETFEEDBACKSUCCESS");
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
