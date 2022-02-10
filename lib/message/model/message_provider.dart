import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/model/message_model.dart';
import 'package:we_pei_yang_flutter/message/network/message_service.dart';
import 'package:we_pei_yang_flutter/message/message_dialog.dart';

class MessageProvider extends ChangeNotifier {
  List<LikeMessage> _likeMessages = [];

  MessageCount _messageCount;

  List<LikeMessage> get likeMessages => _likeMessages;

  MessageCount get messageCount => _messageCount;

  bool get isEmpty =>
      (likeMessages?.length ?? 0) == 0;

  refreshFeedbackCount() async {
    await MessageService.getLikeMessages(page: 1, onSuccess: (list, total) {

    }, onFailure: (e) {
      ToastProvider.error(e.error.toString());
    });
    notifyListeners();
  }

  setAllMessageRead() async {
    await MessageService.setAllMessageRead(
        onSuccess: () async {
      await refreshFeedbackCount();
      ToastProvider.success('所有消息已读成功');
    }, onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  bool isMessageEmptyOfType(FeedbackMessageType type) {
    if (isEmpty) return true;
    switch (type) {
      case FeedbackMessageType.total:
        return messageCount.total.isZero;
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