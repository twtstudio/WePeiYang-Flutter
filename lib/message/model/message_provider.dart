import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/message/feedback_badge_widget.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/message/model/message_model.dart';
import 'package:we_pei_yang_flutter/message/network/message_service.dart';
import 'package:we_pei_yang_flutter/message/message_dialog.dart';

class MessageProvider extends ChangeNotifier {
  List<LikeMessage> _likeMessages = [];
  List<FloorMessage> _floorMessages = [];

  MessageCount _messageCount;

  List<LikeMessage> get likeMessages => _likeMessages;
  List<FloorMessage> get floorMessages => _floorMessages;

  MessageCount get messageCount => _messageCount;

  bool get isEmpty =>
      (likeMessages?.length ?? 0) == 0;

  refreshFeedbackCount() async {
    await MessageService.getUnreadMessagesCount(
        onResult: (count) {
          _messageCount = count;
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

  int getMessageCount(MessageType type) {
    switch (type) {
      case MessageType.like:
        return _messageCount?.like ?? 0;
      case MessageType.floor:
        return _messageCount?.floor ?? 0;
      case MessageType.reply:
        return _messageCount?.reply ?? 0;
      case MessageType.notice:
        return _messageCount?.notice ?? 0;
      default:
        return 0;
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
  bool get haveMessage => this == -1;
  bool get isOne => this == 1;
}