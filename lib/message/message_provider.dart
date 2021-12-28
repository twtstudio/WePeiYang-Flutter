import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/message_service.dart';
import 'package:we_pei_yang_flutter/message/message_dialog.dart';
import 'package:we_pei_yang_flutter/message/message_model.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageDataItem> _feedbackQuestions = [];
  List<MessageDataItem> _feedbackFavourites = [];
  List<int> _feedbackMessageList = [];
  List<String> _feedbackHasViewed = [];///是否查看过微口令
  String _messageData;
  ClassifiedCount _classifiedMessageCount;

  List<MessageDataItem> get feedbackQs => _feedbackQuestions;

  List<MessageDataItem> get feedbackFs => _feedbackFavourites;

  List<int> get feedbackMessageList => _feedbackMessageList;

  List<String> get feedbackHasViewed => _feedbackHasViewed;

  ClassifiedCount get classifiedMessageCount => _classifiedMessageCount;

  bool get isEmpty =>
      (feedbackFs?.length ?? 0) + (feedbackQs?.length ?? 0) == 0;

  String get messageData => _messageData;

  setFeedbackWeKoHasViewed(String postId) {
    _feedbackHasViewed.add(postId);
    notifyListeners();
  }

  refreshFeedbackCount() async {
    var result = await MessageService.getAllMessages() ?? TotalMessageData();
    _feedbackQuestions =
        result.questions?.where((element) => element.isOwner)?.toList() ?? [];
    _feedbackFavourites =
        result.questions?.where((element) => element.isFavour)?.toList() ?? [];
    _feedbackMessageList =
        result.questions?.map((e) => e.questionId)?.toList() ?? [];
    _classifiedMessageCount = result.classifiedMessageCount;
    notifyListeners();
  }

  setFeedbackQuestionRead(int messageId) async {
    await MessageService.setQuestionRead(messageId);
    await refreshFeedbackCount();
  }

  bool inMessageList(int questionId) => questionId == null
      ? false
      : _feedbackMessageList?.contains(questionId) ?? false;

  bool isMessageEmptyOfType(FeedbackMessageType type) {
    if (isEmpty) return true;
    switch (type) {
      case FeedbackMessageType.detail_post:
        return feedbackQs.length.isZero;
      case FeedbackMessageType.detail_favourite:
        return feedbackFs.length.isZero;
      case FeedbackMessageType.home:
        return feedbackMessageList.length.isZero;
      case FeedbackMessageType.mailbox:
        return classifiedMessageCount.total.isZero;
      default:
        return true;
    }
  }
}

showMessageDialog(BuildContext context, String data) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => MessageDialog(data),
  );
}

extension IntExtension on int {
  bool get isZero => this == 0;

  bool get isOne => this == 1;
}
