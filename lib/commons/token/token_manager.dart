import 'dart:convert';

abstract class TokenManagerAbstract {
  bool checkTokenLocal(String token) {
    try {
      if (token == "") return false;

      String payloadString = token.split('.')[1];
      final payload = json.decode(utf8.decode(base64.decode(payloadString)));
      int exp = payload['exp'];
      if (DateTime.fromMillisecondsSinceEpoch(exp * 1000).isAfter(
        DateTime.now().subtract(Duration(minutes: 5)),
      ))
        return true;
      else
        return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> get token;

  Future<String> refreshToken();
}
