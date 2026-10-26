import 'package:flutter_test/flutter_test.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/post_notification_target.dart';

void main() {
  test('notification history opens the same post as the Android intent', () {
    expect(postIdFromNotificationUrl('wpy://wpy.app/post?id=123'), 123);
    expect(postIdFromNotificationUrl('wpy://wpy.app/post?id=2147483647'),
        2147483647);
  });

  test('ordinary website links are not treated as post routes', () {
    expect(postIdFromNotificationUrl('https://www.twt.edu.cn/#/'), isNull);
    expect(postIdFromNotificationUrl('https://wpy.app/post?id=123'), isNull);
  });

  test('malformed targets cannot select unrelated routes or invalid IDs', () {
    for (final url in [
      'wpy://other.app/post?id=123',
      'wpy://wpy.app/post?id=0',
      'wpy://wpy.app/post?id=-1',
      'wpy://wpy.app/post?id=2147483648',
      'wpy://wpy.app/post?id=123&next=other',
      'wpy://wpy.app/post?id=123;S.type=other',
      'wpy://wpy.app/post',
      '',
    ]) {
      expect(postIdFromNotificationUrl(url), isNull, reason: url);
    }
  });
}
