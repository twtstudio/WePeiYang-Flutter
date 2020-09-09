import 'dart:convert';

class CommonBody<T> {
  int error_code;
  String message;
  T data;

  CommonBody.fromJson(String data) {
    Map<String, String> tmp = json.decode(data);
    error_code = tmp['error_code'] as int;
    message = tmp['message'];
    data = tmp['data'];
  }
}

class Token {
  String token;

  Token(this.token);

  Token.fromJson(dynamic tmp) {
    token = tmp['token'];
  }
}
