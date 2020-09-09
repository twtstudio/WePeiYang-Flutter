class Token {
  String token;

  Token(this.token);

  Token.fromJson(dynamic tmp) {
    token = tmp['token'];
  }
}
