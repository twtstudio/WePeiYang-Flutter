class MessageDataItem {
  int messageId;
  int id;

  MessageDataItem({this.messageId, this.id});

  static MessageDataItem fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    MessageDataItem item = MessageDataItem();
    item.id = map['id'] ?? 0;
    item.messageId = map['messageId'] ?? 0;
    return item;
  }
}
