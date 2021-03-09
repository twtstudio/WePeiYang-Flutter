import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umeng_sdk/umeng_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('umeng_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await UmengSdk.platformVersion, '42');
  });
}
