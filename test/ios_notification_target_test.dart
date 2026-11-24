import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/ios_notification_target.dart';

void main() {
  Map<String, dynamic> payload(String url) => {
        'type': 2,
        'data': {'title': '评论通知', 'content': '收到一条评论', 'url': url},
      };

  test('APNs string and object payloads open the same post as Android', () {
    final post = payload('wpy://wpy.app/post?id=123');
    for (final value in [post, jsonEncode(post), 'wpy://wpy.app/post?id=123']) {
      expect(iosNotificationEvent(value), {'event': 1, 'data': 123});
    }
  });

  test('notice center notification opens the lake inbox', () {
    expect(iosNotificationEvent(payload('wpy://wpy.app/open?page=notice')),
        {'event': 7, 'data': 'notice'});
  });

  test('web notifications open the message page with their content', () {
    final event = iosNotificationEvent(payload('https://www.twt.edu.cn/'))!;
    expect(event['event'], 3);
    expect(event['data']['title'], '评论通知');
    expect(event['data']['url'], 'https://www.twt.edu.cn/');
  });

  test('malformed or unsupported notifications do not navigate', () {
    for (final value in [
      null,
      '自定义消息',
      'not json',
      [],
      {'type': 2},
      {
        'type': 2,
        'data': {'url': 123}
      },
      {
        'type': 3,
        'data': {'url': 'wpy://wpy.app/post?id=123'}
      },
      payload('wpy://evil/post?id=123'),
      payload('wpy://wpy.app/post?id=0'),
      payload('wpy://wpy.app/post?id=2147483648'),
      payload('wpy://wpy.app/post?id=1&other=2'),
      payload('wpy://wpy.app/open?page=notice&other=2'),
      payload('javascript:alert(1)'),
      payload('file:///etc/passwd'),
    ]) {
      expect(iosNotificationEvent(value), isNull, reason: '$value');
    }
  });
}
