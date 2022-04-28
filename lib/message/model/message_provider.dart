import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/message/model/message_model.dart';
import 'package:we_pei_yang_flutter/message/network/message_service.dart';
import 'package:we_pei_yang_flutter/auth/view/message/message_dialog.dart';

class MessageProvider extends ChangeNotifier {
  List<LikeMessage> _likeMessages = [];
  List<FloorMessage> _floorMessages = [];
  List<ReplyMessage> _replyMessages = [];
  List<NoticeMessage> _noticeMessages = [];

  MessageCount _messageCount = MessageCount(like: 0, floor: 0, reply: 0, notice: 0);

  List<LikeMessage> get likeMessages => _likeMessages;
  List<FloorMessage> get floorMessages => _floorMessages;
  List<ReplyMessage> get replyMessages => _replyMessages;
  List<NoticeMessage> get noticeMessages => _noticeMessages;

  MessageCount get messageCount => _messageCount;

  bool get isEmpty =>
      (likeMessages?.length ?? 0) == 0;

  refreshFeedbackCount() async {
    if(CommonPreferences().feedbackToken.value != ""){
      await MessageService.getUnreadMessagesCount(
          onResult: (count) {
            _messageCount = count;
          }, onFailure: (e) {
        ToastProvider.error(e.error.toString());
      });
      notifyListeners();
    }
  }

  setAllMessageRead() async {
    await MessageService.setAllMessageRead(
        onSuccess: () async {
      await refreshFeedbackCount();
      ToastProvider.success('所有消息已读成功');
    }, onFailure: (e) => ToastProvider.error(e.error.toString()));
    notifyListeners();
  }

  getLikeMessages({int page = 1, bool isRefresh = true}) async {
      await MessageService.getLikeMessages(
          page: page,
          onSuccess: (list, total) {
            if(isRefresh) clearLikeMessages();
            _likeMessages.addAll(list);
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
      notifyListeners();
  }

  clearLikeMessages() {
    _likeMessages.clear();
  }

  int getMessageCount(MessageType type) {
    switch (type) {
      case MessageType.like:
        return _messageCount?.like ?? 0;
      case MessageType.floor:
        return _messageCount?.floor ?? 0;
      case MessageType.reply:
        return _messageCount?.reply ?? 0;
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