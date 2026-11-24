import 'dart:convert';

import 'post_notification_target.dart';

/// Converts an APNs payload into the existing native navigation event format.
/// Only explicit app routes and ordinary web notifications are accepted.
Map<String, dynamic>? iosNotificationEvent(Object? payload) {
  try {
    if (payload is String) {
      if (payload.startsWith('wpy://')) return _appRoute(payload);
      payload = jsonDecode(payload);
    }
    if (payload is! Map || payload['type'] != 2) return null;
    final data = payload['data'];
    if (data is! Map || data['url'] is! String) return null;
    final url = data['url'] as String;
    final route = _appRoute(url);
    if (route != null) return route;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !['https', 'http'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        data['title'] is! String ||
        data['content'] is! String) return null;
    return {
      'event': 3,
      'data': {
        'title': data['title'],
        'content': data['content'],
        'url': url,
        'createdAt': '',
      },
    };
  } on FormatException {
    return null;
  }
}

Map<String, dynamic>? _appRoute(String url) {
  final postId = postIdFromNotificationUrl(url);
  if (postId != null) return {'event': 1, 'data': postId};
  if (url == 'wpy://wpy.app/open?page=notice') {
    return {'event': 7, 'data': 'notice'};
  }
  return null;
}
