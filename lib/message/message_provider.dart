import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wei_pei_yang_demo/message/feedback_badge_widget.dart';
import 'package:wei_pei_yang_demo/message/message_center.dart';
import 'package:wei_pei_yang_demo/message/message_dialog.dart';
import 'package:wei_pei_yang_demo/message/message_model.dart';

class MessageProvider extends ChangeNotifier {
  MessageProvider(this._messageChannel);

  final MethodChannel _messageChannel;
  List<MessageDataItem> _feedbackQuestions;
  List<MessageDataItem> _feedbackFavourites;
  List<int> _feedbackMessageList;
  String _messageData;
  int _totalMessageCount ;


  List<MessageDataItem> get feedbackQs => _feedbackQuestions;

  List<MessageDataItem> get feedbackFs => _feedbackFavourites;

  List<int> get feedbackMessageList => _feedbackMessageList;

  int get totalMessageCount => _totalMessageCount;

  bool get isEmpty =>
      (feedbackFs?.length ?? 0) + (feedbackQs?.length ?? 0) == 0;

  String get messageData => _messageData;

  refreshFeedbackCount() async {
    var result = await MessageRepository.getAllMessages() ?? TotalMessageData();
    print("FeedbackmessageCount ${result.questions?.length ?? -1}");
    _feedbackQuestions =
        result.questions?.where((element) => element.isOwner)?.toList() ?? [];
    _feedbackFavourites =
        result.questions?.where((element) => element.isFavour)?.toList() ?? [];
    _feedbackMessageList = result.questions?.map((e) => e.questionId)?.toList() ?? [];
    _totalMessageCount = result.totalMessageCount;
    print("SETFEEDBACKSUCCESS");
    notifyListeners();
  }

  setFeedbackQuestionRead(int messageId) async {
    print("SETFEEDBACK");
    await MessageRepository.setQuestionRead(messageId);
    await refreshFeedbackCount();
    print("SETFEEDBACKSUCCESS");
  }

  bool inMessageList(int questionId) => questionId == null
      ? false
      : _feedbackMessageList?.contains(questionId) ?? false;

  bool isMessageEmptyOfType(FeedbackMessageType type) {
    if(isEmpty) return true;
    switch (type) {
      case FeedbackMessageType.detail_post:
        return feedbackQs.length.isZero;
        break;
      case FeedbackMessageType.detail_favourite:
        return feedbackFs.length.isZero;
        break;
      case FeedbackMessageType.home:
        return feedbackMessageList.length.isZero;
        break;
      case FeedbackMessageType.mailbox:
        return totalMessageCount.isZero;
        break;
      default:
        return true;
    }
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

extension IntExtension on int {
  bool get isZero => this == 0;
}
