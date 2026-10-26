/// The post link stored in notification history by opencenter.
int? postIdFromNotificationUrl(String url) {
  final match =
      RegExp(r'^wpy://wpy\.app/post\?id=([1-9][0-9]{0,9})$').firstMatch(url);
  if (match == null) return null;
  final id = int.tryParse(match.group(1)!);
  return id != null && id <= 2147483647 ? id : null;
}
