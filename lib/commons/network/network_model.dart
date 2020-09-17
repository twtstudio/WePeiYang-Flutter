class CommonBody {
  // ignore: non_constant_identifier_names
  int error_code;
  String message;
  Map data;

  CommonBody.fromJson(dynamic jsonData) {
    error_code = jsonData['error_code'];
    message = jsonData['message'];
    data = jsonData['data'];
  }
}

class Token {
  String token;

  Token(this.token);

  Token.fromJson(dynamic tmp) {
    token = tmp['token'];
  }
}
