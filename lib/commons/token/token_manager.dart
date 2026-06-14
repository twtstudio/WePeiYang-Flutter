import 'package:we_pei_yang_flutter/commons/util/log/log.dart';
import 'dart:convert';

abstract class TokenManagerAbstract {
  bool checkTokenLocal(String token) {
    try {
      if (token == "") return false;

      final segments = token.split('.');
      if (segments.length != 3) return false;

      final payloadString = base64Url.normalize(segments[1]);
      final payload = json.decode(utf8.decode(base64Url.decode(payloadString)));
      final exp = payload['exp'];
      if (exp is! int) return false;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiresAt.isAfter(DateTime.now().subtract(Duration(minutes: 5)));
    } catch (e) {
      Log.e(e, null, 'token');
      return false;
    }
  }

  Future<String> get token;

  Future<String> refreshToken();
}
