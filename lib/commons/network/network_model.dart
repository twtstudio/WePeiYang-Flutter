class CommonBody {
  // ignore: non_constant_identifier_names
  int error_code;
  String message;
  Map result;

  CommonBody.fromJson(dynamic jsonData) {
    error_code = jsonData['error_code'];
    message = jsonData['message'];
    result = jsonData['result'];
  }
}
