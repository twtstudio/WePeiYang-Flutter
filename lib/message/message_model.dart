import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';

class TotalMessageData {
  List<MessageDataItem> questions;
  ClassifiedCount classifiedMessageCount;

  TotalMessageData({this.questions, this.classifiedMessageCount});

  static TotalMessageData fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    TotalMessageData total = TotalMessageData();
    total.questions = []..addAll((map['question_list'] as List ?? [])
        .map<MessageDataItem>((m) => MessageDataItem.fromJson(m)));
    total.classifiedMessageCount =
        ClassifiedCount.fromJson(map['message_count'] ?? []);
    return total;
  }
}

class ClassifiedCount {
  int favor;
  int contain;
  int reply;

  ClassifiedCount.fromJson(List<dynamic> list) {
    favor = list[MessageType.favor.index] ?? 0;
    contain = list[MessageType.contain.index] ?? 0;
    reply = list[MessageType.reply.index] ?? 0;
  }

  int get total => favor + contain + reply;
}

class MessageDataItem {
  int questionId;
  bool isOwner;
  bool isFavour;

  MessageDataItem({this.questionId, this.isFavour, this.isOwner});

  static MessageDataItem fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    MessageDataItem item = MessageDataItem();
    item.questionId = map['question_id'] ?? 0;
    item.isOwner = map['is_owner'] ?? false;
    item.isFavour = map['is_favorite'] ?? false;
    return item;
  }
}
