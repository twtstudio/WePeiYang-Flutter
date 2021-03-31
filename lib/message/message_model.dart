class TotalMessageData {
  List<MessageDataItem> questions;
  int totalMessageCount;

  TotalMessageData({this.questions, this.totalMessageCount = 0});

  static TotalMessageData fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    TotalMessageData total = TotalMessageData();
    total.questions = List()
      ..addAll((map['question_list'] as List ?? [])
          .map<MessageDataItem>((m) => MessageDataItem.fromJson(m)));
    total.totalMessageCount = map['message_count'] ?? 0;
    return total;
  }
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
